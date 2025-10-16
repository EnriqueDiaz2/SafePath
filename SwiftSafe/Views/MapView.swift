import SwiftUI
import MapKit
import CoreLocation
import Combine

// MARK: - Vista de Mapa
/*
 MapView utiliza MapKit para mostrar un mapa interactivo
 con ubicaciones marcadas y funcionalidad de ubicación del usuario
*/
struct MapView: View {
    @EnvironmentObject var appDataManager: AppDataManager
    
    // Estado del mapa y ubicación
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.6737, longitude: -103.3444), // Guadalajara Centro, Jalisco, México
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedPlace: Place?
    @State private var showingLocationDetails = false
    @State private var mapType: MKMapType = .standard
    @State private var showingMapOptions = false
    @State private var showingSearch = false
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var navigateToAlerts = false
    
    // Nuevos estados para selección de ubicación
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showingSaveLocation = false
    @State private var newLocationName = ""
    @State private var newLocationDescription = ""
    @State private var isSelectingLocation = false
    @GestureState private var dragLocation = CGPoint.zero
    
    // Estados para selección rápida de ubicación nueva
    @State private var showingQuickLocationOptions = false
    @State private var temporaryPlace: Place?
    
    // Manager de ubicación
    @StateObject private var locationManager = MapLocationManager()
    
    // Estado para mostrar/ocultar lugares cercanos
    @State private var showNearbyPlaces = true
    
    // Estado para filtros visuales
    @State private var showSavedPlaces = true
    @State private var showNearbyFilter = false
    
    // Estado para filtro por categoría
    @State private var selectedCategory = "Todos"
    
    // Estado para filtro por accesibilidad
    @State private var filterAccessibleOnly = false
    
    // Computed property para lugares filtrados (guardados + cercanos + categoría + accesibilidad)
    var filteredPlaces: [Place] {
        var places: [Place] = []
        
        // Agregar lugares guardados si está activado
        if showSavedPlaces {
            places.append(contentsOf: appDataManager.favoritePlaces)
        }
        
        // Agregar lugares cercanos si está activado
        if showNearbyFilter {
            let savedIds = Set(appDataManager.favoritePlaces.map { $0.id })
            let nearby = appDataManager.nearbyPlaces.filter { !savedIds.contains($0.id) }
            places.append(contentsOf: nearby)
        }
        
        // Filtrar por categoría
        if selectedCategory != "Todos" {
            places = places.filter { place in
                matchesCategory(place: place, category: selectedCategory)
            }
        }
        
        // Filtrar por accesibilidad
        if filterAccessibleOnly {
            places = places.filter { place in
                // Un lugar es accesible si tiene al menos una reseña que lo marque como accesible
                place.reviews.contains(where: { $0.isAccessible })
            }
        }
        
        // Filtrar por búsqueda
        if searchText.isEmpty {
            return places
        } else {
            return places.filter { place in
                place.name.localizedCaseInsensitiveContains(searchText) ||
                place.subtitle.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Función para verificar si un lugar coincide con una categoría
    func matchesCategory(place: Place, category: String) -> Bool {
        let name = place.name.lowercased()
        let subtitle = place.subtitle.lowercased()
        
        switch category {
        case "Restaurantes":
            return name.contains("restaurante") || name.contains("restaurant") || name.contains("comida") || subtitle.contains("restaurante")
        case "Hospitales":
            return name.contains("hospital") || name.contains("clínica") || name.contains("clinic") || subtitle.contains("salud") || name.contains("imss")
        case "Bomberos":
            return name.contains("bombero") || name.contains("fire") || subtitle.contains("bombero")
        case "IMSS":
            return name.contains("imss") || name.contains("seguro social") || subtitle.contains("imss")
        case "Comisaría":
            return name.contains("comisaría") || name.contains("comisaria") || name.contains("policía") || name.contains("policia") || subtitle.contains("seguridad")
        default:
            return true
        }
    }
    
    // Verificar si un lugar está guardado
    func isPlaceSaved(_ place: Place) -> Bool {
        return appDataManager.favoritePlaces.contains(where: { $0.id == place.id })
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Mapa Principal
                Map(coordinateRegion: $region, 
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: .none,
                    annotationItems: filteredPlaces) { place in
                    
                    // Anotaciones personalizadas para cada lugar
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: place.latitude,
                        longitude: place.longitude
                    )) {
                        PlaceAnnotationView(
                            place: place,
                            isSaved: isPlaceSaved(place)
                        ) {
                            selectedPlace = place
                            showingLocationDetails.toggle()
                        }
                    }
                }
                .mapStyle(.standard) // Requiere iOS 17+, usar alternativa si es necesario
                .onAppear {
                    // Solicitar permisos de ubicación al aparecer la vista
                    locationManager.requestLocationPermission()
                }
                .onLongPressGesture(minimumDuration: 0.5) {
                    // Long press en el mapa para seleccionar nueva ubicación
                    handleMapLongPress()
                }
                
                // Pin centrado cuando se está seleccionando ubicación
                if isSelectingLocation {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Image(systemName: "triangle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .offset(x: 0, y: -8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // MARK: - Barra de Búsqueda
                VStack {
                    // Mensaje de instrucción cuando está en modo selección
                    if isSelectingLocation {
                        HStack {
                            Image(systemName: "hand.point.up.left.fill")
                                .foregroundColor(.white)
                            Text("Mueve el mapa para seleccionar la ubicación")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        HStack(spacing: 12) {
                            // Barra de búsqueda
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                
                                TextField("Buscar ubicaciones", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                
                                // Botón para limpiar búsqueda
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                            
                            // Botón de filtros
                            Button(action: { showingFilters.toggle() }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                    
                                    // Indicador cuando hay un filtro activo
                                    if selectedCategory != "Todos" || filterAccessibleOnly {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 12, height: 12)
                                            .offset(x: -8, y: 8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 60)
                    }
                    
                    // Contador de resultados filtrados
                    if !searchText.isEmpty && !isSelectingLocation {
                        HStack {
                            Text("\(filteredPlaces.count) resultado(s) encontrado(s)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Indicadores de filtros activos
                    VStack(spacing: 6) {
                        // Indicador de categoría activa
                        if selectedCategory != "Todos" && !isSelectingLocation {
                            HStack {
                                Text("Filtrando: \(selectedCategory)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange)
                                    .cornerRadius(15)
                                
                                Button(action: {
                                    withAnimation {
                                        selectedCategory = "Todos"
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Indicador de accesibilidad activa
                        if filterAccessibleOnly && !isSelectingLocation {
                            HStack {
                                Image(systemName: "figure.roll")
                                    .font(.caption)
                                Text("Solo lugares accesibles")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    withAnimation {
                                        filterAccessibleOnly = false
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .cornerRadius(15)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(.top, 8)
                    
                    // Botones de filtro (Guardados y Cercanos) - centrados
                    if !isSelectingLocation {
                        HStack {
                            Spacer()
                            
                            HStack(spacing: 0) {
                                // Filtro Guardados
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        showSavedPlaces.toggle()
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "exclamationmark.octagon.fill")
                                            .font(.system(size: 14))
                                        Text("Guardados")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(showSavedPlaces ? .white : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(showSavedPlaces ? Color.red : Color.white)
                                }
                                
                                // Filtro Cercanos
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        showNearbyFilter.toggle()
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Cercanos")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(showNearbyFilter ? .white : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(showNearbyFilter ? Color.blue : Color.white)
                                }
                            }
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
                            
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                
                // Botón de centrar en ubicación (abajo a la derecha)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: centerOnUserLocation) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 200)
                    }
                }
                
                // Botones de acción cuando se está seleccionando ubicación
                if isSelectingLocation {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            // Botón para confirmar ubicación
                            Button(action: confirmLocation) {
                                Image(systemName: "checkmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .padding(.trailing, 8)
                            
                            // Botón para cancelar selección
                            Button(action: cancelLocationSelection) {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .padding(.trailing)
                        }
                        .padding(.bottom, 30)
                    }
                }
                
                // Botón flotante para agregar lugar (cuando no está en modo selección)
                if !isSelectingLocation {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: addNewPlace) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
                
                // MARK: - Lista de Lugares (Panel Deslizable)
                if !isSelectingLocation {
                    VStack {
                        Spacer()
                        
                        PlacesListPanel(places: filteredPlaces) { place in
                            // Centrar mapa en el lugar seleccionado
                            withAnimation {
                                region.center = CLLocationCoordinate2D(
                                    latitude: place.latitude,
                                    longitude: place.longitude
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mapa")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLocationDetails) {
                if let place = selectedPlace {
                    LocationDetailView(place: place)
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterOptionsView(selectedCategory: $selectedCategory, filterAccessibleOnly: $filterAccessibleOnly)
            }
            .sheet(isPresented: $showingSaveLocation) {
                SaveLocationView(
                    coordinate: selectedCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    onSave: { name, description in
                        saveNewLocation(name: name, description: description)
                    }
                )
            }
            .sheet(isPresented: $showingQuickLocationOptions) {
                if let tempPlace = temporaryPlace {
                    QuickLocationOptionsView(
                        place: tempPlace,
                        onSaveAndView: { savedPlace in
                            appDataManager.favoritePlaces.append(savedPlace)
                            selectedPlace = savedPlace
                            showingQuickLocationOptions = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showingLocationDetails = true
                            }
                        },
                        onViewOnly: { place in
                            selectedPlace = place
                            showingQuickLocationOptions = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showingLocationDetails = true
                            }
                        }
                    )
                }
            }
            .background(
                NavigationLink(destination: EmergencyAlertsView(), isActive: $navigateToAlerts) {
                    EmptyView()
                }
            )
        }
    }
    
    // MARK: - Métodos
    
    /*
     Maneja el long press en el mapa para seleccionar una ubicación nueva
    */
    private func handleMapLongPress() {
        // Crear un lugar temporal en el centro del mapa
        let coordinate = region.center
        
        // Crear un lugar temporal
        temporaryPlace = Place(
            name: "Ubicación Seleccionada",
            subtitle: "Toca para agregar detalles",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            photos: [],
            reviews: []
        )
        
        // Mostrar opciones
        showingQuickLocationOptions = true
    }
    
    /*
     Centra el mapa en la ubicación actual del usuario
    */
    private func centerOnUserLocation() {
        if let userLocation = locationManager.currentLocation {
            withAnimation {
                region.center = userLocation.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            }
        } else {
            // Si no hay ubicación, solicitar permisos
            locationManager.requestLocationPermission()
        }
    }
    
    /*
     Función para agregar un nuevo lugar (simulada)
    */
    private func addNewPlace() {
        // Activar modo de selección de ubicación
        isSelectingLocation = true
    }
    
    /*
     Confirmar la ubicación seleccionada
    */
    private func confirmLocation() {
        selectedCoordinate = region.center
        isSelectingLocation = false
        showingSaveLocation = true
    }
    
    /*
     Cancelar la selección de ubicación
    */
    private func cancelLocationSelection() {
        isSelectingLocation = false
        selectedCoordinate = nil
    }
    
    /*
     Función para guardar una nueva ubicación
    */
    private func saveNewLocation(name: String, description: String) {
        guard let coordinate = selectedCoordinate else { return }
        
        let newPlace = Place(
            name: name.isEmpty ? "Nuevo Lugar" : name,
            subtitle: description.isEmpty ? "Lugar agregado desde el mapa" : description,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        appDataManager.favoritePlaces.append(newPlace)
        selectedCoordinate = nil
        showingSaveLocation = false
    }
}

// MARK: - Manager de Ubicación para MapView
/*
 Clase para manejar la ubicación del usuario usando CoreLocation
*/
class MapLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /*
     Solicita permisos de ubicación al usuario
    */
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Manejar caso de permisos denegados
            break
        case .notDetermined:
            // Permisos aún no determinados
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }
}

// MARK: - Vista de Anotación Personalizada
/*
 Vista personalizada para las anotaciones en el mapa
*/
// MARK: - Vista de Anotación Personalizada
/*
 Vista personalizada para las anotaciones en el mapa
*/
struct PlaceAnnotationView: View {
    let place: Place
    let isSaved: Bool
    let onTap: () -> Void
    
    // Función para determinar el icono y color según el tipo de lugar
    private func iconForPlace() -> (icon: String, color: Color) {
        let name = place.name.lowercased()
        let subtitle = place.subtitle.lowercased()
        
        // Detectar tipo por palabras clave
        if name.contains("restaurante") || name.contains("restaurant") || subtitle.contains("restaurante") || name.contains("comida") {
            return ("fork.knife.circle.fill", .orange)
        } else if name.contains("hospital") || name.contains("clínica") || name.contains("clinic") || subtitle.contains("salud") {
            return ("cross.circle.fill", .red)
        } else if name.contains("catedral") || name.contains("iglesia") || name.contains("church") || name.contains("templo") {
            return ("building.columns.circle.fill", .purple)
        } else if name.contains("parque") || name.contains("park") || name.contains("jardín") {
            return ("tree.circle.fill", .green)
        } else if name.contains("museo") || name.contains("museum") || name.contains("galería") {
            return ("building.2.circle.fill", .brown)
        } else if name.contains("escuela") || name.contains("school") || name.contains("universidad") || name.contains("university") {
            return ("graduationcap.circle.fill", .blue)
        } else if name.contains("tienda") || name.contains("store") || name.contains("shop") || name.contains("mall") {
            return("cart.circle.fill", .cyan)
        } else if name.contains("hotel") || name.contains("motel") {
            return ("bed.double.circle.fill", .indigo)
        } else if name.contains("banco") || name.contains("bank") {
            return ("dollarsign.circle.fill", .green)
        } else if name.contains("gasolinera") || name.contains("gas") {
            return ("fuelpump.circle.fill", .yellow)
        } else {
            // Icono por defecto
            return ("mappin.circle.fill", isSaved ? .red : .blue)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            let placeIcon = iconForPlace()
            
            VStack(spacing: 0) {
                // Icono dinámico según el tipo de lugar
                Image(systemName: placeIcon.icon)
                    .font(.title)
                    .foregroundColor(placeIcon.color)
                
                Image(systemName: "triangle.fill")
                    .font(.caption)
                    .foregroundColor(placeIcon.color)
                    .offset(x: 0, y: -5)
            }
        }
        .scaleEffect(isSaved ? 1.2 : 1.0)
    }
}

// MARK: - Panel de Lista de Lugares
/*
 Panel deslizable que muestra la lista de lugares
*/
struct PlacesListPanel: View {
    let places: [Place]
    let onPlaceSelected: (Place) -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle del panel
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary)
                .frame(width: 40, height: 6)
                .padding(.top, 10)
                .onTapGesture {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }
            
            // Contenido del panel
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Lugares Guardados")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("\(places.count) lugares")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                if isExpanded {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(places) { place in
                                PlaceListRow(place: place) {
                                    onPlaceSelected(place)
                                    withAnimation(.spring()) {
                                        isExpanded = false
                                    }
                                }
                                .padding(.horizontal)
                                
                                if place.id != places.last?.id {
                                    Divider()
                                        .padding(.leading, 60)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                } else {
                    // Vista compacta - mostrar solo los primeros lugares
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(places.prefix(3)) { place in
                                CompactPlaceCard(place: place) {
                                    onPlaceSelected(place)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
        .padding(.horizontal, 10)
    }
}

// MARK: - Fila de Lugar en Lista
/*
 Componente para mostrar un lugar en la lista
*/
struct PlaceListRow: View {
    let place: Place
    let onTap: () -> Void
    
    // Función para determinar el icono y color según el tipo de lugar
    private func iconForPlace() -> (icon: String, color: Color) {
        let name = place.name.lowercased()
        let subtitle = place.subtitle.lowercased()
        
        // Detectar tipo por palabras clave
        if name.contains("restaurante") || name.contains("restaurant") || subtitle.contains("restaurante") || name.contains("comida") {
            return ("fork.knife.circle.fill", .orange)
        } else if name.contains("hospital") || name.contains("clínica") || name.contains("clinic") || subtitle.contains("salud") {
            return ("cross.circle.fill", .red)
        } else if name.contains("catedral") || name.contains("iglesia") || name.contains("church") || name.contains("templo") {
            return ("building.columns.circle.fill", .purple)
        } else if name.contains("parque") || name.contains("park") || name.contains("jardín") {
            return ("tree.circle.fill", .green)
        } else if name.contains("museo") || name.contains("museum") || name.contains("galería") {
            return ("building.2.circle.fill", .brown)
        } else if name.contains("escuela") || name.contains("school") || name.contains("universidad") || name.contains("university") {
            return ("graduationcap.circle.fill", .blue)
        } else if name.contains("tienda") || name.contains("store") || name.contains("shop") || name.contains("mall") {
            return("cart.circle.fill", .cyan)
        } else if name.contains("hotel") || name.contains("motel") {
            return ("bed.double.circle.fill", .indigo)
        } else if name.contains("banco") || name.contains("bank") {
            return ("dollarsign.circle.fill", .green)
        } else if name.contains("gasolinera") || name.contains("gas") {
            return ("fuelpump.circle.fill", .yellow)
        } else {
            // Icono por defecto
            return ("mappin.circle.fill", .red)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            let placeIcon = iconForPlace()
            
            HStack(spacing: 15) {
                Image(systemName: placeIcon.icon)
                    .font(.title2)
                    .foregroundColor(placeIcon.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(place.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tarjeta Compacta de Lugar
/*
 Vista compacta para mostrar lugares en scroll horizontal
*/
struct CompactPlaceCard: View {
    let place: Place
    let onTap: () -> Void
    
    // Función para determinar el icono y color según el tipo de lugar
    private func iconForPlace() -> (icon: String, color: Color) {
        let name = place.name.lowercased()
        let subtitle = place.subtitle.lowercased()
        
        // Detectar tipo por palabras clave
        if name.contains("restaurante") || name.contains("restaurant") || subtitle.contains("restaurante") || name.contains("comida") {
            return ("fork.knife.circle.fill", .orange)
        } else if name.contains("hospital") || name.contains("clínica") || name.contains("clinic") || subtitle.contains("salud") {
            return ("cross.circle.fill", .red)
        } else if name.contains("catedral") || name.contains("iglesia") || name.contains("church") || name.contains("templo") {
            return ("building.columns.circle.fill", .purple)
        } else if name.contains("parque") || name.contains("park") || name.contains("jardín") {
            return ("tree.circle.fill", .green)
        } else if name.contains("museo") || name.contains("museum") || name.contains("galería") {
            return ("building.2.circle.fill", .brown)
        } else if name.contains("escuela") || name.contains("school") || name.contains("universidad") || name.contains("university") {
            return ("graduationcap.circle.fill", .blue)
        } else if name.contains("tienda") || name.contains("store") || name.contains("shop") || name.contains("mall") {
            return("cart.circle.fill", .cyan)
        } else if name.contains("hotel") || name.contains("motel") {
            return ("bed.double.circle.fill", .indigo)
        } else if name.contains("banco") || name.contains("bank") {
            return ("dollarsign.circle.fill", .green)
        } else if name.contains("gasolinera") || name.contains("gas") {
            return ("fuelpump.circle.fill", .yellow)
        } else {
            // Icono por defecto
            return ("mappin.circle.fill", .red)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            let placeIcon = iconForPlace()
            
            VStack(spacing: 8) {
                Image(systemName: placeIcon.icon)
                    .font(.title)
                    .foregroundColor(placeIcon.color)
                
                Text(place.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .frame(width: 80, height: 70)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Vista de Detalle de Ubicación
/*
 Vista modal que muestra información detallada de un lugar
*/
struct LocationDetailView: View {
    @State var place: Place
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appDataManager: AppDataManager
    
    @State private var showingAddReview = false
    @State private var showingAddPhoto = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingSaveConfirmation = false
    
    // Verificar si el lugar ya está guardado
    var isPlaceSaved: Bool {
        appDataManager.favoritePlaces.contains(where: { $0.id == place.id })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Imagen del lugar
                    ZStack(alignment: .topLeading) {
                        // Imagen de fondo (simulada con gradiente o foto real)
                        if let firstPhoto = place.photos.first, let uiImage = UIImage(named: firstPhoto) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.6), Color.brown.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 250)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.7))
                                )
                        }
                        
                        // Botón de cerrar
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    
                    // Información del lugar
                    VStack(alignment: .leading, spacing: 16) {
                        // Nombre del lugar
                        Text(place.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Rating y distancia
                        HStack(spacing: 16) {
                            // Rating
                            HStack(spacing: 4) {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(place.rating.rounded()) ? "star.fill" : "star")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                }
                                Text("\(String(format: "%.1f", place.rating)) (\(place.reviews.count) reseñas)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Distancia
                            HStack(spacing: 4) {
                                Image(systemName: "figure.walk")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text("A 50 metros")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Botones de acción para agregar contenido
                        HStack(spacing: 12) {
                            Button(action: { showingAddReview = true }) {
                                HStack {
                                    Image(systemName: "star.bubble")
                                    Text("Agregar Reseña")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            
                            Button(action: { showingImagePicker = true }) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("Agregar Foto")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.top, 8)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Descripción
                        Text(place.subtitle)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        // Coordenadas (opcional, en gris claro)
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            Text("Lat: \(String(format: "%.4f", place.latitude)), Lng: \(String(format: "%.4f", place.longitude))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 4)
                        
                        // Galería de fotos
                        if !place.photos.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fotos (\(place.photos.count))")
                                    .font(.headline)
                                    .padding(.top, 8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(place.photos, id: \.self) { photo in
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 120, height: 120)
                                                .overlay(
                                                    Image(systemName: "photo.fill")
                                                        .foregroundColor(.gray)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Sección de reseñas
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Reseñas")
                                    .font(.headline)
                                Spacer()
                                if !place.reviews.isEmpty {
                                    Text("\(place.reviews.count) reseñas")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top, 8)
                            
                            if place.reviews.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "text.bubble")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("Aún no hay reseñas")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Sé el primero en dejar una reseña")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                            } else {
                                ForEach(place.reviews) { review in
                                    ReviewCard(review: review)
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Botones de acción
                        VStack(spacing: 12) {
                            // Botón para guardar el lugar si no está guardado
                            if !isPlaceSaved {
                                Button(action: savePlace) {
                                    HStack {
                                        Image(systemName: "star.circle.fill")
                                            .foregroundColor(.orange)
                                        
                                        Text("Guardar este lugar")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.orange)
                                    .cornerRadius(12)
                                }
                            }
                            
                            Button(action: openInMaps) {
                                HStack {
                                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                        .foregroundColor(.blue)
                                    
                                    Text("Cómo llegar")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            Button(action: shareLocation) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.green)
                                    
                                    Text("Compartir ubicación")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddReview) {
            AddReviewView(place: $place, onSave: { review in
                place.reviews.append(review)
                appDataManager.updatePlace(place)
            })
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) { image in
                // En una app real, aquí guardarías la imagen en el storage
                // Por ahora solo agregamos un placeholder
                place.photos.append("photo_\(UUID().uuidString)")
                appDataManager.updatePlace(place)
            }
        }
        .alert("Lugar Guardado", isPresented: $showingSaveConfirmation) {
            Button("OK") { }
        } message: {
            Text("'\(place.name)' ha sido guardado en tus lugares favoritos")
        }
    }
    
    // MARK: - Métodos
    
    private func savePlace() {
        // Guardar el lugar en favoritos
        if !isPlaceSaved {
            appDataManager.favoritePlaces.append(place)
            showingSaveConfirmation = true
        }
    }
    
    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = place.name
        mapItem.openInMaps()
    }
    
    private func shareLocation() {
        // Implementar funcionalidad de compartir
        let activityVC = UIActivityViewController(
            activityItems: ["Ubicación: \(place.name) - \(place.subtitle)"],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// MARK: - Preview
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(AppDataManager())
    }
}

// MARK: - Vista de Opciones de Filtro
/*
 Vista que muestra opciones de filtrado para el mapa
*/
struct FilterOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCategory: String
    @Binding var filterAccessibleOnly: Bool
    
    let categories = ["Todos", "Restaurantes", "Hospitales", "Bomberos", "IMSS", "Comisaría"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Text("Filtros")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 44)
                    }
                    .padding()
                    
                    Divider()
                    
                    VStack(spacing: 24) {
                        // Sección de accesibilidad
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ACCESIBILIDAD")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    HStack(spacing: 12) {
                                        Image(systemName: "figure.roll")
                                            .font(.title3)
                                            .foregroundColor(.green)
                                            .frame(width: 30)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Solo lugares accesibles")
                                                .font(.body)
                                                .fontWeight(.medium)
                                            
                                            Text("Filtra lugares con reseñas de accesibilidad")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $filterAccessibleOnly)
                                        .labelsHidden()
                                        .tint(.green)
                                }
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Sección de categorías
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CATEGORÍAS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    CategoryButton(
                                        title: category,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Botones de acción
                        VStack(spacing: 12) {
                            Button(action: {
                                selectedCategory = "Todos"
                                filterAccessibleOnly = false
                            }) {
                                Text("Limpiar filtros")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            }
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Aplicar filtros")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Botón de Categoría
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(UIColor.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Vista Mejorada de Alertas y Emergencias
struct EmergencyAlertsView: View {
    @State private var showingEmergencyMap = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Título de alertas
            Text("Alertas y emergencias")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)
            
            // Grid de rectángulos vacíos (2x3)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(0..<6, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(UIColor.systemGray6))
                        .frame(height: 120)
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Botón para ver lugares de emergencia
            Button(action: { showingEmergencyMap = true }) {
                Text("Ver lugares de emergencia")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(25)
            }
            .padding()
            .sheet(isPresented: $showingEmergencyMap) {
                EmergencyMapView()
            }
        }
        .navigationTitle("Emergencias")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Vista para Guardar Nueva Ubicación
struct SaveLocationView: View {
    @Environment(\.dismiss) var dismiss
    let coordinate: CLLocationCoordinate2D
    let onSave: (String, String) -> Void
    
    @State private var locationName = ""
    @State private var locationDescription = ""
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Lugar")) {
                    TextField("Nombre del lugar", text: $locationName)
                        .focused($isNameFocused)
                    
                    TextField("Descripción (opcional)", text: $locationDescription)
                }
                
                Section(header: Text("Coordenadas")) {
                    HStack {
                        Text("Latitud:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.6f", coordinate.latitude))
                    }
                    
                    HStack {
                        Text("Longitud:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.6f", coordinate.longitude))
                    }
                }
                
                Section {
                    Button(action: {
                        onSave(locationName, locationDescription)
                        dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Guardar Ubicación")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(locationName.isEmpty)
                }
            }
            .navigationTitle("Nueva Ubicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
    }
}

// MARK: - Vista para Agregar Reseña
struct AddReviewView: View {
    @Binding var place: Place
    let onSave: (Review) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var userName = "Usuario Actual"
    @State private var rating: Int = 0
    @State private var comment = ""
    @State private var isAccessible: Bool = false
    @State private var accessibilityDescription = ""
    @FocusState private var isCommentFocused: Bool
    @FocusState private var isAccessibilityFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header con fondo
                    VStack(spacing: 20) {
                        Text("Tu Calificación")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // Sistema de estrellas interactivo
                        VStack(spacing: 12) {
                            HStack(spacing: 15) {
                                ForEach(1...5, id: \.self) { index in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            rating = index
                                        }
                                    }) {
                                        Image(systemName: index <= rating ? "star.fill" : "star")
                                            .font(.system(size: 45))
                                            .foregroundColor(index <= rating ? .orange : Color(UIColor.systemGray4))
                                            .scaleEffect(index == rating ? 1.1 : 1.0)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            if rating > 0 {
                                Text("\(rating) de 5 estrellas")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Puntúa este lugar")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(Color(UIColor.systemBackground))
                    
                    // Sección de comentario
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tu Reseña")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemGray6))
                                .frame(height: 150)
                            
                            TextEditor(text: $comment)
                                .padding(8)
                                .frame(height: 150)
                                .background(Color.clear)
                                .focused($isCommentFocused)
                                .scrollContentBackground(.hidden)
                            
                            if comment.isEmpty {
                                Text("Escribe tu opinión sobre este lugar...")
                                    .foregroundColor(Color(UIColor.placeholderText))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Text("\(comment.count) caracteres")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 20)
                    }
                    
                    // Sección de accesibilidad
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Discapacidad:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        HStack {
                            Text("¿Es accesible para personas\ncon discapacidad?")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isAccessible)
                                .labelsHidden()
                                .tint(.green)
                                .onChange(of: isAccessible) { newValue in
                                    if newValue {
                                        // Enfocar automáticamente el campo cuando se activa
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            isAccessibilityFocused = true
                                        }
                                    } else {
                                        // Limpiar el texto si se desactiva
                                        accessibilityDescription = ""
                                    }
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.systemBackground))
                        
                        // Campo de texto que aparece cuando isAccessible está activado
                        if isAccessible {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Describe las facilidades de accesibilidad")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.systemGray6))
                                        .frame(minHeight: 100)
                                    
                                    TextEditor(text: $accessibilityDescription)
                                        .padding(8)
                                        .frame(minHeight: 100)
                                        .background(Color.clear)
                                        .focused($isAccessibilityFocused)
                                        .scrollContentBackground(.hidden)
                                    
                                    if accessibilityDescription.isEmpty {
                                        Text("Ej: Cuenta con rampa de acceso, baños adaptados, estacionamiento para personas con discapacidad...")
                                            .foregroundColor(Color(UIColor.placeholderText))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 16)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                Text("\(accessibilityDescription.count) caracteres")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.horizontal, 20)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .animation(.easeInOut(duration: 0.3), value: isAccessible)
                        }
                    }
                    
                    // Botón de enviar
                    Button(action: {
                        if canSubmit() {
                            let newReview = Review(
                                userName: userName,
                                rating: Double(rating),
                                comment: comment.isEmpty ? "Sin comentarios" : comment,
                                date: Date(),
                                isAccessible: isAccessible,
                                accessibilityDescription: accessibilityDescription
                            )
                            onSave(newReview)
                            dismiss()
                        }
                    }) {
                        Text("Enviar")
                            .font(.headline)
                            .foregroundColor(canSubmit() ? .white : Color(UIColor.systemGray3))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(canSubmit() ? Color.green.opacity(0.8) : Color(UIColor.systemGray5))
                            )
                    }
                    .disabled(!canSubmit())
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Nueva Reseña")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    // Validación para enviar la reseña
    private func canSubmit() -> Bool {
        // Debe tener calificación
        guard rating > 0 else { return false }
        
        // Si está marcado como accesible, debe tener descripción
        if isAccessible && accessibilityDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        
        return true
    }
}

// MARK: - Tarjeta de Reseña
struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Avatar del usuario
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(review.userName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.userName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(review.rating) ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                Text(formatDate(review.date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(review.comment)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            // Mostrar badge de accesibilidad si el lugar es accesible
            if review.isAccessible {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.roll")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Text("Lugar Accesible")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green)
                    .cornerRadius(8)
                    
                    if !review.accessibilityDescription.isEmpty {
                        Text(review.accessibilityDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Vista de Opciones Rápidas para Ubicación
/*
 Vista que se muestra al hacer long press en el mapa
 Permite guardar la ubicación o verla directamente
*/
struct QuickLocationOptionsView: View {
    @State var place: Place
    let onSaveAndView: (Place) -> Void
    let onViewOnly: (Place) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var locationName = ""
    @State private var locationDescription = ""
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con mapa pequeño
                ZStack {
                    Rectangle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 120)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Nueva Ubicación")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Lat: \(String(format: "%.4f", place.latitude)), Lng: \(String(format: "%.4f", place.longitude))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Formulario
                Form {
                    Section(header: Text("Información del Lugar")) {
                        TextField("Nombre del lugar (opcional)", text: $locationName)
                            .focused($isNameFocused)
                        
                        TextField("Descripción (opcional)", text: $locationDescription)
                    }
                    
                    Section {
                        // Botón para guardar y ver detalles
                        Button(action: {
                            var updatedPlace = place
                            if !locationName.isEmpty {
                                updatedPlace.name = locationName
                            }
                            if !locationDescription.isEmpty {
                                updatedPlace.subtitle = locationDescription
                            }
                            onSaveAndView(updatedPlace)
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(.blue)
                                Text("Guardar y Agregar Reseña/Foto")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                        
                        // Botón para solo ver sin guardar
                        Button(action: {
                            var updatedPlace = place
                            if !locationName.isEmpty {
                                updatedPlace.name = locationName
                            }
                            if !locationDescription.isEmpty {
                                updatedPlace.subtitle = locationDescription
                            }
                            onViewOnly(updatedPlace)
                        }) {
                            HStack {
                                Image(systemName: "eye")
                                    .foregroundColor(.green)
                                Text("Ver Detalles (sin guardar)")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }
                    
                    Section {
                        Text("Mantén presionado sobre cualquier parte del mapa para seleccionar una ubicación y agregar reseñas o fotos.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Seleccionar Ubicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

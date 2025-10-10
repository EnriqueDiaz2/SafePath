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
    
    // Manager de ubicación
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Mapa Principal
                Map(coordinateRegion: $region, 
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: .none,
                    annotationItems: appDataManager.favoritePlaces) { place in
                    
                    // Anotaciones personalizadas para cada lugar
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: place.latitude,
                        longitude: place.longitude
                    )) {
                        PlaceAnnotationView(place: place) {
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
                
                // MARK: - Barra de Búsqueda
                VStack {
                    HStack(spacing: 12) {
                        // Barra de búsqueda
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Buscar ubicaciones", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        
                        // Botón de filtros
                        Button(action: { showingFilters.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                
                // MARK: - Controles del Mapa
                VStack {
                    HStack {
                        Spacer()
                        
                        // Botón de opciones del mapa
                        Button(action: { showingMapOptions.toggle() }) {
                            Image(systemName: "map")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing)
                        .actionSheet(isPresented: $showingMapOptions) {
                            ActionSheet(
                                title: Text("Tipo de Mapa"),
                                buttons: [
                                    .default(Text("Estándar")) { mapType = .standard },
                                    .default(Text("Satélite")) { mapType = .satellite },
                                    .default(Text("Híbrido")) { mapType = .hybrid },
                                    .cancel(Text("Cancelar"))
                                ]
                            )
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        // Botón para centrar en ubicación del usuario
                        Button(action: centerOnUserLocation) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        // Botón para agregar nuevo lugar
                        Button(action: addNewPlace) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing)
                    }
                    .padding(.bottom, 30)
                }
                
                // MARK: - Lista de Lugares (Panel Deslizable)
                VStack {
                    Spacer()
                    
                    PlacesListPanel(places: appDataManager.favoritePlaces) { place in
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
            .navigationTitle("Mapa")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLocationDetails) {
                if let place = selectedPlace {
                    LocationDetailView(place: place)
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterOptionsView()
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
        let newPlace = Place(
            name: "Nuevo Lugar",
            subtitle: "Lugar agregado desde el mapa",
            latitude: region.center.latitude,
            longitude: region.center.longitude
        )
        
        appDataManager.favoritePlaces.append(newPlace)
    }
}

// MARK: - Manager de Ubicación
/*
 Clase para manejar la ubicación del usuario usando CoreLocation
*/
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
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
struct PlaceAnnotationView: View {
    let place: Place
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                
                Image(systemName: "triangle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
                    .offset(x: 0, y: -5)
            }
        }
        .scaleEffect(1.2)
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
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
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
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                
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
    let place: Place
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Imagen del lugar
            ZStack(alignment: .topLeading) {
                // Imagen de fondo (simulada con gradiente)
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
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("4.5 (29 reseñas)")
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
                
                // Botón de Calificar
                Button(action: {}) {
                    Text("Calificar")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .cornerRadius(10)
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
                
                Spacer()
                
                // Botones de acción
                VStack(spacing: 12) {
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
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // MARK: - Métodos
    
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
    @State private var selectedCategory = "Todos"
    
    let categories = ["Restaurantes", "Hospitales", "Bomberos", "IMSS", "Comisaría"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Filtro")
                        .font(.headline)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44)
                }
                .padding()
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                        
                        // Botón para ver alertas de emergencia
                        NavigationLink(destination: EmergencyAlertsView()) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                
                                Text("Ver alertas de emergencia")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
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

// MARK: - Vista de Mapa de Emergencias
struct EmergencyMapView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.6737, longitude: -103.3444), // Guadalajara Centro
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    let emergencyLocations = [
        EmergencyLocation(name: "IMSS", type: "IMSS", latitude: 20.6750, longitude: -103.3450),
        EmergencyLocation(name: "Hospital", type: "Hospital", latitude: 20.6720, longitude: -103.3480),
        EmergencyLocation(name: "Bomberos", type: "Bomberos", latitude: 20.6760, longitude: -103.3420)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: emergencyLocations) { location in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )) {
                        VStack {
                            Image(systemName: iconForType(location.type))
                                .font(.title)
                                .foregroundColor(colorForType(location.type))
                            
                            Text(location.type)
                                .font(.caption2)
                                .padding(4)
                                .background(Color.white)
                                .cornerRadius(4)
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Barra de búsqueda superior
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Buscar lugares de emergencia", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("Lugares de Emergencia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "IMSS": return "cross.case.fill"
        case "Hospital": return "staroflife.fill"
        case "Bomberos": return "flame.fill"
        default: return "mappin.circle.fill"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type {
        case "IMSS": return .blue
        case "Hospital": return .red
        case "Bomberos": return .orange
        default: return .gray
        }
    }
}

// MARK: - Modelo de Ubicación de Emergencia
struct EmergencyLocation: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let latitude: Double
    let longitude: Double
}

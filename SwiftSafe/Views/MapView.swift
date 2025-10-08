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
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // Nueva York por defecto
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @State private var selectedPlace: Place?
    @State private var showingLocationDetails = false
    @State private var mapType: MKMapType = .standard
    @State private var showingMapOptions = false
    
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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Imagen del lugar (simulada)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                        .cornerRadius(15)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        )
                    
                    // Información del lugar
                    VStack(alignment: .leading, spacing: 15) {
                        Text(place.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(place.subtitle)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        // Coordenadas
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            
                            Text("Lat: \(String(format: "%.4f", place.latitude)), Lng: \(String(format: "%.4f", place.longitude))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Acciones
                        VStack(spacing: 12) {
                            ActionButton(
                                title: "Cómo llegar",
                                icon: "arrow.triangle.turn.up.right.diamond",
                                color: .blue
                            ) {
                                // Abrir en Maps
                                openInMaps()
                            }
                            
                            ActionButton(
                                title: "Compartir ubicación",
                                icon: "square.and.arrow.up",
                                color: .green
                            ) {
                                // Compartir ubicación
                                shareLocation()
                            }
                            
                            ActionButton(
                                title: "Eliminar de favoritos",
                                icon: "trash",
                                color: .red
                            ) {
                                // Eliminar de favoritos
                                dismiss()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
            .navigationTitle("Detalles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
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

// MARK: - Botón de Acción
/*
 Botón personalizado para acciones en la vista de detalle
*/
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(AppDataManager())
    }
}
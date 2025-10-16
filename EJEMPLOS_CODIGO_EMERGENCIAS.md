# Ejemplos de Código - Mapa de Emergencias

## 1. Búsqueda de Lugares de Emergencia

### Búsqueda básica
```swift
let searcher = EmergencySearch()

// Búsqueda de hospitales cercanos
await searcher.search(
    around: CLLocationCoordinate2D(latitude: 20.6737, longitude: -103.3444),
    category: .hospital
)

// Acceder a los resultados
print("Lugares encontrados: \(searcher.places.count)")
for place in searcher.places {
    print("- \(place.name)")
}
```

### Búsqueda con radio personalizado
```swift
// Búsqueda en un radio de 5km
await searcher.search(
    around: userLocation,
    category: .pharmacy,
    spanMeters: 5000
)
```

## 2. Gestión de Ubicación

### Solicitar permisos y obtener ubicación
```swift
let locationManager = EmergencyLocationManager()

// Solicitar permisos
locationManager.request()

// Observar cambios de ubicación
locationManager.$userLocation
    .sink { location in
        if let location = location {
            print("Ubicación actual: \(location.coordinate)")
        }
    }
```

## 3. Realizar Llamadas de Emergencia

### Llamada simple
```swift
// Llamar al 911
PhoneDialer.call("911")

// Llamar a Cruz Roja
PhoneDialer.call("065")

// Llamar a un lugar de emergencia
if let phone = emergencyPlace.phoneNumber {
    PhoneDialer.call(phone)
}
```

## 4. Abrir Direcciones en Maps

### Obtener direcciones
```swift
// Abrir en Apple Maps con modo conducción
emergencyPlace.mapItem.openInMaps(launchOptions: [
    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
])

// Modo caminando
emergencyPlace.mapItem.openInMaps(launchOptions: [
    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
])

// Modo transporte público
emergencyPlace.mapItem.openInMaps(launchOptions: [
    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit
])
```

## 5. Filtrado por Categoría

### Implementación de filtros
```swift
// Estado para la categoría seleccionada
@State private var selectedCategory: EmergencyCategory = .hospital

// Cambiar categoría
Button {
    selectedCategory = .pharmacy
    Task { 
        await searcher.search(
            around: region.center, 
            category: selectedCategory
        ) 
    }
} label: {
    HStack {
        Image(systemName: selectedCategory.systemImage)
        Text(selectedCategory.rawValue)
    }
}
```

### Iterar sobre todas las categorías
```swift
ForEach(EmergencyCategory.allCases) { category in
    Button(category.rawValue) {
        selectedCategory = category
        // Buscar con nueva categoría
    }
}
```

## 6. Anotaciones en el Mapa

### Anotación personalizada
```swift
Map(position: .constant(.region(region))) {
    ForEach(places) { place in
        Annotation(place.name, coordinate: place.coordinate) {
            VStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                Text(place.name)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
    }
}
```

### Anotación de usuario
```swift
if let userCoord = locationManager.userLocation?.coordinate {
    UserAnnotation()
    Annotation("Tú", coordinate: userCoord) {
        Image(systemName: "location.circle.fill")
            .font(.title2)
            .foregroundColor(.blue)
    }
}
```

## 7. Manejo de Estados

### Estados de búsqueda
```swift
// Mostrar loading
if searcher.isSearching {
    ProgressView("Buscando lugares…")
}

// Mostrar error
if let error = searcher.errorMessage {
    Text("Error: \(error)")
        .foregroundColor(.red)
}

// Mostrar resultados
if searcher.places.isEmpty && !searcher.isSearching {
    Text("No se encontraron lugares")
        .foregroundColor(.secondary)
}
```

## 8. Tarjetas de Lugares

### Tarjeta básica
```swift
VStack(alignment: .leading, spacing: 6) {
    Text(place.name)
        .font(.headline)
    
    HStack {
        // Botón llamar
        if let phone = place.phoneNumber {
            Button {
                PhoneDialer.call(phone)
            } label: {
                Label("Llamar", systemImage: "phone.fill")
            }
        }
        
        // Botón direcciones
        Button {
            place.mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        } label: {
            Label("Cómo llegar", systemImage: "arrow.triangle.turn.up.right.circle.fill")
        }
    }
}
.padding()
.background(Color(.secondarySystemBackground))
.cornerRadius(14)
```

## 9. Control de Región del Mapa

### Centrar en ubicación
```swift
@State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
    span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
)

// Actualizar al obtener ubicación del usuario
.onChange(of: locationManager.userLocation) { _, newLocation in
    guard let coord = newLocation?.coordinate else { return }
    withAnimation {
        region.center = coord
    }
}
```

### Ajustar zoom
```swift
// Zoom cercano
region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)

// Zoom lejano
region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
```

## 10. Integración con SwiftUI

### Vista completa de ejemplo
```swift
struct EmergencyQuickView: View {
    @StateObject private var locationManager = EmergencyLocationManager()
    @StateObject private var searcher = EmergencySearch()
    @State private var selectedCategory: EmergencyCategory = .hospital
    
    var body: some View {
        VStack {
            // Selector de categoría
            Picker("Categoría", selection: $selectedCategory) {
                ForEach(EmergencyCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Lista de resultados
            List(searcher.places) { place in
                VStack(alignment: .leading) {
                    Text(place.name)
                        .font(.headline)
                    if let phone = place.phoneNumber {
                        Text(phone)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onTapGesture {
                    place.mapItem.openInMaps()
                }
            }
            
            // Botón de búsqueda
            Button("Buscar cercanos") {
                Task {
                    if let location = locationManager.userLocation?.coordinate {
                        await searcher.search(around: location, category: selectedCategory)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .onAppear {
            locationManager.request()
        }
    }
}
```

## 11. Personalización de Categorías

### Añadir nueva categoría
```swift
enum EmergencyCategory: String, CaseIterable, Identifiable {
    case hospital = "Hospitales"
    case pharmacy = "Farmacias"
    case police = "Policía"
    case fire = "Bomberos"
    case clinic = "Clínicas"  // Nueva categoría
    
    var poiCategory: MKPointOfInterestCategory {
        switch self {
        case .hospital: return .hospital
        case .pharmacy: return .pharmacy
        case .police: return .police
        case .fire: return .fireStation
        case .clinic: return .hospital  // Usar mismo POI
        }
    }
    
    var systemImage: String {
        switch self {
        case .hospital: return "cross.case.fill"
        case .pharmacy: return "pills.fill"
        case .police: return "shield.lefthalf.filled"
        case .fire: return "flame.fill"
        case .clinic: return "stethoscope"
        }
    }
}
```

## 12. Manejo de Errores

### Try-Catch personalizado
```swift
func search(around center: CLLocationCoordinate2D, category: EmergencyCategory) async {
    isSearching = true
    errorMessage = nil
    places.removeAll()
    
    do {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category.rawValue
        request.region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        self.places = response.mapItems.map { EmergencyPlace(mapItem: $0) }
        
        if places.isEmpty {
            errorMessage = "No se encontraron \(category.rawValue.lowercased()) cercanos"
        }
    } catch let error as MKError {
        switch error.code {
        case .placemarkNotFound:
            errorMessage = "No se encontraron lugares"
        case .loadingThrottled:
            errorMessage = "Demasiadas búsquedas. Intenta más tarde"
        default:
            errorMessage = "Error al buscar: \(error.localizedDescription)"
        }
    } catch {
        errorMessage = "Error desconocido: \(error.localizedDescription)"
    }
    
    isSearching = false
}
```

## 13. Extensiones Útiles

### Extensión para CLLocationCoordinate2D
```swift
extension CLLocationCoordinate2D {
    // Calcular distancia entre dos coordenadas
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return from.distance(from: to)
    }
    
    // Formatear coordenadas
    var formatted: String {
        String(format: "%.4f, %.4f", latitude, longitude)
    }
}
```

### Extensión para EmergencyPlace
```swift
extension EmergencyPlace {
    // Distancia desde una coordenada
    func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let to = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        return from.distance(from: to)
    }
    
    // Distancia formateada
    func formattedDistance(from coordinate: CLLocationCoordinate2D) -> String {
        let meters = distance(from: coordinate)
        if meters < 1000 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.1f km", meters / 1000)
        }
    }
}
```

## 14. Testing

### Datos de prueba
```swift
extension EmergencyPlace {
    static var preview: EmergencyPlace {
        let coordinate = CLLocationCoordinate2D(latitude: 20.6737, longitude: -103.3444)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Hospital de Prueba"
        mapItem.phoneNumber = "333-123-4567"
        return EmergencyPlace(mapItem: mapItem)
    }
}

// Preview en SwiftUI
#Preview {
    EmergencyPlaceCard(place: .preview)
}
```

---

**Nota**: Estos ejemplos están basados en la implementación real del mapa de emergencias de SafePath y pueden ser utilizados como referencia para extender o modificar la funcionalidad.

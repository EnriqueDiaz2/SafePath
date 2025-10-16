//
//  EmergencyMapView.swift
//  SwiftSafe
//
//  Created on 16/10/25.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Vista principal de Emergencias
/*
 Vista que muestra un mapa con lugares de emergencia cercanos
 Permite buscar hospitales, farmacias, policía y bomberos
*/
struct EmergencyMapView: View {
    @StateObject private var locationManager = EmergencyLocationManager()
    @StateObject private var searcher = EmergencySearch()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: EmergencyCategory = .hospital
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.6737, longitude: -103.3444), // Guadalajara, Jalisco
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
    )
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.6737, longitude: -103.3444),
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
    ))
    @State private var showingSOSOptions = false
    @State private var selectedPlace: EmergencyPlace?

    var body: some View {
        ZStack {
            // MARK: - Mapa
            Map(position: $cameraPosition) {
                // Anotaciones de lugares de emergencia
                // Pin personalizado con ícono según categoría
            ForEach(searcher.places) { place in
                let iconInfo = iconForPlace(place.name)
                Annotation(place.name, coordinate: place.coordinate) {
                    Button(action: {
                        withAnimation {
                            selectedPlace = place
                        }
                    }) {
                        VStack(spacing: 0) {
                            Image(systemName: iconInfo.icon)
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(iconInfo.color)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 8))
                                .foregroundColor(iconInfo.color)
                                .offset(y: -4)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

                // Punto de usuario
                if let user = locationManager.userLocation?.coordinate {
                    UserAnnotation()
                    Annotation("Tú", coordinate: user) {
                        Image(systemName: "location.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapScaleView()
            }
            .onAppear {
                locationManager.request()
                // Mantener Guadalajara como ubicación predeterminada
                Task { await searcher.search(around: region.center, category: selectedCategory) }
            }
            .ignoresSafeArea()
            
            // MARK: - Overlays en la parte inferior
            VStack {
                Spacer()
                
                // Filtros de Categorías y botones en la parte inferior
                VStack(spacing: 12) {
                    // Filtros
                    HStack(spacing: 10) {
                        ForEach(EmergencyCategory.allCases) { cat in
                            Button {
                                selectedCategory = cat
                                withAnimation {
                                    cameraPosition = .region(region)
                                }
                                Task { await searcher.search(around: region.center, category: cat) }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: cat.systemImage)
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(cat.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(cat == selectedCategory ? Color.red : Color.white)
                                .foregroundColor(cat == selectedCategory ? .white : .primary)
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Botón Buscar cerca y 911
                    HStack(spacing: 12) {
                        Button {
                            Task { await searcher.search(around: region.center, category: selectedCategory) }
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Buscar cerca")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        
                        // Botón 911 grande y rojo
                        Button {
                            PhoneDialer.call("911")
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 18, weight: .bold))
                                Text("911")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: .red.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Lista rápida de lugares
                    if !searcher.places.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(searcher.places.prefix(5), id: \.self) { p in
                                    EmergencyPlaceCard(place: p)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    if searcher.isSearching {
                        ProgressView("Buscando \(selectedCategory.rawValue.lowercased())…")
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else if let msg = searcher.errorMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.bottom, 20)
                .padding(.top, 12)
                .background(.ultraThinMaterial)
            }
            
            // Botón SOS flotante (esquina superior derecha)
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showingSOSOptions = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 24, weight: .bold))
                            Text("SOS")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(color: .red.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 80)
                }
                Spacer()
            }
        }
        .navigationTitle("Emergencias")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSOSOptions) {
            SOSOptionsView()
        }
        .sheet(item: $selectedPlace) { place in
            EmergencyPlaceDetailView(place: place, selectedPlace: $selectedPlace)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Helper: Acortar nombres largos
    private func shortName(_ name: String) -> String {
        name.count > 18 ? String(name.prefix(18)) + "…" : name
    }
    
    // MARK: - Helper: Determinar ícono y color según el nombre
    private func iconForPlace(_ placeName: String) -> (icon: String, color: Color) {
        let name = placeName.lowercased()
        if name.contains("hospital") || name.contains("clínica") || name.contains("médico") {
            return ("cross.case.fill", .red)
        } else if name.contains("farmacia") || name.contains("pharmacy") {
            return ("pills.fill", .green)
        } else if name.contains("policía") || name.contains("police") {
            return ("shield.lefthalf.filled", .blue)
        } else if name.contains("bombero") || name.contains("fire") {
            return ("flame.fill", .orange)
        } else {
            return ("cross.case.fill", .red) // Por defecto hospital
        }
    }
}

// MARK: - Tarjeta con acciones por lugar
/*
 Tarjeta que muestra información de un lugar de emergencia
 con botones para llamar y obtener direcciones
*/
struct EmergencyPlaceCard: View {
    let place: EmergencyPlace
    @State private var showReviews = false
    
    // Determinar el ícono según el nombre del lugar
    private var categoryIcon: (icon: String, color: Color) {
        let name = place.name.lowercased()
        if name.contains("hospital") || name.contains("clínica") || name.contains("médico") {
            return ("cross.case.fill", .red)
        } else if name.contains("farmacia") || name.contains("pharmacy") {
            return ("pills.fill", .green)
        } else if name.contains("policía") || name.contains("police") {
            return ("shield.lefthalf.filled", .blue)
        } else if name.contains("bombero") || name.contains("fire") {
            return ("flame.fill", .orange)
        } else {
            return ("cross.case.fill", .red) // Por defecto hospital
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header con ícono y nombre
            HStack(spacing: 10) {
                Image(systemName: categoryIcon.icon)
                    .font(.system(size: 24))
                    .foregroundColor(categoryIcon.color)
                    .frame(width: 40, height: 40)
                    .background(categoryIcon.color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    // Mostrar calificación promedio
                    if !place.reviews.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(place.averageRating.rounded()) ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(.yellow)
                            }
                            Text(String(format: "%.1f", place.averageRating))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.gray)
                            Text("(\(place.reviews.count))")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
            }

            // Botones de acción
            HStack(spacing: 8) {
                // Botón Llamar
                if let phone = place.phoneNumber {
                    Button {
                        PhoneDialer.call(phone)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 12))
                            Text("Llamar")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }

                // Botón Cómo llegar
                Button {
                    place.mapItem.openInMaps(launchOptions: [
                        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                    ])
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                        Text("Cómo llegar")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            
            // Botón Ver Reseñas
            if !place.reviews.isEmpty {
                Button {
                    showReviews = true
                } label: {
                    HStack {
                        Image(systemName: "star.bubble")
                            .font(.system(size: 12))
                        Text("Ver \(place.reviews.count) reseñas")
                            .font(.system(size: 13, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.3), lineWidth: 2)
        )
        .frame(width: 280)
        .sheet(isPresented: $showReviews) {
            PlaceReviewsView(place: place, isPresented: $showReviews)
        }
    }
}

// MARK: - Vista de Opciones SOS
struct SOSOptionsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Números de Emergencia")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    EmergencyNumberButton(
                        icon: "phone.fill",
                        title: "911",
                        subtitle: "Emergencias",
                        color: .red,
                        number: "911"
                    )
                    
                    EmergencyNumberButton(
                        icon: "cross.case.fill",
                        title: "065",
                        subtitle: "Cruz Roja",
                        color: .red,
                        number: "065"
                    )
                    
                    EmergencyNumberButton(
                        icon: "shield.lefthalf.filled",
                        title: "089",
                        subtitle: "Denuncia Anónima",
                        color: .blue,
                        number: "089"
                    )
                    
                    EmergencyNumberButton(
                        icon: "flame.fill",
                        title: "Bomberos",
                        subtitle: "068",
                        color: .orange,
                        number: "068"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
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
}

// MARK: - Botón de Número de Emergencia
struct EmergencyNumberButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let number: String
    
    var body: some View {
        Button {
            PhoneDialer.call(number)
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Vista de Reseñas del Lugar
struct PlaceReviewsView: View {
    let place: EmergencyPlace
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header con información del lugar
                        VStack(alignment: .leading, spacing: 12) {
                            Text(place.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            // Estadísticas de calificación
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(format: "%.1f", place.averageRating))
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.orange)
                                    
                                    HStack(spacing: 2) {
                                        ForEach(0..<5) { index in
                                            Image(systemName: index < Int(place.averageRating.rounded()) ? "star.fill" : "star")
                                                .font(.system(size: 16))
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(place.reviews.count) reseñas")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Basado en opiniones de usuarios")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 2)
                        
                        // Lista de reseñas
                        VStack(spacing: 16) {
                            ForEach(place.reviews) { review in
                                ReviewCardView(review: review)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Reseñas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Volver")
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(false)
    }
}

// MARK: - Tarjeta de Reseña Individual
struct ReviewCardView: View {
    let review: PlaceReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header con usuario y fecha
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.system(size: 16, weight: .semibold))
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < review.rating ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                Text(review.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            // Comentario
            Text(review.comment)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            // Foto si existe
            if let photoName = review.photoName {
                Image(photoName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Vista Detallada del Lugar de Emergencia
struct EmergencyPlaceDetailView: View {
    let place: EmergencyPlace
    @Binding var selectedPlace: EmergencyPlace?
    
    private var categoryIcon: (icon: String, color: Color) {
        let name = place.name.lowercased()
        if name.contains("hospital") || name.contains("clínica") || name.contains("médico") {
            return ("cross.case.fill", .red)
        } else if name.contains("farmacia") || name.contains("pharmacy") {
            return ("pills.fill", .green)
        } else if name.contains("policía") || name.contains("police") {
            return ("shield.lefthalf.filled", .blue)
        } else if name.contains("bombero") || name.contains("fire") {
            return ("flame.fill", .orange)
        } else {
            return ("cross.case.fill", .red)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header con imagen de placeholder
                    ZStack(alignment: .topLeading) {
                        // Imagen de placeholder
                        Rectangle()
                            .fill(categoryIcon.color.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: categoryIcon.icon)
                                    .font(.system(size: 60))
                                    .foregroundColor(categoryIcon.color.opacity(0.5))
                            )
                        
                        // Botón cerrar
                        Button(action: { 
                            selectedPlace = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .padding()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Nombre del lugar
                        Text(place.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // Calificación
                        if !place.reviews.isEmpty {
                            HStack(spacing: 8) {
                                HStack(spacing: 2) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < Int(place.averageRating.rounded()) ? "star.fill" : "star")
                                            .font(.system(size: 16))
                                            .foregroundColor(.orange)
                                    }
                                }
                                
                                Text(String(format: "%.1f", place.averageRating))
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text("(\(place.reviews.count) reseñas)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        } else {
                            HStack(spacing: 4) {
                                ForEach(0..<5) { _ in
                                    Image(systemName: "star")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                                Text("0.0 (0 reseñas)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Divider()
                        
                        // Botones de acción
                        VStack(spacing: 12) {
                            // Botón Agregar Reseña
                            Button(action: {
                                // Acción para agregar reseña
                            }) {
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 20))
                                    Text("Agregar Reseña")
                                        .font(.system(size: 16, weight: .semibold))
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            
                            // Botón Agregar Foto
                            Button(action: {
                                // Acción para agregar foto
                            }) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 20))
                                    Text("Agregar Foto")
                                        .font(.system(size: 16, weight: .semibold))
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                        }
                        
                        Divider()
                        
                        // Información del lugar
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Información")
                                .font(.headline)
                            
                            // Tipo de lugar
                            HStack(spacing: 12) {
                                Image(systemName: categoryIcon.icon)
                                    .foregroundColor(categoryIcon.color)
                                Text(place.name.contains("Hospital") ? "Hospital" :
                                     place.name.contains("Farmacia") ? "Farmacia" :
                                     place.name.contains("Policía") ? "Estación de Policía" :
                                     place.name.contains("Bombero") ? "Estación de Bomberos" :
                                     "Lugar de emergencia")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            // Distancia (simulada)
                            HStack(spacing: 12) {
                                Image(systemName: "figure.walk")
                                    .foregroundColor(.blue)
                                Text("A 50 metros")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            // Coordenadas
                            HStack(spacing: 12) {
                                Image(systemName: "location.circle")
                                    .foregroundColor(.gray)
                                Text("Lat: \(String(format: "%.4f", place.coordinate.latitude)), Lng: \(String(format: "%.4f", place.coordinate.longitude))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Sección de reseñas
                        if !place.reviews.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Reseñas")
                                        .font(.headline)
                                    Spacer()
                                    NavigationLink(destination: PlaceReviewsView(place: place, isPresented: .constant(true))) {
                                        Text("Ver todas")
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                // Mostrar primeras 2 reseñas
                                ForEach(place.reviews.prefix(2)) { review in
                                    ReviewCardView(review: review)
                                }
                            }
                        } else {
                            Divider()
                            
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("Aún no hay reseñas")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text("Sé el primero en dejar una reseña")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                        
                        Divider()
                        
                        // Botón Guardar este lugar
                        Button(action: {
                            // Acción para guardar
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "bookmark.fill")
                                Text("Guardar este lugar")
                                    .font(.system(size: 18, weight: .semibold))
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(16)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        EmergencyMapView()
    }
}

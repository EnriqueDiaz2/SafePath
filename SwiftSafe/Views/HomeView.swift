import SwiftUI

// MARK: - Vista de Inicio
struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appDataManager: AppDataManager
    
    @State private var showingChatGroups = false
    @State private var showingFilterSheet = false
    @State private var selectedFilter = "Todos los chats"
    @State private var showingEventDetail = false
    @State private var selectedEventIndex = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Próximos eventos")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        TabView {
                            EventCardWithFlags(
                                title: "México vs USA",
                                subtitle: "Jueves 11 de junio de 2026",
                                flagImage1: "bandera-mexico",
                                flagImage2: "bandera-usa"
                            )
                            .onTapGesture {
                                selectedEventIndex = 0
                                showingEventDetail = true
                            }
                            
                            EventCardWithFlags(
                                title: "Canada vs Japon",
                                subtitle: "Sábado 13 de junio de 2026",
                                flagImage1: "bandera-canada",
                                flagImage2: "bandera-japon"
                            )
                            .onTapGesture {
                                selectedEventIndex = 1
                                showingEventDetail = true
                            }
                            
                            EventCardWithFlags(
                                title: "Brasil vs Ecuador",
                                subtitle: "Domingo 15 de junio de 2026",
                                flagImage1: "bandera-brasil",
                                flagImage2: "bandera-ecuador"
                            )
                            .onTapGesture {
                                selectedEventIndex = 2
                                showingEventDetail = true
                            }
                            
                            EventCard(
                                title: "Final de Copa",
                                subtitle: "Domingo 30 de junio de 2026",
                                image: "star.fill",
                                backgroundColor: Color.red
                            )
                            .onTapGesture {
                                selectedEventIndex = 0
                                showingEventDetail = true
                            }
                        }
                        .frame(height: 180)
                        .tabViewStyle(PageTabViewStyle())
                    }
                    
                    Button(action: {
                        showingChatGroups = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Chat")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Social")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.4))
                        }
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $showingChatGroups) {
                        ChatGroupsView(
                            showingFilterSheet: $showingFilterSheet,
                            selectedFilter: $selectedFilter
                        )
                    }
                    
                    NavigationLink(destination: MapView().environmentObject(appDataManager)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Alertas y")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("emergencias")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEventDetail) {
                EventDetailView(initialIndex: selectedEventIndex)
            }
        }
    }
}

struct EventCard: View {
    let title: String
    let subtitle: String
    let image: String
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.leading)
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 100, height: 100)
                
                Image(systemName: image)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .padding(.trailing)
        }
        .frame(height: 140)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct ChatGroupsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showingFilterSheet: Bool
    @Binding var selectedFilter: String
    
    @State private var chatGroups = [
        ChatGroup(name: "Social Feed", count: 0, image: "", color: Color.green),
        ChatGroup(name: "Estados Unidos", count: 0, image: "", color: Color.red),
        ChatGroup(name: "Mexico", count: 0, image: "", color: Color.blue)
    ]
    
    var filteredChats: [ChatGroup] {
        return chatGroups
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Chat grupal")
                        .font(.headline)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44)
                }
                .padding()
                
                Button(action: {
                    showingFilterSheet = true
                }) {
                    HStack {
                        Text("Filtros")
                            .foregroundColor(.primary)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                }
                .padding(.bottom)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredChats) { chat in
                            ChatGroupRow(chatGroup: chat)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheetView(selectedFilter: $selectedFilter)
            }
        }
    }
}

struct ChatGroupRow: View {
    let chatGroup: ChatGroup
    
    var body: some View {
        HStack {
            Text("\(chatGroup.name)")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(chatGroup.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Text(chatGroup.image)
                    .font(.system(size: 35))
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
    }
}

struct FilterSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedFilter: String
    
    let filterOptions = ["Todos los chats", "Paises", "Cede\n(ciudad)", "Fase"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Filtro")
                    .font(.headline)
                    .padding()
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(filterOptions, id: \.self) { option in
                    Button(action: {
                        selectedFilter = option
                        dismiss()
                    }) {
                        Text(option)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                            )
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            
            Spacer()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct ChatGroup: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    //let icon: String
    let image: String
    let color: Color
}

// MARK: - Event Card con Banderas
struct EventCardWithFlags: View {
    let title: String
    let subtitle: String
    let flagImage1: String
    let flagImage2: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.leading)
            
            Spacer()
            
            HStack(spacing: 12) {
                Image(flagImage1)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                
                Text("VS")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Image(flagImage2)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            .padding(.trailing)
        }
        .frame(height: 140)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// MARK: - Vista de Detalle de Eventos
struct EventDetailView: View {
    @Environment(\.dismiss) var dismiss
    let initialIndex: Int
    @State private var currentIndex = 0
    
    let events = [
        MatchEvent(
            title: "Estadio Akron, Guadalajara",
            flagImage1: "bandera-mexico",
            flagImage2: "bandera-usa",
            country1: "México",
            country2: "Estados Unidos",
            phase: "FASE DE GRUPOS",
            group: "Grupo B",
            time: "20:00",
            venue: "Estadio Akron, Guadalajara",
            date: "11.06.2026"
        ),
        MatchEvent(
            title: "Estadio Akron, Guadalajara",
            flagImage1: "bandera-canada",
            flagImage2: "bandera-japon",
            country1: "Canadá",
            country2: "Japón",
            phase: "FASE DE GRUPOS",
            group: "Grupo A",
            time: "18:00",
            venue: "Estadio Akron, Guadalajara",
            date: "13.06.2026"
        ),
        MatchEvent(
            title: "Estadio Akron, Guadalajara",
            flagImage1: "bandera-brasil",
            flagImage2: "bandera-ecuador",
            country1: "Brasil",
            country2: "Ecuador",
            phase: "FASE DE GRUPOS",
            group: "Grupo C",
            time: "17:25",
            venue: "Estadio Akron, Guadalajara",
            date: "15.06.2026"
        )
    ]
    
    var body: some View {
        NavigationView {
            TabView(selection: $currentIndex) {
                ForEach(events.indices, id: \.self) { index in
                    MatchDetailCard(event: events[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                currentIndex = initialIndex
            }
        }
    }
}

// MARK: - Modelo de Evento de Partido
struct MatchEvent {
    let title: String
    let flagImage1: String
    let flagImage2: String
    let country1: String
    let country2: String
    let phase: String
    let group: String
    let time: String
    let venue: String
    let date: String
}

// MARK: - Tarjeta de Detalle de Partido
struct MatchDetailCard: View {
    let event: MatchEvent
    
    var body: some View {
        VStack(spacing: 0) {
            // Encabezado con el título del torneo
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .padding(.leading, 12)
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("COPA MUNDIAL DE LA FIFA®")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                    Text(event.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .padding(.trailing, 12)
            }
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.3, green: 0.6, blue: 0.5),
                        Color(red: 0.2, green: 0.5, blue: 0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Contenido principal
            ScrollView {
                VStack(spacing: 16) {
                    // Banderas y VS
                    HStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image(event.flagImage1)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 70)
                                .cornerRadius(4)
                            
                            Text(event.country1)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("VS")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 8) {
                            Image(event.flagImage2)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 70)
                                .cornerRadius(4)
                            
                            Text(event.country2)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.top, 24)
                    
                    // Información del encuentro
                    VStack(spacing: 12) {
                        Text("Datos del encuentro")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .center, spacing: 6) {
                            Text(event.phase)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            Text(event.group)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            Text("Hora: \(event.time)")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            Text("Sede: \(event.venue)")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            Text("Sede inicial: \(event.date)")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(UIColor.systemBackground))
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationManager())
            .environmentObject(AppDataManager())
    }
}


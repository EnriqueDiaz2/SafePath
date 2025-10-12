import SwiftUI

// MARK: - Vista de Inicio
struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appDataManager: AppDataManager
    
    @State private var showingChatGroups = false
    @State private var showingFilterSheet = false
    @State private var selectedFilter = "Todos los chats"
    
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
                                flagImage2: "bandera-usa",
                                backgroundColor: Color.black
                            )
                            
                            EventCard(
                                title: "Torneo Local",
                                subtitle: "Sábado 20 de junio de 2026",
                                image: "sportscourt.fill",
                                backgroundColor: Color.blue
                            )
                            
                            EventCard(
                                title: "Final de Copa",
                                subtitle: "Domingo 30 de junio de 2026",
                                image: "star.fill",
                                backgroundColor: Color.green
                            )
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
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
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
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationManager())
            .environmentObject(AppDataManager())
    }
}

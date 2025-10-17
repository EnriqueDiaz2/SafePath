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
    @State private var showingEmergencyOptions = false
    @State private var currentEventIndex = 0
    @State private var autoScrollTimer: Timer?
    @State private var wasDetailShowing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Próximos eventos")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        TabView(selection: $currentEventIndex) {
                            EventCardWithFlags(
                                title: "México vs USA",
                                subtitle: "Jueves 11 de junio de 2026",
                                flagImage1: "bandera-mexico",
                                flagImage2: "bandera-usa"
                            )
                            .tag(0)
                            .onTapGesture {
                                selectedEventIndex = 0
                                showingEventDetail = true
                                stopAutoScroll()
                            }
                            
                            EventCardWithFlags(
                                title: "Canada vs Japon",
                                subtitle: "Sábado 13 de junio de 2026",
                                flagImage1: "bandera-canada",
                                flagImage2: "bandera-japon"
                            )
                            .tag(1)
                            .onTapGesture {
                                selectedEventIndex = 1
                                showingEventDetail = true
                                stopAutoScroll()
                            }
                            
                            EventCardWithFlags(
                                title: "Brasil vs Ecuador",
                                subtitle: "Domingo 15 de junio de 2026",
                                flagImage1: "bandera-brasil",
                                flagImage2: "bandera-ecuador"
                            )
                            .tag(2)
                            .onTapGesture {
                                selectedEventIndex = 2
                                showingEventDetail = true
                                stopAutoScroll()
                            }
                            
                            EventCard(
                                title: "Final de Copa",
                                subtitle: "Domingo 30 de junio de 2026",
                                image: "star.fill",
                                backgroundColor: Color.red
                            )
                            .tag(3)
                            .onTapGesture {
                                selectedEventIndex = 0
                                showingEventDetail = true
                                stopAutoScroll()
                            }
                        }
                        .frame(height: 180)
                        .tabViewStyle(PageTabViewStyle())
                        .onAppear {
                            currentEventIndex = 0
                            startAutoScroll()
                        }
                        .onDisappear {
                            stopAutoScroll()
                        }
                        .onChange(of: showingEventDetail) { newValue in
                            if wasDetailShowing && !newValue {
                                // Solo reiniciar cuando se cierra (de true a false)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    startAutoScroll()
                                }
                            }
                            wasDetailShowing = newValue
                        }
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
                    
                    Button(action: {
                        showingEmergencyOptions = true
                    }) {
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
                    .sheet(isPresented: $showingEmergencyOptions) {
                        EmergencyOptionsView()
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.top, 8)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEventDetail) {
                EventDetailView(initialIndex: selectedEventIndex)
            }
        }
    }
    
    // MARK: - Auto-scroll para eventos
    func startAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentEventIndex = currentEventIndex < 3 ? currentEventIndex + 1 : 0
            }
        }
    }
    
    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
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
    
    // Países
    @State private var paisesChats = [
        ChatGroup(name: "México", count: 0, image: "🇲🇽", color: Color.green),
        ChatGroup(name: "Estados Unidos", count: 0, image: "🇺🇸", color: Color.blue),
        ChatGroup(name: "Canadá", count: 0, image: "🇨🇦", color: Color.red),
        ChatGroup(name: "Japón", count: 0, image: "🇯🇵", color: Color.red),
        ChatGroup(name: "Brasil", count: 0, image: "🇧🇷", color: Color.green),
        ChatGroup(name: "Ecuador", count: 0, image: "🇪🇨", color: Color.yellow)
    ]
    
    // Ciudades
    @State private var ciudadesChats = [
        ChatGroup(name: "Guadalajara", count: 0, image: "🏛️", color: Color.blue),
        ChatGroup(name: "Monterrey", count: 0, image: "🏔️", color: Color.orange),
        ChatGroup(name: "Ciudad de México", count: 0, image: "🏙️", color: Color.purple)
    ]
    
    // Partidos
    @State private var partidosChats = [
        ChatGroup(name: "México vs Estados Unidos", count: 0, image: "⚽", color: Color.green),
        ChatGroup(name: "Canadá vs Japón", count: 0, image: "⚽", color: Color.red),
        ChatGroup(name: "Brasil vs Ecuador", count: 0, image: "⚽", color: Color.yellow)
    ]
    
    // Todos los chats (predeterminado)
    @State private var todosChats = [
        ChatGroup(name: "Social Feed", count: 0, image: "💬", color: Color.green),
        ChatGroup(name: "México", count: 0, image: "🇲🇽", color: Color.green),
        ChatGroup(name: "Estados Unidos", count: 0, image: "🇺🇸", color: Color.blue),
        ChatGroup(name: "Canadá", count: 0, image: "🇨🇦", color: Color.red),
        ChatGroup(name: "Japón", count: 0, image: "🇯🇵", color: Color.red),
        ChatGroup(name: "Brasil", count: 0, image: "🇧🇷", color: Color.green),
        ChatGroup(name: "Ecuador", count: 0, image: "🇪🇨", color: Color.yellow),
        ChatGroup(name: "Guadalajara", count: 0, image: "🏛️", color: Color.blue),
        ChatGroup(name: "Monterrey", count: 0, image: "🏔️", color: Color.orange),
        ChatGroup(name: "Ciudad de México", count: 0, image: "�️", color: Color.purple),
        ChatGroup(name: "México vs Estados Unidos", count: 0, image: "⚽", color: Color.green),
        ChatGroup(name: "Canadá vs Japón", count: 0, image: "⚽", color: Color.red),
        ChatGroup(name: "Brasil vs Ecuador", count: 0, image: "⚽", color: Color.yellow)
    ]
    
    // Mis chats guardados
    @State private var misChats: [ChatGroup] = []
    @State private var showingJoinChatModal = false
    @State private var selectedChatToJoin: ChatGroup?
    @State private var selectedChat: ChatGroup?
    @State private var showChatDetail = false
    
    var filteredChats: [ChatGroup] {
        switch selectedFilter {
        case "Mis chats":
            // Siempre mostrar Social Feed al principio, luego los chats guardados
            let socialFeed = ChatGroup(name: "Social Feed", count: 0, image: "💬", color: Color.green)
            return [socialFeed] + misChats
        case "Paises":
            return paisesChats
        case "Cede":
            return ciudadesChats
        case "Partidos":
            return partidosChats
        default:
            return todosChats
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            NavigationView {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.title3)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Text("Chat grupal")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                            
                            // Grid de opciones de chat social
                        ScrollView {
                            
                            Button(action: {
                                showingFilterSheet = true
                            }) {
                                HStack {
                                    let filterDisplay = getFilterDisplayName(selectedFilter)
                                    Text("Filtros: \(filterDisplay)")
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(20)
                            }
                            .padding(.bottom, 4)
                            
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(filteredChats) { chat in
                                        if selectedFilter == "Mis chats" || chat.name == "Social Feed" {
                                            // Si es "Mis chats" o Social Feed, permitir navegar directamente
                                            Button(action: {
                                                selectedChat = chat
                                                showChatDetail = true
                                            }) {
                                                ChatGroupRow(chatGroup: chat)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        } else {
                                            // Si no es "Mis chats" ni Social Feed, mostrar modal para unirse
                                            Button(action: {
                                                selectedChatToJoin = chat
                                                showingJoinChatModal = true
                                            }) {
                                                ChatGroupRow(chatGroup: chat)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 4)
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $showingFilterSheet) {
                    FilterSheetView(selectedFilter: $selectedFilter)
                }
                .sheet(isPresented: $showingJoinChatModal) {
                    if let chatToJoin = selectedChatToJoin {
                        JoinChatModalView(
                            chatGroup: chatToJoin,
                            isPresented: $showingJoinChatModal,
                            onJoin: { joinChat(chatToJoin) }
                        )
                    }
                }
                .sheet(isPresented: $showChatDetail) {
                    if let chat = selectedChat {
                        ChatDetailView(chatGroup: chat)
                    }
                }
            }
        }
    }
    
    func getFilterDisplayName(_ filter: String) -> String {
        switch filter {
        case "Mis chats":
            return "Mis Chats"
        case "Paises":
            return "Países"
        case "Cede":
            return "Ciudades"
        case "Partidos":
            return "Partidos"
        default:
            return "Todos"
        }
    }
    
    func joinChat(_ chat: ChatGroup) {
        // Agregar el chat a "Mis chats" si no está ya ahí
        if !misChats.contains(where: { $0.id == chat.id }) {
            misChats.append(chat)
        }
        showingJoinChatModal = false
        selectedChatToJoin = nil
    }
}

// MARK: - Modal para unirse a un chat
struct JoinChatModalView: View {
    @Environment(\.dismiss) var dismiss
    let chatGroup: ChatGroup
    @Binding var isPresented: Bool
    let onJoin: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Unirse a Chat")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Divider()
            
            // Contenido
            VStack(spacing: 24) {
                // Icono del chat
                ZStack {
                    Circle()
                        .fill(chatGroup.color.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Text(chatGroup.image)
                        .font(.system(size: 60))
                }
                
                // Información del chat
                VStack(spacing: 8) {
                    Text("¿Unirse a este chat?")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(chatGroup.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Podrás participar en conversaciones y ver mensajes de la comunidad")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Botones de acción
            VStack(spacing: 12) {
                Button(action: {
                    onJoin()
                    dismiss()
                }) {
                    Text("Unirse al chat")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.0, green: 0.5, blue: 0.4))
                        .cornerRadius(12)
                }
                
                Button(action: { dismiss() }) {
                    Text("Cancelar")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
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
    
    let filterOptions = [
        ("Todos los chats", "Todos"),
        ("Mis chats", "Mis Chats"),
        ("Paises", "Países"),
        ("Cede", "Ciudades"),
        ("Partidos", "Partidos")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Filtros")
                    .font(.headline)
                    .padding()
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(filterOptions, id: \.0) { option in
                    Button(action: {
                        selectedFilter = option.0
                        dismiss()
                    }) {
                        HStack {
                            Text(option.1)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedFilter == option.0 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.4))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedFilter == option.0 ? Color(red: 0.0, green: 0.5, blue: 0.4).opacity(0.1) : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedFilter == option.0 ? Color(red: 0.0, green: 0.5, blue: 0.4) : Color.clear, lineWidth: 2)
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

// MARK: - Vista de Chat Detallado
struct ChatDetailView: View {
    @Environment(\.dismiss) var dismiss
    let chatGroup: ChatGroup
    
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    
    var body: some View {
        // Si es Social Feed, mostrar vista de feed
        if chatGroup.name == "Social Feed" {
            SocialFeedView()
        } else {
            // Vista de chat normal para otros grupos
            ChatMessagesView(
                chatGroup: chatGroup,
                messageText: $messageText,
                messages: $messages
            )
        }
    }
}

// MARK: - Vista de Social Feed
struct SocialFeedView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingCreatePost = false
    @State private var posts: [SocialPost] = [
        SocialPost(
            userName: "Carlos López",
            timeAgo: "hace 8 horas",
            content: "Llegando al estadio Akron 🏟️ ¡Qué emoción!",
            likes: 25,
            comments: 5,
            hasImage: true,
            imageName: "Estadio"
        ),
        SocialPost(
            userName: "José María",
            timeAgo: "hace 10 horas",
            content: "¡Vamos México! 🇲🇽 Este partido será épico",
            likes: 0,
            comments: 18,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "Ana García",
            timeAgo: "hace 12 horas",
            content: "La afición brasileña está lista 🎉⚽ Ambiente increíble en la ciudad",
            likes: 45,
            comments: 12,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "Miguel Rodríguez",
            timeAgo: "hace 1 día",
            content: "¡Primer partido del Mundial! 🇺🇸 No me lo pierdo",
            likes: 89,
            comments: 24,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "Patricia González",
            timeAgo: "hace 1 día",
            content: "Toronto está listo para recibir a los equipos 🏆 Increíble ver esto en persona",
            likes: 32,
            comments: 7,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "David Chen",
            timeAgo: "hace 2 días",
            content: "¡Qué emoción! Primera vez en Norteamérica ⚽🇯🇵 Sueño cumplido",
            likes: 56,
            comments: 15,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "Laura Martínez",
            timeAgo: "hace 2 días",
            content: "La selección ecuatoriana viene con todo 💪 Orgullosa de representar a nuestro país",
            likes: 41,
            comments: 9,
            hasImage: true,
            imageName: "Estadio"
        ),
        SocialPost(
            userName: "Roberto Sánchez",
            timeAgo: "hace 3 días",
            content: "Entrenamiento con los compañeros 🏃‍♂️ Listos para la competencia",
            likes: 78,
            comments: 22,
            hasImage: true,
            imageName: "Estadio"
        ),
        SocialPost(
            userName: "Sophia López",
            timeAgo: "hace 3 días",
            content: "¿Alguien más tan emocionado como yo? ⚽🔥",
            likes: 102,
            comments: 34,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "Francisco Ruiz",
            timeAgo: "hace 4 días",
            content: "Preparando las banderas para apoyar 🇲🇽🇨🇦 ¡Que comience la fiesta!",
            likes: 67,
            comments: 19,
            hasImage: true,
            imageName: "Estadio"
        ),
        SocialPost(
            userName: "Valentina Torres",
            timeAgo: "hace 4 días",
            content: "Con mi familia viendo el pre-partido 👨‍👩‍👧‍👦 Momento memorable",
            likes: 55,
            comments: 11,
            hasImage: true,
            imageName: "Estadio"
        ),
        SocialPost(
            userName: "Andrés Mendoza",
            timeAgo: "hace 5 días",
            content: "¡Lo mejor de estar aquí es la gente! 🙌 Conociendo aficionados de todo el mundo",
            likes: 94,
            comments: 28,
            hasImage: false,
            imageName: nil
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.title3)
                    }
                    
                    Spacer()
                    
                    Text("Social Feed")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: { showingCreatePost = true }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.4))
                            .font(.title3)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider()
                
                // Posts Feed
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(posts) { post in
                            SocialPostCard(post: post)
                            
                            Divider()
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView(isPresented: $showingCreatePost, posts: $posts)
        }
    }
}

// MARK: - Tarjeta de Post Social
struct SocialPostCard: View {
    let post: SocialPost
    @State private var isLiked = false
    @State private var showComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header del post
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(post.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Contenido del post
            if !post.content.isEmpty {
                Text(post.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Imagen del post (si tiene)
            if post.hasImage {
                ZStack(alignment: .bottomTrailing) {
                    // Intentar cargar la imagen del estadio, o usar placeholder
                    Group {
                        if let uiImage = UIImage(named: "estadio-akron") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            // Placeholder si la imagen no existe
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.6, blue: 0.9),
                                        Color(red: 0.3, green: 0.5, blue: 0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                    .frame(height: 300)
                    .clipped()
                    
                    // Etiqueta del estadio
                    if let imageName = post.imageName {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                            Text(imageName)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.95))
                        )
                        .padding(12)
                    }
                }
            }
            
            // Acciones (like, comentarios)
            HStack(spacing: 24) {
                Button(action: {
                    isLiked.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .primary)
                            .font(.system(size: 18))
                        Text("\(post.likes + (isLiked ? 1 : 0)) me gusta")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {
                    showComments.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.primary)
                            .font(.system(size: 18))
                        Text("\(post.comments) comentarios")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showComments) {
            CommentsView(post: post, isPresented: $showComments)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Vista de Comentarios
struct CommentsView: View {
    let post: SocialPost
    @Binding var isPresented: Bool
    @State private var commentText = ""
    @State private var comments: [Comment] = [
        Comment(userName: "María García", timeAgo: "hace 2 horas", text: "¡Qué increíble! 🙌", likes: 5),
        Comment(userName: "Luis Rodríguez", timeAgo: "hace 3 horas", text: "Vamos México! ⚽🇲🇽", likes: 12),
        Comment(userName: "Ana López", timeAgo: "hace 4 horas", text: "El estadio se ve hermoso", likes: 8),
        Comment(userName: "Carlos Mendez", timeAgo: "hace 5 horas", text: "Desearia estar ahí! 😭", likes: 3),
        Comment(userName: "Sofia González", timeAgo: "hace 6 horas", text: "Que emocionante es esto", likes: 15)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .font(.title3)
                }
                
                Spacer()
                
                Text("Comentarios")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
            
            // Lista de comentarios
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(comments) { comment in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 35, height: 35)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 16))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(comment.userName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Text(comment.timeAgo)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            Text(comment.text)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.leading, 47)
                                .padding(.trailing)
                            
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart")
                                            .font(.caption)
                                        Text("\(comment.likes)")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.leading, 47)
                            .padding(.trailing)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Input de nuevo comentario
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 35, height: 35)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    )
                
                TextField("Escribe un comentario...", text: $commentText)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                
                Button(action: {
                    if !commentText.isEmpty {
                        commentText = ""
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                        .foregroundColor(commentText.isEmpty ? .gray : Color(red: 0.0, green: 0.5, blue: 0.4))
                }
                .disabled(commentText.isEmpty)
            }
            .padding()
        }
    }
}

// MARK: - Modelo de Comentario
struct Comment: Identifiable {
    let id = UUID()
    let userName: String
    let timeAgo: String
    let text: String
    let likes: Int
}

// MARK: - Modelo de Post Social
struct SocialPost: Identifiable {
    let id = UUID()
    let userName: String
    let timeAgo: String
    let content: String
    let likes: Int
    let comments: Int
    let hasImage: Bool
    let imageName: String?
}

// MARK: - Vista de Chat con Mensajes
struct ChatMessagesView: View {
    @Environment(\.dismiss) var dismiss
    let chatGroup: ChatGroup
    @Binding var messageText: String
    @Binding var messages: [ChatMessage]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.title3)
                    }
                    
                    HStack(spacing: 8) {
                        if chatGroup.name.contains("vs") {
                            // Para partidos, mostrar banderas
                            let teams = chatGroup.name.components(separatedBy: " vs ")
                            if teams.count == 2 {
                                Text(getFlagForCountry(teams[0].trimmingCharacters(in: .whitespaces)))
                                    .font(.title3)
                                Text(getFlagForCountry(teams[1].trimmingCharacters(in: .whitespaces)))
                                    .font(.title3)
                            }
                        } else {
                            // Para otros chats, mostrar el emoji correspondiente
                            Text(chatGroup.image)
                                .font(.title2)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(chatGroup.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    /*HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "video.fill")
                                .foregroundColor(.primary)
                        }
                    }*/
                }
                .padding(.horizontal)
                .padding(.top, geometry.safeAreaInsets.top > 0 ? geometry.safeAreaInsets.top : 4)
                .padding(.bottom, 4)
                .background(Color(UIColor.systemBackground))
                
                Divider()
                
                // Messages Area
                ScrollView {
                    VStack(spacing: 16) {
                        // Header del chat con fecha
                        Text(getCurrentDate())
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        // Mensajes predefinidos según el tipo de chat
                        ForEach(getInitialMessages(for: chatGroup.name), id: \.id) { message in
                            MessageBubble(message: message)
                        }
                        
                        // Mensajes del usuario
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Input Area
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "face.smiling")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Mensaje...", text: $messageText)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(20)
                    
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "paperclip")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(messageText.isEmpty ? .gray : Color(red: 0.0, green: 0.5, blue: 0.4))
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemBackground))
            }
            .edgesIgnoringSafeArea(.top)
        }
        .navigationBarHidden(true)
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let newMessage = ChatMessage(
            text: messageText,
            isFromCurrentUser: true,
            timestamp: Date()
        )
        messages.append(newMessage)
        messageText = ""
    }
    
    func getInitialMessages(for chatName: String) -> [ChatMessage] {
        if chatName.contains("vs") {
            // Para partidos
            return [
                ChatMessage(text: "Welcome to the World Cup", isFromCurrentUser: false, timestamp: Date()),
                ChatMessage(text: "Hola", isFromCurrentUser: true, timestamp: Date()),
                ChatMessage(text: "This match will be awesome!", isFromCurrentUser: false, timestamp: Date()),
                ChatMessage(text: "Vamos Mexico!!", isFromCurrentUser: true, timestamp: Date())
            ]
        } else {
            // Para países o ciudades
            return [
                ChatMessage(text: "Welcome to the World Cup", isFromCurrentUser: false, timestamp: Date()),
                ChatMessage(text: "Hola", isFromCurrentUser: true, timestamp: Date()),
                ChatMessage(text: "This match will be awesome!", isFromCurrentUser: false, timestamp: Date())
            ]
        }
    }
    
    func getFlagForCountry(_ country: String) -> String {
        switch country.lowercased() {
        case "méxico", "mexico": return "🇲🇽"
        case "estados unidos": return "🇺🇸"
        case "canadá", "canada": return "🇨🇦"
        case "japón", "japon": return "🇯🇵"
        case "brasil": return "🇧🇷"
        case "ecuador": return "🇪🇨"
        default: return "⚽"
        }
    }
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "dd 'de' MMMM, yyyy, h:mm a"
        return formatter.string(from: Date())
    }
}

// MARK: - Mensaje de Chat
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    var hasImage: Bool = false
}

// MARK: - Burbuja de Mensaje
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if message.hasImage {
                    // Mensaje con imagen (para Social Feed)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(message.text)
                            .padding(12)
                            .background(Color(UIColor.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemGray4))
                            .frame(height: 150)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(maxWidth: 250)
                } else {
                    Text(message.text)
                        .padding(12)
                        .background(message.isFromCurrentUser ? Color(red: 0.0, green: 0.5, blue: 0.4) : Color(UIColor.systemGray5))
                        .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                        .cornerRadius(16)
                        .frame(maxWidth: 250, alignment: message.isFromCurrentUser ? .trailing : .leading)
                }
            }
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
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
                    MatchDetailCard(event: events[index], currentIndex: $currentIndex, totalEvents: events.count)
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
    @Binding var currentIndex: Int
    let totalEvents: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Encabezado con el título del torneo
            HStack {
                Button(action: {
                    withAnimation {
                        currentIndex = (currentIndex - 1 + totalEvents) % totalEvents
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding(.leading, 12)
                }
                
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
                
                Button(action: {
                    withAnimation {
                        currentIndex = (currentIndex + 1) % totalEvents
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding(.trailing, 12)
                }
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

// MARK: - Vista de Opciones de Emergencia
struct EmergencyOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appDataManager: AppDataManager
    @State private var showingEmergencyMap = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    Text("Alertas y emergencias")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Grid de opciones de emergencia
                ScrollView {
                    VStack(spacing: 20) {
                        // Primera fila
                        HStack(spacing: 15) {
                            EmergencyOptionCard(
                                icon: "phone.fill",
                                title: "911",
                                subtitle: "Emergencias",
                                backgroundColor: Color(red: 0.7, green: 0.2, blue: 0.2),
                                action: { callEmergency("911") }
                            )
                            
                            EmergencyOptionCard(
                                icon: "cross.case.fill",
                                title: "065",
                                subtitle: "Cruz Roja",
                                backgroundColor: Color.red,
                                action: { callEmergency("065") }
                            )
                        }
                        
                        // Segunda fila
                        HStack(spacing: 15) {
                            EmergencyOptionCard(
                                icon: "heart.fill",
                                title: "Línea de la",
                                subtitle: "vida",
                                backgroundColor: Color(red: 0.2, green: 0.5, blue: 0.4),
                                action: { callEmergency("800-911-2000") }
                            )
                            
                            EmergencyOptionCard(
                                icon: "person.fill",
                                title: "Línea de la",
                                subtitle: "mujer",
                                backgroundColor: Color(red: 0.4, green: 0.2, blue: 0.5),
                                action: { callEmergency("800-108-4053") }
                            )
                        }
                        
                        // Tercera fila
                        HStack(spacing: 15) {
                            EmergencyOptionCard(
                                icon: "scale.3d",
                                title: "089",
                                subtitle: "Denuncia anónima",
                                backgroundColor: Color(red: 0.2, green: 0.5, blue: 0.4),
                                action: { callEmergency("089") }
                            )
                            
                            EmergencyOptionCard(
                                icon: "hand.raised.fill",
                                title: "PROFECO",
                                subtitle: "",
                                backgroundColor: Color(red: 0.2, green: 0.5, blue: 0.4),
                                action: { callEmergency("800-468-8722") }
                            )
                        }
                        
                        // Botón de lugares de emergencia - Mapa con POIs de emergencia
                        Button(action: {
                            showingEmergencyMap = true
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "map.fill")
                                    .font(.headline)
                                Text("Ver lugares de emergencia")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(25)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
            .fullScreenCover(isPresented: $showingEmergencyMap) {
                NavigationView {
                    EmergencyMapView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    showingEmergencyMap = false
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 16, weight: .semibold))
                                        Text("Volver")
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    func callEmergency(_ number: String) {
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Tarjeta de Opción de Emergencia
struct EmergencyOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(backgroundColor)
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: icon)
                        .font(.system(size: 45))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(15)
        }
    }
}

// MARK: - Vista de Crear Post
struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    @Binding var posts: [SocialPost]
    @State private var postContent = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var hasImage = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Crear Post")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    publishPost()
                }) {
                    Text("Publicar")
                        .font(.headline)
                        .foregroundColor(postContent.isEmpty ? .gray : Color(red: 0.0, green: 0.5, blue: 0.4))
                }
                .disabled(postContent.isEmpty)
            }
            .padding()
            
            Divider()
            
            // Contenido del post
            VStack(alignment: .leading, spacing: 12) {
                // Avatar y nombre de usuario
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 18))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tu Usuario")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Ahora")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Campo de texto
                TextEditor(text: $postContent)
                    .frame(height: 120)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .padding(.horizontal)
                    )
                
                // Botones de acciones
                HStack(spacing: 16) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "photo")
                                .font(.system(size: 18))
                            Text("Foto")
                                .font(.subheadline)
                        }
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.4))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            
            Spacer()
        }
        .sheet(isPresented: $showingImagePicker) {
            SocialFeedImagePicker(image: $selectedImage)
                .onDisappear {
                    if selectedImage != nil {
                        hasImage = true
                    }
                }
        }
    }
    
    func publishPost() {
        // Crear un nuevo post
        let newPost = SocialPost(
            userName: "Tu Usuario",
            timeAgo: "Ahora",
            content: postContent,
            likes: 0,
            comments: 0,
            hasImage: hasImage,
            imageName: hasImage ? "Foto" : nil
        )
        
        // Agregar al inicio de los posts
        posts.insert(newPost, at: 0)
        
        // Cerrar el sheet
        isPresented = false
    }
}

// MARK: - Social Feed Image Picker
struct SocialFeedImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
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
        let parent: SocialFeedImagePicker
        
        init(_ parent: SocialFeedImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationManager())
            .environmentObject(AppDataManager())
    }
}


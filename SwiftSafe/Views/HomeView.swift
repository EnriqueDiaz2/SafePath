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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 8) {
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
    
    var filteredChats: [ChatGroup] {
        switch selectedFilter {
        case "Paises":
            return paisesChats
        case "Cede\n(ciudad)":
            return ciudadesChats
        case "Fase":
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
                                    Text(selectedFilter == "Cede\n(ciudad)" ? "Filtros: Ciudades" : "Filtros: \(selectedFilter.replacingOccurrences(of: "Todos los chats", with: "Todos"))")
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
                                        NavigationLink(destination: ChatDetailView(chatGroup: chat)) {
                                            ChatGroupRow(chatGroup: chat)
                                        }
                                        .buttonStyle(PlainButtonStyle())
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
    
    let filterOptions = [
        ("Todos los chats", "Todos"),
        ("Paises", "Países"),
        ("Cede", "Cede\n(ciudad)"),
        ("Fase", "Fase\n(Partidos)")
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
    @State private var posts: [SocialPost] = [
        SocialPost(
            userName: "Hablando en el grupo de México",
            timeAgo: "hace 8 horas",
            content: "Llegando al estadio Akron",
            likes: 25,
            comments: 5,
            hasImage: true,
            imageName: "Estadio"
        ),
        SocialPost(
            userName: "Desde en el grupo de Colombia",
            timeAgo: "hace 10 horas",
            content: "",
            likes: 0,
            comments: 18,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "Hablando en el grupo de Brasil",
            timeAgo: "hace 12 horas",
            content: "La afición brasileña está lista 🎉⚽",
            likes: 45,
            comments: 12,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "Hablando en el grupo de Estados Unidos",
            timeAgo: "hace 1 día",
            content: "¡Primer partido del Mundial! 🇺🇸",
            likes: 89,
            comments: 24,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "Desde en el grupo de Canadá",
            timeAgo: "hace 1 día",
            content: "Toronto está listo para recibir a los equipos",
            likes: 32,
            comments: 7,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "Hablando en el grupo de Japón",
            timeAgo: "hace 2 días",
            content: "¡Qué emoción! Primera vez en Norteamérica ⚽🇯🇵",
            likes: 56,
            comments: 15,
            hasImage: false,
            imageName: nil
        ),
        SocialPost(
            userName: "Desde en el grupo de Ecuador",
            timeAgo: "hace 2 días",
            content: "La selección ecuatoriana viene con todo",
            likes: 41,
            comments: 9,
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
    }
}

// MARK: - Tarjeta de Post Social
struct SocialPostCard: View {
    let post: SocialPost
    @State private var isLiked = false
    
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
                
                Button(action: {}) {
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
    }
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

// MARK: - Vista de Opciones de Emergencia
struct EmergencyOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appDataManager: AppDataManager
    
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
                        
                        // Botón de lugares de emergencia
                        NavigationLink(destination: MapView().environmentObject(appDataManager)) {
                            HStack {
                                Spacer()
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationManager())
            .environmentObject(AppDataManager())
    }
}


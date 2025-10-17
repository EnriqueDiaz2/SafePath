# 📸 Guía Rápida: Agregar y Cambiar Foto de Perfil

## 🎯 ¿Qué se implementó?

La funcionalidad completa para que los usuarios de SafePath puedan:
- ✅ Cambiar su foto de perfil
- ✅ Seleccionar fotos desde la galería
- ✅ Ver la foto en el header del perfil
- ✅ Guardar la foto de forma persistente

## 🚀 Cómo Funciona

### Paso 1️⃣: Usuario abre el perfil
- Toca el botón flotante de Perfil (ícono de persona)

### Paso 2️⃣: Ve su foto actual
- En el header del perfil aparece su foto (o ícono por defecto)
- Hay un botón de cámara azul en la esquina

### Paso 3️⃣: Toca la foto para editar
- Se abre la vista de edición de perfil
- Aparece su foto actual con opción de cambiar

### Paso 4️⃣: Selecciona nueva foto
- Toca "Cambiar foto de perfil"
- Se abre el selector nativo de fotos
- Selecciona una imagen de su galería

### Paso 5️⃣: Visualiza la foto
- La foto aparece inmediatamente en el círculo
- Se muestra en forma circular con bordes suaves

### Paso 6️⃣: Guarda los cambios
- Toca el botón "Guardar Cambios" al fondo
- Se confirma el guardado (con animación)
- Se cierra la vista automáticamente

### Paso 7️⃣: Foto actualizada
- El header del perfil muestra la foto guardada
- Persiste entre sesiones de la app

## 📱 Componentes de la Interfaz

```
ProfileView (Header)
├── ZStack (Círculo de foto)
│   ├── Gradiente de fondo (verde)
│   ├── Imagen de perfil (si existe)
│   └── Botón de cámara (indicador)
│
EditProfileView
├── ZStack (Foto preview)
│   ├── Foto actual o icono
│   └── Botón cámara
│
└── PhotosPicker
    └── Selector nativo de iOS
```

## 💾 Dónde se Guarda

- **Base de Datos**: UserDefaults
- **Clave**: `userProfileImageData`
- **Formato**: Datos binarios (Data)
- **Persistencia**: Entre sesiones de la app

## 🔑 Código Clave

### En ProfileView
```swift
@State private var profileImage: UIImage?

.onAppear {
    loadProfileImage()
}
```

### En EditProfileView
```swift
@State private var uiImage: UIImage?
@State private var profileImageData: Data?

PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
    Text("Cambiar foto de perfil")
}
```

### Guardado
```swift
if let imageData = profileImageData {
    UserDefaults.standard.set(imageData, forKey: "userProfileImageData")
}
```

## 🎨 Visual Flow

```
┌─────────────────────────────────────┐
│      PROFILE VIEW (Header)          │
│  ┌───────────────────────────────┐  │
│  │                               │  │
│  │      [Foto Perfil] 🎥        │  │
│  │      (Click para editar)      │  │
│  │                               │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
              ↓ Toca
┌─────────────────────────────────────┐
│   EDIT PROFILE VIEW (Modal Sheet)   │
│  ┌───────────────────────────────┐  │
│  │      [Foto Perfil Preview]    │  │
│  │          (100x100)            │  │
│  │                               │  │
│  │  [Cambiar foto de perfil] 🖼️  │  │
│  └───────────────────────────────┘  │
│              ↓ Toca                  │
│  ┌───────────────────────────────┐  │
│  │  PHOTO PICKER (Sistema iOS)   │  │
│  │  Galería → Seleccionar → OK   │  │
│  └───────────────────────────────┘  │
│              ↓ Selecciona            │
│  ┌───────────────────────────────┐  │
│  │   [Nueva Foto Preview]        │  │
│  │   (Se muestra la seleccionada)│  │
│  └───────────────────────────────┘  │
│              ↓ Toca                  │
│  ┌───────────────────────────────┐  │
│  │  [Guardar Cambios] ✅         │  │
│  │  Confirmación guardada        │  │
│  │  Se cierra automáticamente    │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
              ↓ Se cierra
┌─────────────────────────────────────┐
│      PROFILE VIEW (Actualizado)     │
│  ┌───────────────────────────────┐  │
│  │                               │  │
│  │      [Nueva Foto] 📸          │  │
│  │      (¡Guardada!)             │  │
│  │                               │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

## 🔧 Requisitos del Sistema

- iOS 16.0+
- SwiftUI
- PhotosUI Framework
- UserDefaults

## 📋 Permisos Necesarios

**Info.plist:**
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tu galería de fotos para cambiar tu foto de perfil</string>
```

## ❓ FAQs

**P: ¿Dónde se guarda la foto?**
R: En UserDefaults bajo la clave `userProfileImageData`

**P: ¿Puedo editar la foto?**
R: Actualmente no, pero se puede agregar esta funcionalidad

**P: ¿Qué tamaño máximo tiene?**
R: UserDefaults tiene límite de ~5MB, pero se recomienda comprimir imágenes

**P: ¿La foto se sincroniza con Firebase?**
R: No actualmente, solo se guarda localmente

**P: ¿Puedo tomar fotos con la cámara?**
R: No actualmente, solo desde la galería

## 🚀 Próximas Mejoras

1. Captura desde cámara
2. Edición y filtros de imagen
3. Compresión automática
4. Sincronización con Firebase
5. Múltiples fotos de perfil

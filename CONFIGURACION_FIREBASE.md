# 🔥 Configuración de Firebase para SafePath

## ⚡ Guía Rápida de Configuración

### 1️⃣ Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Click en **"Agregar proyecto"**
3. Nombre del proyecto: **SafePath**
4. Acepta los términos y crea el proyecto

---

### 2️⃣ Agregar iOS App

1. En el dashboard del proyecto, click en **iOS** icon
2. Ingresa el **Bundle ID** de tu app:
   - Encontrarlo en Xcode: Target → General → Bundle Identifier
   - Ejemplo: `com.tuempresa.SafePath`
3. **App nickname:** SafePath iOS
4. Descarga el archivo **`GoogleService-Info.plist`**

---

### 3️⃣ Agregar GoogleService-Info.plist a Xcode

1. Arrastra el archivo `GoogleService-Info.plist` a tu proyecto en Xcode
2. ✅ Marca "Copy items if needed"
3. ✅ Selecciona el target "SwiftSafe"
4. El archivo debe quedar en la raíz del proyecto junto a `SwiftSafeApp.swift`

**⚠️ IMPORTANTE:** Este archivo contiene claves de configuración. **NO** lo subas a repositorios públicos.

---

### 4️⃣ Instalar Firebase SDK

#### Usando Swift Package Manager (SPM):

1. En Xcode: **File → Add Package Dependencies...**
2. URL del paquete:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
3. Versión: **Latest**
4. Selecciona los siguientes productos:
   - ✅ **FirebaseAuth**
   - ✅ **FirebaseFirestore**
5. Click en **Add Package**

#### Verificar instalación:
```swift
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
```

---

### 5️⃣ Habilitar Authentication en Firebase Console

1. En Firebase Console, ve a **Build → Authentication**
2. Click en **Get Started**
3. Ve a la pestaña **Sign-in method**
4. Habilita **Email/Password**:
   - Activa el toggle
   - ✅ Email/Password
   - ❌ Email link (sin contraseña) - por ahora no
   - Click en **Save**

---

### 6️⃣ Crear Base de Datos Firestore

1. En Firebase Console, ve a **Build → Firestore Database**
2. Click en **Create database**
3. Selecciona ubicación:
   - **Production mode** (por ahora)
   - Región: `us-central` o la más cercana
4. Click en **Enable**

---

### 7️⃣ Configurar Reglas de Seguridad de Firestore

Ve a **Firestore Database → Rules** y reemplaza con:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Regla para la colección 'users'
    match /users/{userId} {
      // Solo el usuario autenticado puede leer/escribir su propio documento
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Permitir creación de perfil durante el registro
      allow create: if request.auth != null;
    }
    
    // Agregar aquí reglas para otras colecciones (lugares, reseñas, etc.)
    match /places/{placeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      // Solo el autor puede editar/eliminar su reseña
      allow update, delete: if request.auth != null && 
                               request.auth.uid == resource.data.userId;
    }
  }
}
```

Click en **Publish**.

---

### 8️⃣ Personalizar Correo de Verificación (Opcional)

1. Ve a **Authentication → Templates**
2. Selecciona **Email address verification**
3. Click en el **icono de lápiz** para editar
4. Personaliza:
   - **From name:** SafePath
   - **Subject:** Verifica tu cuenta de SafePath
   - **Template:**

```html
<p>Hola,</p>

<p>Gracias por registrarte en <strong>SafePath</strong>.</p>

<p>Para completar tu registro, por favor verifica tu correo dando clic en el siguiente enlace:</p>

<p><a href="%LINK%">Verificar mi correo electrónico</a></p>

<p>Si no creaste esta cuenta, puedes ignorar este mensaje.</p>

<p>¡Bienvenido a SafePath!</p>
<p>El equipo de SafePath</p>
```

5. Click en **Save**

---

### 9️⃣ Configurar URL Actions (Para Links de Verificación)

1. Ve a **Project Settings** (⚙️ icono arriba a la izquierda)
2. Scroll hasta **Authorized domains**
3. Asegúrate que están estos dominios:
   - ✅ `localhost`
   - ✅ Tu dominio custom (si tienes)

---

### 🔟 Verificar Configuración en Xcode

Tu `SwiftSafeApp.swift` debe verse así:

```swift
import SwiftUI
import FirebaseCore

@main
struct SwiftSafeApp: App {
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var appDataManager = AppDataManager()
    
    init() {
        // ✅ Configurar Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if !onboardingManager.hasCompletedOnboarding {
                OnboardingFlowView()
                    .environmentObject(onboardingManager)
                    .environmentObject(authManager)
                    .environmentObject(appDataManager)
            } else {
                AuthGateView()
                    .environmentObject(onboardingManager)
                    .environmentObject(authManager)
                    .environmentObject(appDataManager)
            }
        }
    }
}
```

---

## ✅ Checklist de Configuración

- [ ] Proyecto creado en Firebase Console
- [ ] iOS app agregada al proyecto
- [ ] `GoogleService-Info.plist` descargado
- [ ] Archivo agregado a Xcode
- [ ] Firebase SDK instalado via SPM
- [ ] Email/Password habilitado en Authentication
- [ ] Firestore Database creado
- [ ] Reglas de seguridad configuradas
- [ ] `FirebaseApp.configure()` en SwiftSafeApp.swift
- [ ] Correo de verificación personalizado (opcional)

---

## 🧪 Probar la Configuración

### 1. Compilar el proyecto
```bash
⌘ + B
```

Si no hay errores de compilación, Firebase está correctamente instalado.

### 2. Probar registro de usuario

1. Ejecuta la app en el simulador
2. Ve a la pestaña **"Crear cuenta"**
3. Ingresa:
   - Email: `prueba@ejemplo.com`
   - Contraseña: `password123`
4. Click en **"Registrarme"**

### 3. Verificar en Firebase Console

1. Ve a **Authentication → Users**
2. Deberías ver el usuario creado
3. Verifica que aparezca con el icono de **correo no verificado** ⚠️

### 4. Verificar en Firestore

1. Ve a **Firestore Database → Data**
2. Deberías ver la colección **`users`**
3. Dentro un documento con el UID del usuario
4. Campos: `email`, `createdAt`, `role`, `onboardingCompleted`

---

## 🐛 Solución de Problemas Comunes

### Error: "Failed to configure Firebase"
**Causa:** `GoogleService-Info.plist` no está en el proyecto o está mal ubicado.

**Solución:**
1. Verifica que el archivo esté en la raíz del proyecto
2. Verifica que esté incluido en el target
3. Limpia el build: `⌘ + Shift + K`
4. Reconstruye: `⌘ + B`

---

### Error: "Module 'Firebase...' not found"
**Causa:** El SDK no se instaló correctamente.

**Solución:**
1. Ve a **File → Packages → Resolve Package Versions**
2. Si persiste, elimina el paquete y vuélvelo a agregar
3. Reinicia Xcode

---

### Error: "Email already in use"
**Causa:** El correo ya está registrado (normal en pruebas).

**Solución:**
1. Ve a Firebase Console → Authentication → Users
2. Elimina el usuario de prueba
3. O usa otro correo diferente

---

### No llega el correo de verificación
**Causa:** Puede estar en spam o el servicio de correo tarda.

**Solución:**
1. Revisa carpeta de spam
2. Espera 5-10 minutos
3. Usa el botón "Reenviar correo"
4. Verifica que el correo sea válido

---

## 🔒 Seguridad

### ⚠️ IMPORTANTE - .gitignore

Asegúrate que tu `.gitignore` incluya:

```gitignore
# Firebase
GoogleService-Info.plist
google-services.json

# Xcode
*.xcuserstate
*.xcuserdatad/
DerivedData/
```

---

## 📊 Monitoreo

### Ver logs en Firebase Console

1. **Authentication → Users:** Lista de usuarios registrados
2. **Firestore Database → Data:** Datos almacenados
3. **Project Settings → Usage:** Estadísticas de uso

---

## 🚀 Siguiente Paso

Una vez completada la configuración, puedes:

1. ✅ Probar el flujo completo de registro
2. ✅ Verificar correo desde el email enviado
3. ✅ Iniciar sesión con el usuario verificado
4. ✅ Navegar por la app

---

## 📚 Documentación Oficial

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)

---

**✨ ¡Firebase configurado y listo para usar!**

Ahora tu app SafePath tiene backend completo para autenticación y base de datos. 🔥

# 🔐 Sistema de Autenticación con Verificación de Correo

## 📋 Descripción General

Sistema completo de autenticación implementado en **SafePath** utilizando **Firebase Authentication** con verificación obligatoria de correo electrónico antes de acceder a la aplicación.

---

## 📁 Archivos Creados

### 1. **AuthViewModel.swift**
**Ubicación:** `SwiftSafe/ViewModels/AuthViewModel.swift`

ViewModel principal que gestiona toda la lógica de autenticación:

- ✅ **Registro de usuarios** (`signUp`)
- ✅ **Inicio de sesión** (`signIn`)
- ✅ **Cierre de sesión** (`signOut`)
- ✅ **Verificación de correo** (`checkVerification`)
- ✅ **Reenvío de correo** (`resendVerification`)
- ✅ **Creación de perfil en Firestore**
- ✅ **Manejo de errores localizado**

### 2. **AuthGateView.swift**
**Ubicación:** `SwiftSafe/Views/AuthGateView.swift`

Vista controladora que determina qué pantalla mostrar según el estado del usuario:

- 👤 **No autenticado** → Tabs de Login/Registro
- ⏳ **Autenticado sin verificar** → Pantalla de verificación
- ✅ **Autenticado y verificado** → App principal (MainTabView)

### 3. **SignUpView.swift**
**Ubicación:** `SwiftSafe/Views/SignUpView.swift`

Pantalla de **registro de nuevos usuarios**:
- Campo de correo electrónico
- Campo de contraseña (mínimo 8 caracteres)
- Validación en tiempo real
- Mensaje informativo sobre verificación

### 4. **SignInView.swift**
**Ubicación:** `SwiftSafe/Views/SignInView.swift`

Pantalla de **inicio de sesión**:
- Campo de correo electrónico
- Campo de contraseña
- Validación de campos vacíos
- Manejo de errores (correo no existe, contraseña incorrecta, etc.)

### 5. **VerifyEmailView.swift**
**Ubicación:** `SwiftSafe/Views/VerifyEmailView.swift`

Pantalla de **verificación de correo**:
- ✉️ Icono y mensaje claro
- 🔄 Botón "Ya verifiqué mi correo"
- 📧 Botón "Reenviar correo de verificación"
- 🔀 Botón "Cambiar de cuenta"

---

## 🔄 Flujo de Autenticación

```
┌─────────────────┐
│   App Inicio    │
└────────┬────────┘
         │
         v
    ¿Onboarding?
         │
    ┌────┴────┐
   NO        YES
    │          │
    v          v
┌─────────┐  Completar
│AuthGate │  Onboarding
└────┬────┘
     │
     v
¿Usuario autenticado?
     │
  ┌──┴──┐
 NO    YES
  │     │
  v     v
Tabs   ¿Verificado?
Login    │
Registro ┌─┴─┐
        NO YES
         │  │
         v  v
    Verify Main
    Email  App
```

---

## 🎯 Funcionalidades Implementadas

### ✅ Registro de Usuario
1. Usuario ingresa correo y contraseña (8+ caracteres)
2. Se crea cuenta en Firebase Authentication
3. Se envía correo de verificación automáticamente
4. Se crea perfil básico en Firestore con campos:
   - `email`
   - `createdAt`
   - `role: "user"`
   - `onboardingCompleted: false`

### ✅ Verificación de Correo
- Usuario debe verificar su correo antes de acceder
- Puede **reenviar** el correo si no lo recibió
- Botón "Ya verifiqué" refresca el estado
- Puede **cambiar de cuenta** si se equivocó

### ✅ Inicio de Sesión
- Verifica credenciales con Firebase
- Si el correo no está verificado → envía a pantalla de verificación
- Si está verificado → acceso a la app

### ✅ Manejo de Errores
Mensajes personalizados en español para:
- ❌ Correo ya registrado
- ❌ Correo inválido
- ❌ Contraseña débil
- ❌ Error de red
- ❌ Contraseña incorrecta
- ❌ Usuario no encontrado

---

## 🔧 Configuración Requerida

### 1. Firebase Setup
Asegúrate de tener configurado Firebase en tu proyecto:

```swift
// En SwiftSafeApp.swift
import FirebaseCore

init() {
    FirebaseApp.configure()
}
```

### 2. Agregar Dependencias
En tu `Package.swift` o mediante SPM:
```
https://github.com/firebase/firebase-ios-sdk
```

Selecciona:
- ✅ FirebaseAuth
- ✅ FirebaseFirestore

### 3. Info.plist
No requiere permisos especiales para autenticación básica.

---

## 📝 Uso en el Código

### Inicializar AuthViewModel
```swift
@StateObject private var authVM = AuthViewModel()
```

### Verificar Estado del Usuario
```swift
if let user = authVM.user, user.isEmailVerified {
    // Usuario autenticado y verificado
    MainTabView()
} else {
    // Mostrar login o verificación
    AuthGateView()
}
```

### Cerrar Sesión
```swift
Button("Cerrar sesión") {
    authVM.signOut()
}
```

---

## 🎨 Diseño UI

### Características del Diseño
- ✅ Interfaz moderna con **Forms** de SwiftUI
- ✅ Estados de carga con **ProgressView**
- ✅ Validación en tiempo real
- ✅ Botones deshabilitados cuando corresponde
- ✅ Mensajes de error en rojo
- ✅ Navegación fluida con **NavigationStack**
- ✅ Iconos SF Symbols

### Pantallas
1. **Tabs** (Login/Registro)
2. **Formulario de Registro**
3. **Formulario de Login**
4. **Pantalla de Verificación** (elegante y clara)

---

## 🔐 Seguridad

### Medidas Implementadas
1. ✅ Contraseñas de mínimo 8 caracteres
2. ✅ Verificación de correo obligatoria
3. ✅ No se guardan contraseñas en local
4. ✅ Firebase maneja tokens de sesión
5. ✅ Perfil de usuario en Firestore protegido

### Reglas de Firestore Recomendadas
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Solo el usuario puede leer/escribir su propio perfil
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🚀 Integración con MainTabView

El sistema está diseñado para integrarse con tu `MainTabView` existente:

```swift
// En AuthGateView.swift
if user.isEmailVerified {
    MainTabView()
        .environmentObject(vm)
}
```

Puedes acceder al usuario desde cualquier vista:
```swift
@EnvironmentObject var authVM: AuthViewModel

Text("Bienvenido, \(authVM.user?.email ?? "Usuario")")
```

---

## 📊 Estructura de Datos en Firestore

### Colección: `users`
```json
{
  "uid_del_usuario": {
    "email": "usuario@ejemplo.com",
    "createdAt": Timestamp,
    "role": "user",
    "onboardingCompleted": false
  }
}
```

---

## 🐛 Solución de Problemas

### Problema: No llega el correo de verificación
**Solución:** 
- Verificar que Firebase está configurado correctamente
- Revisar carpeta de spam
- Usar el botón "Reenviar correo"

### Problema: Error al crear usuario
**Solución:**
- Verificar conexión a internet
- Revisar que Firebase está inicializado en `SwiftSafeApp.swift`
- Confirmar que el correo no está registrado previamente

### Problema: Usuario sigue sin verificar después de verificar
**Solución:**
- Presionar el botón "Ya verifiqué mi correo"
- Esto recarga el estado del usuario desde Firebase

---

## 📱 Próximos Pasos (Opcional)

### Mejoras Futuras
- 🔄 Recuperación de contraseña
- 📝 Campos adicionales de perfil (nombre, foto)
- 🔐 Autenticación con Google/Apple
- 👤 Edición de perfil
- 🔔 Notificaciones push

---

## ✅ Checklist de Implementación

- [x] AuthViewModel creado
- [x] Vistas de autenticación creadas
- [x] Integración con SwiftSafeApp
- [x] Flujo de verificación de correo
- [x] Manejo de errores
- [x] Creación de perfil en Firestore
- [ ] Configurar Firebase Console
- [ ] Probar flujo completo
- [ ] Configurar reglas de Firestore
- [ ] Personalizar correo de verificación (opcional)

---

## 📞 Soporte

Si tienes preguntas o problemas con la implementación:
1. Revisa la documentación de Firebase Auth
2. Verifica los logs en Xcode
3. Revisa la consola de Firebase

---

**✨ ¡Sistema de autenticación listo para usar!**

Ahora SafePath tiene un sistema robusto y seguro de autenticación con verificación de correo electrónico. 🎉

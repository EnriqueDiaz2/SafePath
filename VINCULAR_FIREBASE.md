# 🔧 Cómo Vincular Firebase al Proyecto SwiftSafe

## ⚠️ Situación Actual

Firebase **ya está descargado** pero **no está vinculado** al target de tu app. Por eso falla la compilación.

---

## ✅ Solución: Vincular Firebase en Xcode (2 minutos)

### **Paso 1: Abre el Proyecto en Xcode**
Si no está abierto, abre `SwiftSafe.xcodeproj`

---

### **Paso 2: Selecciona el Proyecto**
1. En el panel izquierdo (Navigator), click en **"SwiftSafe"** (el ícono azul del proyecto)
2. Asegúrate de seleccionar el **target "SwiftSafe"** en el panel central

---

### **Paso 3: Ve a "General" Tab**
En la barra superior del editor, selecciona la pestaña **"General"**

---

### **Paso 4: Scroll hasta "Frameworks, Libraries, and Embedded Content"**
Baja hasta encontrar esta sección

---

### **Paso 5: Agrega los Frameworks de Firebase**
1. Click en el botón **"+"** en esa sección
2. En el popup que aparece, busca y agrega:
   - ✅ **FirebaseAuth**
   - ✅ **FirebaseCore**
   - ✅ **FirebaseFirestore**
3. Asegúrate que digan **"Do Not Embed"** en la columna "Embed"

---

### **Paso 6: Limpia y Reconstruye**
1. Menú: **Product → Clean Build Folder** (o `⌘ + Shift + K`)
2. Menú: **Product → Build** (o `⌘ + B`)

---

## 🎯 Alternativamente: Desde Package Dependencies

Si los frameworks no aparecen en el paso 5:

1. Selecciona el proyecto "SwiftSafe"
2. Ve a la pestaña **"Package Dependencies"**
3. Verifica que esté `firebase-ios-sdk`
4. Click en el paquete
5. Ve a la pestaña **"General"** nuevamente
6. En "Frameworks, Libraries...", el botón "+" debería mostrarte los módulos de Firebase

---

## 🔄 Restaurar Archivos de Firebase

Una vez que Firebase esté vinculado correctamente:

```bash
# Restaurar archivos desde backup
mv ~/Documents/SafePath/Firebase_Backup/*.swift ~/Documents/SafePath/SwiftSafe/ViewModels/
mv ~/Documents/SafePath/Firebase_Backup/Auth*.swift ~/Documents/SafePath/SwiftSafe/Views/
mv ~/Documents/SafePath/Firebase_Backup/Sign*.swift ~/Documents/SafePath/SwiftSafe/Views/
mv ~/Documents/SafePath/Firebase_Backup/Verify*.swift ~/Documents/SafePath/SwiftSafe/Views/
```

O arrastra manualmente los archivos de vuelta al proyecto en Xcode.

---

## 📋 Archivos en Backup

Los siguientes archivos están temporalmente en `Firebase_Backup/`:

- ✅ `AuthViewModel.swift`
- ✅ `AuthGateView.swift`
- ✅ `SignUpView.swift`
- ✅ `SignInView.swift`
- ✅ `VerifyEmailView.swift`

---

## ✨ Una Vez Restaurado

Actualiza `SwiftSafeApp.swift` para usar `AuthGateView`:

```swift
import SwiftUI
import FirebaseCore

@main
struct SwiftSafeApp: App {
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var appDataManager = AppDataManager()
    
    init() {
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

## 🎉 Listo!

Tu app debería compilar sin errores ahora y tendrás el sistema de autenticación completo con Firebase.

---

## 📞 ¿Sigues con problemas?

Si los módulos de Firebase no aparecen:

1. Cierra Xcode completamente
2. Elimina `DerivedData`:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/SwiftSafe-*
   ```
3. Abre el proyecto nuevamente
4. **File → Packages → Reset Package Caches**
5. **File → Packages → Resolve Package Versions**
6. Intenta vincular los frameworks nuevamente

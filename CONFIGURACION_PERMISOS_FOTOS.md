# ⚠️ CONFIGURACIÓN REQUERIDA PARA FOTOS

## 📸 Permiso de Biblioteca de Fotos

Para que la funcionalidad de agregar fotos funcione correctamente, necesitas agregar el permiso de acceso a la biblioteca de fotos.

## 🔧 Cómo Configurar (Xcode 14+)

### Opción 1: Mediante Info.plist

1. Abre el proyecto en Xcode
2. Selecciona el archivo **SwiftSafe.xcodeproj**
3. Ve a la pestaña **Info**
4. En "Custom iOS Target Properties"
5. Click en el botón **+** para agregar una nueva propiedad
6. Busca: `Privacy - Photo Library Usage Description`
7. Agrega el valor: `"Necesitamos acceso a tus fotos para que puedas compartir imágenes de lugares"`

### Opción 2: Mediante Target Settings

1. Selecciona el proyecto **SwiftSafe** en el navegador
2. Selecciona el target **SwiftSafe**
3. Ve a la pestaña **Info**
4. En la sección **Custom iOS Target Properties**
5. Agrega:
   - **Key**: `NSPhotoLibraryUsageDescription`
   - **Type**: `String`
   - **Value**: `Necesitamos acceso a tus fotos para que puedas compartir imágenes de lugares`

## 📝 Descripción en Español

```
Necesitamos acceso a tus fotos para que puedas compartir imágenes de lugares
```

## 📝 Descripción en Inglés (si prefieres)

```
We need access to your photos so you can share images of places
```

## 🧪 Verificación

1. Ejecuta la app en el simulador o dispositivo
2. Navega al mapa
3. Haz clic en cualquier lugar
4. Haz clic en "Agregar Foto"
5. **Primera vez**: Verás un diálogo pidiendo permiso
6. Acepta el permiso
7. Se abrirá la biblioteca de fotos

## ⚠️ Si no Agregas el Permiso

Si intentas usar el selector de fotos sin agregar esta descripción:

- ❌ La app se cerrará inesperadamente (crash)
- ❌ Verás un error en la consola de Xcode
- ❌ No se mostrará ningún mensaje al usuario

## ✅ Después de Agregar el Permiso

- ✅ La app solicitará permiso la primera vez
- ✅ El usuario puede aceptar o rechazar
- ✅ Si acepta, podrá seleccionar fotos
- ✅ Si rechaza, la app no cerrará pero no podrá acceder a fotos

## 🔄 Permisos Adicionales (Opcional para Futuro)

Si más adelante quieres agregar la opción de **tomar fotos con la cámara**:

**Key**: `NSCameraUsageDescription`
**Value**: `Necesitamos acceso a tu cámara para tomar fotos de lugares`

## 📱 Simulador vs Dispositivo Real

### Simulador:
- ✅ Puede acceder a fotos de muestra
- ⚠️ Necesitas agregar fotos manualmente (arrastrar imágenes al simulador)

### Dispositivo Real:
- ✅ Accede a la biblioteca completa del usuario
- ✅ El permiso se solicita al usuario real

## 🔍 Cómo Verificar si está Configurado

1. Abre el proyecto en Xcode
2. Selecciona el target **SwiftSafe**
3. Ve a **Info** > **Custom iOS Target Properties**
4. Busca `Privacy - Photo Library Usage Description`
5. Si existe con un valor, ¡está configurado correctamente! ✅

## 📋 Archivo Info.plist (XML)

Si necesitas editar el Info.plist directamente como XML, agrega:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tus fotos para que puedas compartir imágenes de lugares</string>
```

## 🚨 IMPORTANTE

**SIN ESTE PERMISO LA APP SE CERRARÁ AL INTENTAR SELECCIONAR FOTOS**

Asegúrate de agregar esta configuración antes de probar la funcionalidad de fotos.

---

**Status**: ⚠️ Pendiente de configuración en Xcode
**Prioridad**: 🔴 Alta (requerido para funcionalidad de fotos)
**Tiempo estimado**: 1 minuto


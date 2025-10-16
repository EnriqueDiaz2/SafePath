# Funcionalidad de Mapa de Emergencias

## Descripción General

Se ha implementado una nueva funcionalidad de **Mapa de Emergencias** que permite a los usuarios encontrar lugares de emergencia cercanos como hospitales, farmacias, estaciones de policía y bomberos en tiempo real.

## Archivos Modificados y Creados

### 1. **Models.swift** (Modificado)
Se agregaron los siguientes modelos y clases:

#### Modelos Agregados:
- **`EmergencyPlace`**: Estructura que representa un lugar de emergencia con información del MapKit
- **`EmergencyCategory`**: Enumeración con las categorías de emergencia (Hospitales, Farmacias, Policía, Bomberos)
- **`EmergencyLocationManager`**: Gestor de ubicación específico para emergencias
- **`EmergencySearch`**: Clase que busca POIs (Points of Interest) de emergencia usando MapKit
- **`PhoneDialer`**: Helper para realizar llamadas telefónicas

### 2. **EmergencyMapView.swift** (Nuevo)
Vista principal del mapa de emergencias que incluye:

#### Características:
- **Filtros por categoría**: Botones para filtrar por tipo de emergencia
- **Mapa interactivo**: Muestra lugares de emergencia cercanos con anotaciones
- **Ubicación del usuario**: Marca la ubicación actual del usuario
- **Lista de lugares**: Scroll horizontal con los 5 lugares más cercanos
- **Botón de emergencia 911**: Acceso rápido para llamar al 911
- **Búsqueda cercana**: Botón para buscar lugares alrededor de la ubicación actual

#### Componentes:
- **`EmergencyMapView`**: Vista principal del mapa
- **`EmergencyPlaceCard`**: Tarjeta con información del lugar y acciones (llamar, obtener direcciones)

### 3. **HomeView.swift** (Modificado)
Se actualizó el botón "Ver lugares de emergencia" en `EmergencyOptionsView` para navegar a la nueva vista `EmergencyMapView`.

## Flujo de Uso

```
HomeView 
  → Botón "Alertas y emergencias" 
    → EmergencyOptionsView (Sheet)
      → Botones de llamada (911, 065, etc.)
      → Botón "Ver lugares de emergencia"
        → EmergencyMapView (NavigationLink)
          → Mapa con POIs de emergencia
          → Filtros por categoría
          → Acciones (llamar, cómo llegar)
```

## Funcionalidades Principales

### 1. Búsqueda de Lugares de Emergencia
```swift
// Búsqueda automática al aparecer la vista
Task { 
    await searcher.search(
        around: region.center, 
        category: selectedCategory
    ) 
}
```

### 2. Filtrado por Categoría
- **Hospitales** 🏥
- **Farmacias** 💊
- **Policía** 🛡️
- **Bomberos** 🔥

### 3. Acciones Disponibles
- **Llamar**: Si el lugar tiene teléfono, permite realizar una llamada
- **Cómo llegar**: Abre Apple Maps con direcciones en modo conducción
- **Llamada rápida al 911**: Botón de acceso directo

### 4. Visualización en Mapa
- Anotaciones personalizadas con íconos
- Nombres de lugares acortados para mejor visualización
- Controles del mapa (ubicación, brújula, pitch, escala)

## Permisos Requeridos

Asegúrate de tener configurado en `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte lugares de emergencia cercanos</string>
```

## Tecnologías Utilizadas

- **SwiftUI**: Framework de UI
- **MapKit**: Mapas y búsqueda de POIs
- **CoreLocation**: Gestión de ubicación del usuario
- **Async/Await**: Búsqueda asíncrona de lugares

## Mejoras Futuras Sugeridas

1. **Cache de resultados**: Guardar búsquedas previas para acceso offline
2. **Filtros adicionales**: Distancia máxima, abierto ahora, rating
3. **Detalles del lugar**: Vista detallada con horarios, fotos, reseñas
4. **Compartir ubicación**: Enviar ubicación del lugar de emergencia a contactos
5. **Historial**: Guardar lugares visitados o llamados
6. **Notificaciones**: Alertar cuando se está cerca de un lugar guardado
7. **Modo oscuro optimizado**: Mejorar la visualización del mapa en modo oscuro

## Notas de Implementación

- Se renombró `LocationManager` a `EmergencyLocationManager` para evitar conflictos con el LocationManager existente en MapView.swift
- La búsqueda se realiza en un radio de 3.5 km por defecto
- Los resultados se muestran en tiempo real conforme se obtienen de MapKit
- El mapa se centra automáticamente en la ubicación del usuario cuando está disponible

## Testing

Para probar la funcionalidad:

1. Ejecutar la app en un dispositivo físico o simulador
2. Ir a la vista principal (HomeView)
3. Tocar el botón "Alertas y emergencias"
4. Tocar "Ver lugares de emergencia"
5. Permitir el acceso a la ubicación
6. Probar los diferentes filtros de categoría
7. Seleccionar un lugar de la lista
8. Probar las acciones "Llamar" y "Cómo llegar"

## Capturas de Pantalla de Referencia

Basado en los diseños proporcionados:
- Vista de alertas y emergencias con botones de llamada
- Mapa con marcadores de lugares guardados y cercanos
- Vista principal con acceso a chat social y alertas

---

**Fecha de implementación**: 16 de octubre de 2025  
**Versión**: 1.0

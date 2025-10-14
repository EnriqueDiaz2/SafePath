# 📱 Guía Visual de MapView - SwiftSafe

## 🎯 Vista Principal del Mapa

```
┌─────────────────────────────────────────┐
│  [🔍 Buscar ubicaciones...  ] [⚙️]     │  ← Barra de búsqueda + Filtros
├─────────────────────────────────────────┤
│                                         │
│        🗺️  MAPA INTERACTIVO             │
│                                         │
│     📍 ← Marcadores de lugares          │
│        📍                               │
│           📍                            │
│                                         │
│  [📍]                          [🔵 +]  │  ← Ubicación / Agregar
│                                         │
├─────────────────────────────────────────┤
│  ══════  Lugares Guardados (5)          │
│  ┌───┐ ┌───┐ ┌───┐                     │  ← Panel deslizable
│  │📍 │ │📍 │ │📍 │  ← Tarjetas         │
│  └───┘ └───┘ └───┘                     │
└─────────────────────────────────────────┘
```

## 🔍 Modo de Búsqueda Activa

```
┌─────────────────────────────────────────┐
│  [🔍 Hospital        × ] [⚙️]          │  ← Búsqueda activa
│  🔵 2 resultado(s) encontrado(s)        │  ← Contador de resultados
├─────────────────────────────────────────┤
│                                         │
│        🗺️  MAPA INTERACTIVO             │
│                                         │
│     📍 Hospital Central ✓               │  ← Solo lugares filtrados
│                                         │
│        📍 Hospital San José ✓           │
│                                         │
│                                         │
│  [📍]                          [🔵 +]  │
├─────────────────────────────────────────┤
│  ══════  Lugares Guardados (2)          │  ← Resultados filtrados
│  📍 Hospital Central                    │
│  📍 Hospital San José                   │
└─────────────────────────────────────────┘
```

## ➕ Modo de Selección de Ubicación

```
┌─────────────────────────────────────────┐
│  👉 Mueve el mapa para seleccionar      │  ← Banner de instrucciones
├─────────────────────────────────────────┤
│                                         │
│                                         │
│                                         │
│              🗺️                         │
│                 📍                      │  ← Pin azul centrado
│              UBICACIÓN                  │
│                                         │
│                                         │
│  [📍]                  [✓] [✗]         │  ← Confirmar / Cancelar
│                                         │
└─────────────────────────────────────────┘
              (Panel oculto)
```

## 💾 Modal de Guardar Ubicación

```
┌─────────────────────────────────────────┐
│  Cancelar    Nueva Ubicación            │
├─────────────────────────────────────────┤
│                                         │
│  INFORMACIÓN DEL LUGAR                  │
│  ┌───────────────────────────────────┐ │
│  │ Nombre del lugar *               │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ Descripción (opcional)           │ │
│  └───────────────────────────────────┘ │
│                                         │
│  COORDENADAS                            │
│  Latitud:     20.6737                   │
│  Longitud:  -103.3444                   │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │      Guardar Ubicación           │ │  ← Botón principal
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## 🎬 Flujo de Trabajo

### Agregar Nueva Ubicación
```
1. Usuario presiona [+]
   ↓
2. Aparece pin azul en centro + banner de instrucciones
   ↓
3. Usuario mueve el mapa
   ↓
4. Usuario presiona [✓] para confirmar
   ↓
5. Aparece modal de guardado
   ↓
6. Usuario ingresa nombre y descripción
   ↓
7. Usuario presiona "Guardar Ubicación"
   ↓
8. ✅ Nuevo marcador aparece en el mapa
```

### Buscar Lugares
```
1. Usuario escribe en barra de búsqueda
   ↓
2. Los marcadores se filtran en tiempo real
   ↓
3. Aparece contador de resultados
   ↓
4. Panel inferior muestra solo coincidencias
   ↓
5. Usuario presiona [×] para limpiar
   ↓
6. ✅ Se muestran todos los lugares nuevamente
```

## 🎨 Código de Colores

- 🔵 **Azul**: Acciones principales (agregar, ubicación seleccionada)
- ✅ **Verde**: Confirmación (guardar, confirmar ubicación)
- ❌ **Rojo**: Cancelación (cancelar selección)
- ⚪ **Blanco**: Controles secundarios (ubicación actual, opciones de mapa)
- 🟦 **Azul claro**: Información (banner de instrucciones, contador de resultados)

## 📱 Estados de la Interfaz

| Estado | Barra de Búsqueda | Panel de Lugares | Botón Principal | Pin Central |
|--------|-------------------|------------------|-----------------|-------------|
| Normal | ✅ Visible | ✅ Visible | 🔵 + | ❌ Oculto |
| Búsqueda | ✅ Activa + Contador | ✅ Filtrado | 🔵 + | ❌ Oculto |
| Selección | ❌ Oculta | ❌ Oculto | ✓ ✗ | ✅ Visible |
| Guardando | ❌ Oculta | ❌ Oculto | Modal activo | ❌ Oculto |

## ⚡ Atajos y Tips

- **Búsqueda rápida**: La búsqueda filtra por nombre Y descripción
- **Limpiar búsqueda**: Presiona la X o borra todo el texto
- **Cancelar selección**: Presiona ESC o el botón rojo con ✗
- **Ver detalles**: Toca cualquier marcador 📍 en el mapa
- **Ubicación actual**: Presiona el botón 📍 para centrar el mapa

## 🔄 Animaciones

- ✨ Transición suave al entrar/salir del modo selección
- ✨ Fade in/out del banner de instrucciones
- ✨ Slide del contador de resultados
- ✨ Zoom suave al centrar en ubicación

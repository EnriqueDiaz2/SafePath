# 🚀 Guía Rápida - Mapa de Emergencias

## ⚡ Inicio Rápido

### 1️⃣ Compilar y Ejecutar
```bash
# Abrir el proyecto en Xcode
cd /Users/MacOsLab/Documents/SafePath
open SwiftSafe.xcodeproj

# Seleccionar un simulador (iPhone 15 Pro recomendado)
# Presionar Cmd + R para ejecutar
```

### 2️⃣ Navegar a la Funcionalidad
1. La app se abre en la pantalla principal
2. Toca el botón **"Alertas y emergencias"** (ícono rojo de alerta)
3. Se abre un sheet con opciones de emergencia
4. Toca **"Ver lugares de emergencia"** (botón inferior)
5. ¡Explora el mapa de emergencias! 🗺️

---

## 🎯 Características Principales

### Filtros de Categoría
Toca cualquier categoría para buscar lugares específicos:
- 🏥 **Hospitales** - Encuentra hospitales cercanos
- 💊 **Farmacias** - Encuentra farmacias 24h
- 🛡️ **Policía** - Encuentra estaciones de policía
- 🔥 **Bomberos** - Encuentra estaciones de bomberos

### Acciones Rápidas

#### 📞 Llamar al 911
- Botón rojo en la parte inferior derecha
- Toca para llamar inmediatamente

#### 🔍 Buscar Cerca
- Botón en la parte inferior izquierda
- Busca lugares de la categoría seleccionada alrededor de tu ubicación

#### 📍 Ver Detalles de un Lugar
- Toca cualquier tarjeta en la lista horizontal
- **Llamar**: Llama directamente al lugar (si tiene teléfono)
- **Cómo llegar**: Abre Apple Maps con direcciones

---

## 🗺️ Controles del Mapa

| Control | Ubicación | Función |
|---------|-----------|---------|
| 📍 **Mi Ubicación** | Superior derecha | Centra el mapa en tu ubicación |
| 🧭 **Brújula** | Superior derecha | Muestra orientación del mapa |
| 📐 **Pitch** | Superior derecha | Cambia ángulo de vista 3D |
| 📏 **Escala** | Superior izquierda | Muestra escala del mapa |

---

## 📱 Permisos

### Primera Vez
Al abrir el mapa por primera vez, la app pedirá:

**"SafePath quiere acceder a tu ubicación"**

Opciones:
- ✅ **Permitir mientras uso la app** ← Recomendado
- ⚠️ **Permitir una vez** (tendrás que dar permiso cada vez)
- ❌ **No permitir** (no verás tu ubicación en el mapa)

### Si Denegaste el Permiso
1. Ve a **Ajustes** del iPhone
2. Busca **SafePath**
3. Toca **Ubicación**
4. Selecciona **Mientras se usa la app**

---

## 🎨 Interfaz Visual

```
┌─────────────────────────────────────────┐
│ [🏥] [💊] [🛡️] [🔥]                    │ ← Filtros
├─────────────────────────────────────────┤
│                                         │
│         🗺️ MAPA INTERACTIVO             │
│                                         │
│    📍 Lugar 1    📍 Lugar 2            │
│         📍 TÚ                           │
│    📍 Lugar 3                           │
│                                         │
├─────────────────────────────────────────┤
│ [🔍 Buscar cerca]      [📞 911]        │ ← Acciones rápidas
├─────────────────────────────────────────┤
│ ◄ [Card 1] [Card 2] [Card 3] ►        │ ← Lista horizontal
│    Hospital  Farmacia  Policía         │
└─────────────────────────────────────────┘
```

---

## 🔥 Casos de Uso Comunes

### Emergencia Médica
1. Abre el mapa de emergencias
2. Filtra por 🏥 **Hospitales**
3. Ve el más cercano en la lista
4. Toca **"Cómo llegar"**
5. Apple Maps te guía con indicaciones en tiempo real

### Necesitas una Farmacia de Guardia
1. Abre el mapa de emergencias
2. Filtra por 💊 **Farmacias**
3. Ve la lista de farmacias cercanas
4. Si tiene teléfono, toca **"Llamar"** para preguntar si tienen lo que necesitas
5. Luego toca **"Cómo llegar"**

### Reportar una Emergencia
1. Abre el mapa de emergencias
2. Toca el botón **📞 911** (rojo, esquina inferior derecha)
3. Confirma la llamada
4. Mientras esperas, puedes ver los lugares de emergencia cercanos

---

## 💡 Tips y Trucos

### ⚡ Tip 1: Búsqueda Rápida
No necesitas escribir nada. Solo toca un filtro y la búsqueda es automática.

### ⚡ Tip 2: Actualizar Resultados
Si te moviste de ubicación:
1. Toca el botón de **Mi Ubicación** 📍
2. Luego toca **🔍 Buscar cerca**
3. Los resultados se actualizan para tu nueva ubicación

### ⚡ Tip 3: Ver Más Detalles
Desliza horizontalmente en la lista de lugares para ver más opciones (muestra 5 lugares a la vez).

### ⚡ Tip 4: Zoom Manual
- **Pellizcar** para hacer zoom
- **Arrastrar con dos dedos** para inclinar el mapa
- **Rotar con dos dedos** para cambiar orientación

---

## ⚠️ Solución de Problemas

### No Veo Mi Ubicación
**Causa**: Permisos no otorgados  
**Solución**: Ir a Ajustes → SafePath → Ubicación → "Mientras se usa la app"

### No Aparecen Lugares
**Causa**: No hay lugares de esa categoría cerca o sin conexión  
**Solución**: 
- Prueba con otra categoría
- Verifica tu conexión a internet
- Intenta hacer zoom out en el mapa

### El Botón "Llamar" No Funciona
**Causa**: Probablemente estás en un simulador  
**Solución**: Las llamadas solo funcionan en dispositivos físicos

### El Mapa No Carga
**Causa**: Sin conexión a internet  
**Solución**: Conecta a WiFi o datos móviles. MapKit requiere conexión.

---

## 📊 Información Técnica

| Característica | Valor |
|----------------|-------|
| Radio de búsqueda | 3.5 km |
| Máximo de resultados | ~50 lugares |
| Actualización de ubicación | En tiempo real |
| Precisión de ubicación | Alta (kCLLocationAccuracyBest) |
| Categorías disponibles | 4 |
| Compatibilidad | iOS 17.0+ |

---

## 🆘 Números de Emergencia Disponibles

Desde la vista "Alertas y emergencias":

| Servicio | Número | Botón |
|----------|--------|-------|
| Emergencias | 911 | 📞 911 |
| Cruz Roja | 065 | 🚑 065 |
| Línea de la vida | 800-911-2000 | ❤️ |
| Línea de la mujer | 800-108-4053 | 👤 |
| Denuncia anónima | 089 | 📞 089 |
| PROFECO | 800-468-8722 | 🛡️ |

---

## 📖 Documentación Adicional

Para información más detallada, consulta:

- 📄 `FUNCIONALIDAD_MAPA_EMERGENCIAS.md` - Documentación técnica completa
- 📄 `RESUMEN_MAPA_EMERGENCIAS.md` - Diagramas y arquitectura
- 📄 `EJEMPLOS_CODIGO_EMERGENCIAS.md` - Ejemplos de código
- 📄 `CORRECCIONES_ERRORES.md` - Detalles de correcciones aplicadas

---

## ✅ Checklist de Verificación

Antes de usar en producción, verifica:

- [ ] Permisos de ubicación configurados
- [ ] Info.plist tiene NSLocationWhenInUseUsageDescription
- [ ] La app compila sin errores
- [ ] Probado en dispositivo físico (no solo simulador)
- [ ] Búsqueda funciona para todas las categorías
- [ ] Botones de acción funcionan correctamente
- [ ] El mapa carga correctamente
- [ ] La ubicación del usuario se muestra

---

## 🎓 Tutorial en Video (Conceptual)

1. **Introducción** (0:00-0:30)
   - Pantalla principal
   - Botón de alertas y emergencias

2. **Acceso al Mapa** (0:30-1:00)
   - Abrir sheet de emergencias
   - Tocar "Ver lugares de emergencia"
   - Conceder permisos de ubicación

3. **Uso de Filtros** (1:00-2:00)
   - Seleccionar cada categoría
   - Ver cómo cambian los resultados
   - Interpretación de iconos

4. **Acciones** (2:00-3:00)
   - Llamar a un lugar
   - Obtener direcciones
   - Usar botón 911

5. **Tips Avanzados** (3:00-4:00)
   - Controles del mapa
   - Actualizar búsqueda
   - Zoom y navegación

---

**¡Listo para usar! 🎉**

La funcionalidad está completamente operativa y lista para ayudar en situaciones de emergencia.

---

**Última actualización**: 16 de octubre de 2025  
**Versión**: 1.0  
**Soporte**: Consulta la documentación técnica para más detalles

# EuroCoinDex 📱🪙

App Android para coleccionistas de monedas de euro. Funciona como un álbum digital donde puedes:

- 🗂️ Explorar monedas por país, valor, año o serie
- ✅ Marcar las monedas que posees
- 🔍 Buscar por valor, país, año o tema
- 📤 Exportar e importar tu colección
- 🔄 Actualizar el catálogo sin reinstalar la app

---

## 🛠️ Cómo compilar la app (paso a paso)

### 1. Instalar herramientas (solo la primera vez)

#### a) Instalar Flutter
1. Ve a [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows/android)
2. Descarga Flutter SDK y descomprímelo en `C:\flutter`
3. Añade `C:\flutter\bin` a la variable de entorno PATH
4. Ejecuta en PowerShell: `flutter doctor`

#### b) Instalar Android Studio
1. Descarga desde [developer.android.com/studio](https://developer.android.com/studio)
2. Instala el Android SDK (lo hace automáticamente)
3. En Android Studio > SDK Manager: instala Android 14 (API 34)

### 2. Preparar el código

1. Descarga o clona este repositorio
2. Abre una terminal en la carpeta `eurocoindex/`
3. Ejecuta: `flutter pub get`

### 3. Compilar el APK

```bash
# APK de prueba (para instalar directamente)
flutter build apk --release

# El APK se genera en:
# build/app/outputs/flutter-apk/app-release.apk
```

### 4. Instalar en tu teléfono

**Opción A (recomendada):** Conecta el teléfono por USB
- Activa "Depuración USB" en las opciones de desarrollador
- Ejecuta: `flutter install`

**Opción B:** Copia el APK al teléfono y ábrelo
- Necesitarás permitir "Instalar apps de fuentes desconocidas"

---

## 🔄 Actualizar el catálogo (GitHub)

Cuando quieras añadir nuevas monedas:

1. Edita `data/coins.csv` añadiendo las nuevas filas
2. Añade las imágenes en `assets/coins/`
3. En GitHub Desktop (o la web de GitHub):
   - Sube los archivos modificados
   - Haz commit con el mensaje "Actualización: [descripción]"
4. ¡Listo! La app descarga los cambios automáticamente

---

## 📂 Estructura del proyecto

```
eurocoindex/          ← Código de la app Flutter
├── lib/
│   ├── main.dart            ← Punto de entrada
│   ├── models/              ← Modelos de datos
│   ├── services/            ← Lógica de negocio
│   ├── providers/           ← Gestión de estado
│   ├── screens/             ← Pantallas
│   ├── widgets/             ← Componentes reutilizables
│   └── theme/               ← Temas claro/oscuro
└── pubspec.yaml             ← Dependencias

data/                 ← Base de datos (actualizable)
└── coins.csv

assets/               ← Imágenes (actualizables)
├── coins/
├── flags/
└── values/
```

---

## 🆕 Campos futuros del CSV

Cuando tengas listos los nuevos campos, simplemente añádelos al CSV:
- `subtag` - Subcategoría temática
- `coincidencia` - Relación con otras monedas
- `motivoES` - Motivo de la emisión en español

La app los mostrará automáticamente en la ficha de cada moneda.

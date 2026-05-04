# 📱 EuroCoinDex — Guía de instalación completa

## ¿Qué hay en este ZIP?

```
eurocoindex_completo/
├── 📁 lib/                    ← Código de la app
├── 📁 android/                ← Configuración Android
├── 📁 assets/                 ← Imágenes de monedas, banderas y valores
├── 📁 data/                   ← Base de datos CSV (coins.csv)
├── 📄 pubspec.yaml            ← Lista de dependencias
└── 📄 README.md               ← Instrucciones del proyecto
```

---

## PARTE 1: Subir todo a GitHub (hazlo primero)

### Paso 1 — Crear el repositorio en GitHub

1. Ve a [github.com](https://github.com) e inicia sesión con tu cuenta **16Pablo**
2. Pulsa el botón verde **"New"** (arriba a la izquierda)
3. Rellena:
   - **Repository name:** `eurocoindex`
   - **Visibility:** Public ✅ (necesario para que la app descargue las imágenes gratis)
   - **NO** marques ninguna casilla adicional
4. Pulsa **"Create repository"**

### Paso 2 — Instalar GitHub Desktop

1. Descarga **GitHub Desktop** desde [desktop.github.com](https://desktop.github.com)
2. Instálalo e inicia sesión con tu cuenta **16Pablo**

### Paso 3 — Subir los archivos

1. Descomprime el ZIP que te entregué en una carpeta, por ejemplo `C:\EuroCoinDex\`
2. En GitHub Desktop: **File → Add local repository**
3. Selecciona la carpeta `C:\EuroCoinDex\`
4. Si pregunta si quieres inicializar el repositorio, acepta
5. En la barra izquierda verás todos los archivos listos para subir
6. Escribe en "Summary": `Primera versión` y pulsa **"Commit to main"**
7. Luego pulsa **"Publish repository"**
   - Asegúrate de que esté marcado como **Public**
   - Pulsa **"Publish repository"**

⏳ *La subida tardará unos minutos porque hay ~900 imágenes (31 MB)*

### Paso 4 — Verificar que funciona

Abre esta URL en el navegador (debería mostrarte el CSV en texto):
```
https://raw.githubusercontent.com/16Pablo/eurocoindex/main/data/coins.csv
```
Si ves texto con datos de monedas, ¡todo está correcto!

---

## PARTE 2: Compilar la app

### Paso 1 — Instalar Flutter

1. Ve a [docs.flutter.dev/get-started/install/windows/android](https://docs.flutter.dev/get-started/install/windows/android)
2. Descarga el ZIP de Flutter SDK (unos 500 MB)
3. Descomprímelo en `C:\flutter\` (sin espacios en la ruta)
4. Añade `C:\flutter\bin` al PATH de Windows:
   - Busca "variables de entorno" en el menú Inicio
   - En "Variables del sistema" → `Path` → Editar → Nuevo → escribe `C:\flutter\bin`
   - Acepta todo
5. Abre **PowerShell** y ejecuta: `flutter doctor`
   - Verás un informe de lo que falta instalar

### Paso 2 — Instalar Android Studio

1. Descarga desde [developer.android.com/studio](https://developer.android.com/studio)
2. Instala con las opciones por defecto
3. Al abrirlo por primera vez, sigue el asistente de configuración
4. En **SDK Manager** (icono de tuerca): instala **Android 14 (API 34)**
5. Acepta las licencias de Android ejecutando:
   ```
   flutter doctor --android-licenses
   ```
   Escribe `y` y Enter en cada pregunta

### Paso 3 — Compilar el APK

1. Abre **PowerShell** en la carpeta `C:\EuroCoinDex\`
   (shift + clic derecho en la carpeta → "Abrir ventana de PowerShell aquí")
2. Ejecuta:
   ```
   flutter pub get
   ```
   (descarga las dependencias, puede tardar 2-3 minutos)
3. Luego:
   ```
   flutter build apk --release
   ```
   (compila la app, puede tardar 5-10 minutos la primera vez)
4. El APK estará en:
   ```
   C:\EuroCoinDex\build\app\outputs\flutter-apk\app-release.apk
   ```

### Paso 4 — Instalar en tu teléfono

**Método más fácil — Cable USB:**
1. En tu teléfono: Ajustes → Acerca del teléfono → pulsa 7 veces en "Número de compilación"
2. Aparecen las "Opciones de desarrollador" → activa "Depuración USB"
3. Conecta el teléfono al PC con USB
4. En PowerShell ejecuta: `flutter install`

**Método alternativo — Copiar el APK:**
1. Copia `app-release.apk` al teléfono
2. En el teléfono: Ajustes → Seguridad → activa "Fuentes desconocidas"
3. Abre el APK desde el explorador de archivos y pulsa Instalar

---

## PARTE 3: Actualizar el catálogo (para añadir nuevas monedas)

Cuando haya nuevas emisiones y quieras añadirlas:

1. Edita `data/coins.csv` con Excel (ábrelo como texto UTF-8 con coma como separador)
2. Añade las nuevas filas al final
3. Guarda las nuevas imágenes en `assets/coins/`
4. Abre **GitHub Desktop**, verás los cambios
5. Escribe un mensaje como "Añadidas monedas 2025" y pulsa **Commit**
6. Pulsa **Push origin**

La próxima vez que cualquier usuario abra la app, se descargará el catálogo actualizado automáticamente.

---

## ❓ Problemas frecuentes

| Problema | Solución |
|----------|----------|
| `flutter: command not found` | Revisa que añadiste `C:\flutter\bin` al PATH y reinicia PowerShell |
| `Android SDK not found` | Ejecuta `flutter doctor` y sigue las instrucciones |
| El APK no se instala | Activa "Fuentes desconocidas" en los ajustes del teléfono |
| La app no carga monedas | Verifica que el repositorio GitHub es **Public** |
| Imágenes no aparecen | Espera a que GitHub procese los archivos (puede tardar 1-2 min tras un push) |

---

## 📬 Campos pendientes del CSV

Cuando tengas listos los campos `subtag`, `coincidencia` y `motivoES`, simplemente:
1. Añádelos como nuevas columnas al CSV
2. Súbelo a GitHub
3. La app los mostrará automáticamente en la ficha de cada moneda

---

*EuroCoinDex — Creado con Flutter · Código abierto · Sin anuncios · Sin coste*

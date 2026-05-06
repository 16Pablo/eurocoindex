# EuroCoinDex 📱🪙

App Android para coleccionistas de monedas de euro. Funciona como un álbum digital donde puedes:

- 🗂️ Explorar monedas por país, valor, año o serie
- ✅ Marcar las monedas que posees
- 🔍 Buscar por valor, país, año o tema
- 📤 Exportar e importar tu colección

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

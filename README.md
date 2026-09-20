# LogicLab

Aplicación móvil desarrollada con **Flutter** para la gestión de pedidos, consulta de pedidos en cocina y visualización de estadísticas para administradores.

## 📱 Descripción

**LogicLab** es una aplicación orientada a la gestión de pedidos de un establecimiento.

La aplicación permite a los usuarios autenticarse y realizar diferentes operaciones dependiendo de su rol.

La **versión 1** contempla las siguientes funcionalidades principales:

* Inicio de sesión.
* Gestión y creación de pedidos.
* Consulta de pedidos para cocina.
* Consulta de estadísticas para administradores.
* Manejo de usuarios según su rol.

---

## 🚀 Versión

**Versión actual:** `1.0.0`

### Tecnologías principales

| Tecnología  | Versión  |
| ----------- | -------- |
| Flutter     | `3.47.5` |
| Dart        | `3.13.4` |
| Android SDK | `36+`    |
| Android     | API 37   |
| Lenguaje    | Dart     |

> Las versiones de las dependencias pueden evolucionar durante el desarrollo del proyecto.

---

## 📦 Librerías

Las principales dependencias utilizadas por el proyecto se gestionan mediante `pubspec.yaml`.

Entre las categorías de librerías utilizadas o previstas se encuentran:

* **Flutter SDK** — desarrollo de la aplicación.
* **Material** — componentes visuales.
* **HTTP / cliente API** — comunicación con el backend.
* **Gestión de estado** — administración del estado de la aplicación.
* **Persistencia local** — almacenamiento de información necesaria en el dispositivo.
* **Serialización JSON** — transformación de datos entre la aplicación y el backend.

Las versiones exactas de las dependencias deben consultarse directamente en:

```text
pubspec.yaml
```

---

## 🏗️ Funcionalidades — Versión 1

### 🔐 Login

Permite a los usuarios autenticarse en la aplicación.

Funcionalidades:

* Inicio de sesión.
* Validación de credenciales.
* Manejo de sesión.
* Control de acceso según rol.
* Cierre de sesión.

---

### 🛒 Pedidos

Permite gestionar los pedidos realizados por los usuarios.

Funcionalidades principales:

* Crear un pedido.
* Agregar productos al pedido.
* Consultar información del pedido.
* Consultar estado del pedido.
* Enviar pedido a cocina.

Flujo general:

```text
Usuario
   │
   ▼
Crear pedido
   │
   ▼
Agregar productos
   │
   ▼
Confirmar pedido
   │
   ▼
Cocina
```

---

### 👨‍🍳 Pedidos de cocina

Los usuarios encargados de cocina pueden consultar los pedidos pendientes de preparación.

Funcionalidades:

* Visualizar pedidos pendientes.
* Consultar productos del pedido.
* Consultar información relevante del pedido.
* Actualizar el estado del pedido.
* Identificar pedidos preparados.

Flujo:

```text
Pedido confirmado
       │
       ▼
     Cocina
       │
       ▼
Preparando
       │
       ▼
   Preparado
```

---

### 📊 Estadísticas

Los usuarios con permisos de administrador pueden consultar información estadística relacionada con los pedidos.

Las estadísticas pueden incluir:

* Cantidad de pedidos.
* Pedidos por estado.
* Productos más solicitados.
* Ventas.
* Pedidos por período.
* Información general del negocio.

La información estará disponible mediante diferentes indicadores y visualizaciones.

---

## 👥 Roles

La aplicación contempla inicialmente diferentes tipos de usuario.

### Usuario

Puede:

* Iniciar sesión.
* Crear pedidos.
* Consultar sus pedidos.
* Consultar el estado de sus pedidos.

### Cocina

Puede:

* Iniciar sesión.
* Consultar pedidos.
* Gestionar el estado de preparación.
* Marcar pedidos como preparados.

### Administrador

Puede:

* Iniciar sesión.
* Consultar información general.
* Consultar estadísticas.
* Visualizar información de pedidos.

---

## 📂 Estructura inicial

La estructura puede organizarse de la siguiente manera:

```text
lib/
├── main.dart
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── routes/
│   └── utils/
│
├── models/
│
├── services/
│
├── repositories/
│
├── screens/
│   ├── login/
│   ├── orders/
│   ├── kitchen/
│   └── statistics/
│
├── widgets/
│
└── providers/
```

La estructura puede evolucionar conforme aumente la complejidad de la aplicación.

---

## ▶️ Ejecución del proyecto

### Requisitos

Antes de ejecutar el proyecto es necesario tener instalado:

* Flutter.
* Dart.
* Android SDK.
* Android Emulator o dispositivo Android.
* Git.

Verificar la instalación:

```bash
flutter doctor
```

---

### Instalar dependencias

Desde la raíz del proyecto:

```bash
flutter pub get
```

---

### Ejecutar en Android

Verificar los dispositivos disponibles:

```bash
flutter devices
```

Ejecutar la aplicación:

```bash
flutter run
```

También se puede especificar un dispositivo:

```bash
flutter run -d emulator-5554
```

---

### Ejecutar en Chrome

```bash
flutter run -d chrome
```

---

## 🧪 Pruebas

Las pruebas automatizadas se encuentran dentro de:

```text
test/
```

Ejecutar todas las pruebas:

```bash
flutter test
```

---

## 🔧 Desarrollo

Durante el desarrollo se recomienda utilizar **Hot Reload** para visualizar rápidamente los cambios realizados en la aplicación.

Durante una ejecución con:

```bash
flutter run
```

se puede utilizar:

```text
r
```

para realizar Hot Reload.

---

## 🔄 Flujo general de la aplicación

```text
                    ┌──────────────┐
                    │    Login     │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    Usuario   │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │   Pedidos    │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    Cocina    │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Preparado   │
                    └──────────────┘


                    ┌──────────────┐
                    │Administrador │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ Estadísticas │
                    └──────────────┘
```

---

## 📌 Roadmap — V1

* [x] Configuración inicial de Flutter.
* [ ] Login.
* [ ] Manejo de sesión.
* [ ] Gestión de pedidos.
* [ ] Vista de pedidos para cocina.
* [ ] Actualización de estados.
* [ ] Estadísticas para administrador.
* [ ] Pruebas automatizadas.
* [ ] Validación de permisos por rol.

---

## 📄 Licencia

Proyecto privado.

La distribución, modificación y uso del código están sujetos a las condiciones definidas por los responsables del proyecto.

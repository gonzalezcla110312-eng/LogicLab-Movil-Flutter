# LogicLab - Aplicación Móvil Flutter

Aplicación móvil del sistema **LogicLab**, desarrollada con Flutter para permitir el acceso desde dispositivos Android al sistema de gestión de un restaurante.

La aplicación móvil está construida con Flutter y Dart. Sus pantallas de acceso, menú, cocina, pedidos y PQRS se implementan de forma nativa y consumen la API REST del backend. El frontend React para navegador permanece separado y sin cambios.

---

## Descripción

**LogicLab** es un sistema de gestión para restaurantes que permite administrar diferentes procesos del establecimiento desde una aplicación web y móvil.

La aplicación móvil permite acceder al sistema LogicLab desde un dispositivo Android y utilizar las funcionalidades disponibles para cada usuario según su rol.

### Funcionalidades principales

- Inicio de sesión
- Gestión de usuarios y roles
- Gestión de pedidos
- Consulta y gestión de pedidos en cocina
- Dashboard administrativo
- Consulta de ganancias
- Gestión de platos y menús
- Gestión de mesas
- Gestión de reservaciones
- Gestión de PQRS
- Persistencia de información en MySQL

---

## Arquitectura

El sistema está compuesto por tres partes principales:

```text
┌─────────────────────────────┐
│      Aplicación Flutter     │
│   Interfaz nativa en Dart   │
└──────────────┬──────────────┘
               │ HTTP / REST API
               ▼
┌─────────────────────────────┐
│       Backend Node.js       │
│          Express            │
└──────────────┬──────────────┘
               │
               │ MySQL
               ▼
┌─────────────────────────────┐
│        Base de datos        │
│          LogicLab           │
└─────────────────────────────┘
```

El frontend React para navegador también consume la API del backend, pero la aplicación Android no depende de un WebView para mostrar sus pantallas.

---

## Aplicación Flutter

La aplicación móvil está desarrollada utilizando:

- Flutter
- Dart
- Dio para las solicitudes HTTP a la API REST
- Android SDK

La aplicación se comunica directamente con el backend mediante la URL configurada con `API_URL`.

---

## Tecnologías

| Tecnología | Uso |
|---|---|
| Flutter | Aplicación móvil |
| Dart | Lenguaje de programación |
| Dio | Consumo de la API REST desde Flutter |
| React | Frontend |
| Vite | Servidor de desarrollo del frontend |
| Node.js | Backend |
| Express | API REST |
| MySQL | Base de datos |
| Git / GitHub | Control de versiones |

---

## Versión

### Flutter

- Flutter: `3.47.5`
- Dart: `3.13.4`

### Android

La aplicación fue probada en:

- Android 15
- API 35

---

## Módulo de reservaciones

El sistema cuenta con un módulo de reservaciones conectado al backend y a MySQL.

Permite:

- Crear reservaciones
- Consultar reservaciones
- Modificar reservaciones
- Confirmar reservaciones
- Cancelar reservaciones
- Marcar reservaciones como atendidas
- Seleccionar mesa
- Registrar fecha y hora
- Registrar número de personas
- Registrar información del cliente
- Registrar observaciones
- Validar disponibilidad de mesas

Las reservaciones se almacenan en la tabla:

```text
reservaciones
```

de la base de datos:

```text
LogicLab
```

---

## Ejecución del proyecto

### Requisitos

Se necesita tener instalado:

- Flutter
- Dart
- Android Studio
- Android SDK
- Git
- Un dispositivo Android o emulador

### Comprobar Flutter

```bash
flutter doctor
```

### Instalar dependencias

Desde la carpeta raíz:

```bash
flutter pub get
```

### Ver dispositivos disponibles

```bash
flutter devices
```

### Ejecutar la aplicación

```bash
flutter run
```

También se puede especificar un dispositivo:

```bash
flutter run -d <ID_DEL_DISPOSITIVO>
```

Ejemplo:

```bash
flutter run -d A34XUT5610001877
```

---

## Configuración de red

Durante el desarrollo, el dispositivo Android y el computador deben encontrarse en la misma red local para que la aplicación pueda acceder al frontend y al backend.

La configuración utilizada durante las pruebas fue:

```text
Frontend:
http://192.168.80.25:5173/

Backend:
http://192.168.80.25:3001/
```

Estas direcciones corresponden al entorno local de desarrollo y pueden cambiar dependiendo de la red utilizada.

---

## Pruebas

Ejecutar las pruebas de Flutter:

```bash
flutter test
```

---

## Estructura principal

```text
LogicLab-Movil-Flutter/
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── test/
│
├── lib/
│   └── main.dart
│
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```

---

## Proyectos relacionados

### Frontend

LogicLab Frontend desarrollado con React y Vite.

### Backend

LogicLab Backend desarrollado con Node.js, Express y MySQL.

---

## Proyecto

**LogicLab**

Sistema de gestión para restaurantes desarrollado como proyecto de software utilizando tecnologías web, backend, base de datos y aplicación móvil.
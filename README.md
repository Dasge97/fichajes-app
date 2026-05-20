# Fichajes Mobile

Aplicacion movil Flutter para registrar jornadas contra el backend Symfony de Fichajes.

## Stack

- Flutter + Dart
- `go_router` para navegacion
- `provider` para estado sencillo
- `dio` para HTTP
- `flutter_secure_storage` para sesion local

## Diseño implementado

La UI replica el paquete `entroYA-design/`:

- Marca `entroya`, fondo calido `#f6f6f3` y accion principal slate `#0f172a`.
- Login corporativo con acceso biometrico preparado.
- Inicio con saludo, avatar, estado, cronometro, progreso, accion principal y mini historial.
- Barra inferior: Inicio, Horario, Ausencias y Perfil.
- Horario semanal con resumen, barras por dia y filas por jornada.
- Ausencias con saldo anual, solicitud y estados.
- Perfil con resumen mensual y accesos a Historial y Correcciones.
- Historial del dia y lista de correcciones preparados como vistas secundarias.

## Estructura

```text
lib/
  core/
    config/       Configuracion de entorno
    network/      Cliente HTTP
    theme/        Tema visual
    widgets/      Widgets compartidos
  features/
    auth/         Login y sesion
    clocking/     Estado y acciones de fichaje
    history/      Historial del dia
    absences/     Ausencias
    profile/      Perfil y salida
```

## Ejecutar

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000 --dart-define=TENANT_ID=T1
```

`10.0.2.2` apunta al host desde el emulador Android. En dispositivo fisico, usa la IP local de la maquina que ejecuta Symfony.

## Acceso demo

Ejecuta primero `php bin/console app:cargar-demo` en el backend. La app movil entra con un trabajador real vinculado:

- `ana.torres@demo.local` / `Empleado123!`
- `bruno.garcia@demo.local` / `Empleado123!`

El usuario `admin@fichajes.local` queda para la web y no debe usar la app movil de fichaje mientras no exista selector de trabajador/equipo.

## Endpoints pendientes recomendados

La base ya llama a `POST /api/v1/login` y `POST /api/v1/fichajes/eventos`.

Para una app movil completa conviene anadir endpoints especificos:

- `POST /api/v1/login`: implementado, devuelve token movil firmado.
- `GET /api/v1/mobile/me`: implementado.
- `GET /api/v1/mobile/fichajes/estado`: implementado y conectado en Inicio.
- `GET /api/v1/mobile/fichajes/historial?fecha=...`: implementado y conectado en Historial.
- `POST /api/v1/mobile/fichajes/eventos`: implementado y conectado en Inicio.
- `GET /api/v1/mobile/horarios/semana?fecha=...`: implementado y conectado en Horario.
- `GET /api/v1/mobile/ausencias`: implementado y conectado en Ausencias.
- `POST /api/v1/ausencias`: ya existe, revisar contrato para movil.
- `GET /api/v1/mobile/correcciones`: implementado y conectado en Correcciones.
- `GET /api/v1/mobile/resumen`: implementado y conectado en Perfil.
- `POST /api/v1/correcciones`: ya existe, revisar contrato para formulario movil.
- Biometria local: la UI esta preparada, falta integrar `local_auth`.
- Solicitud de ausencias desde movil: pendiente de formulario y contrato final.
- Solicitud de correcciones desde movil: pendiente de formulario y contrato final.
- Saldo anual de vacaciones: ahora muestra dias reales aprobados/pendientes; falta configurar la bolsa anual por trabajador/convenio para calcular disponibles.

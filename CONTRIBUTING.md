# Cómo contribuir

Guía corta para los equipos COIL (UNIMINUTO + AUNAR Villavicencio).

## Flujo de trabajo

1. Actualiza `develop`: `git checkout develop && git pull`.
2. Crea tu rama: `git checkout -b feature/<nombre-corto>` (ej. `feature/resena-form`).
3. Programa en pasos pequeños. Antes de cada commit:
   ```bash
   dart format lib test
   flutter analyze
   flutter test
   ```
4. Commits con **Conventional Commits** (ver abajo).
5. `git push -u origin feature/<nombre-corto>` y abre un PR **hacia `develop`**.
6. Completa la plantilla del PR (checklist + capturas).
7. **Regla COIL:** el PR debe aprobarlo al menos un integrante de la **otra
   institución**. Nadie aprueba su propio PR.
8. Merge con *Squash and merge* cuando el CI esté en verde.

`main` solo recibe merges desde `develop` al cerrar cada encuentro (demo estable).

## Conventional Commits

```
<tipo>(<alcance opcional>): <descripción en presente, minúscula>
```

| Tipo       | Uso                                         |
| ---------- | ------------------------------------------- |
| `feat`     | nueva funcionalidad                         |
| `fix`      | corrección de un error                      |
| `refactor` | cambio de código sin cambiar comportamiento |
| `test`     | agregar o corregir pruebas                  |
| `docs`     | documentación                               |
| `style`    | formato, sin cambios de lógica              |
| `chore`    | dependencias, configuración, CI             |

Ejemplos:

```
feat(resenas): agregar formulario con selector de estrellas
fix(mapa): pedir permiso de ubicación antes de leer el GPS
test(auth): cubrir el caso de correo ya registrado
```

## Reglas de código

- Respeta las capas (ver README → Arquitectura). `domain` no importa Flutter ni Firebase.
- Los Blocs/Cubits reciben **casos de uso** por constructor.
- Nada de `print`: usa el `AppBlocObserver` o `dart:developer`.
- Al terminar un `TODO(COIL-Ex-n)`, **bórralo** y menciona el código en el PR.
- Nunca subas `google-services.json`, `GoogleService-Info.plist` ni tu
  `firebase_options.dart` real.

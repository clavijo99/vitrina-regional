# Decisiones de arquitectura (ADR breves)

## ADR-001 — Clean Architecture por features + flutter_bloc (2026-11-02)

**Contexto:** equipos mixtos de dos universidades, dos semanas, distintos niveles.
**Decisión:** features con capas `domain / data / presentation`; flutter_bloc
(Bloc para flujos con eventos, Cubit para estado simple); sin Riverpod, GetX ni
get_it. Toda la composición en `lib/app/di/app_providers.dart`.
**Consecuencias:** más archivos, pero cada equipo puede trabajar una capa o
feature en paralelo y todo es testeable con mocks.

## ADR-002 — `material_ui` en lugar de `package:flutter/material.dart` (2026-11-02)

**Contexto:** con Flutter 3.47.7, Material se distribuye como paquete
independiente (`material_ui`) y `go_router` 18 / `cached_network_image` ya
dependen de él. Mezclar ambas librerías crea dos `Theme` distintos.
**Decisión:** la app importa `package:material_ui/material_ui.dart`. No se usa
`MaterialUiCompatibilityBridge` porque está deprecado y el CI falla con infos.
**Consecuencias:** `flutter_map` aún usa la librería del SDK; sus widgets
internos (atribución) pueden no heredar el tema. Revisar al actualizar flutter_map.

## ADR-003 — `firebase_options.dart` como placeholder versionado (2026-11-02)

**Contexto:** el proyecto debe compilar recién clonado (modo mock) y no se
deben subir configuraciones reales.
**Decisión:** se versiona un `lib/firebase_options.dart` placeholder que lanza
`UnsupportedError` si se usa. Tras `flutterfire configure`, cada persona ejecuta
`git update-index --skip-worktree lib/firebase_options.dart`.
`google-services.json` y `GoogleService-Info.plist` están en `.gitignore` y hay
archivos `.example`.
**Consecuencias:** compila sin pasos extra; hay que recordar el
`skip-worktree` (está en README y CONTRIBUTING).

## ADR-004 — Reseñas en colección raíz `resenas` (2026-11-02)

**Decisión:** colección raíz filtrada por `emprendimientoId` (no subcolección),
para poder consultar también por autor. Requiere índice compuesto
(`emprendimientoId ASC, fecha DESC`) definido en `firestore.indexes.json`.

## ADR-005 — Modelos separados de entidades (2026-11-02)

**Decisión:** los modelos de `data` no extienden las entidades; exponen
`toEntity()` / `fromEntity()`. Con `equatable` 3 la igualdad compara
`runtimeType`, y mezclar modelo y entidad rompería comparaciones en tests y estados.

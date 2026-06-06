# Polla Mundialista 2026 - Publicacion

Esta carpeta contiene la version publica para desplegar en Vercel usando Supabase como base de datos compartida.

## 1. Crear Supabase

1. Entra a https://supabase.com y crea un proyecto.
2. Abre `SQL Editor`.
3. Copia y ejecuta todo el contenido de `supabase-schema.sql`.
4. Ve a `Project Settings > API`.
5. Copia:
   - `Project URL`
   - `anon public key`

## 2. Configurar la app

Abre `index.html` y cambia estas dos lineas:

```js
const SUPABASE_URL = "PEGA_AQUI_TU_SUPABASE_URL";
const SUPABASE_ANON_KEY = "PEGA_AQUI_TU_SUPABASE_ANON_KEY";
```

por tus valores reales de Supabase.

## 3. Publicar en Vercel

Opcion simple:

1. Entra a https://vercel.com.
2. Crea un proyecto nuevo.
3. Sube/importa esta carpeta `polla-mundialista-publica`.
4. Vercel publicara `index.html` como app estatica.

## Claves iniciales

- Administrador: `admin2026`
- Todos los jugadores: `jugador2026`

El administrador puede cambiar esas claves desde la app.

## Cierre de recepcion

En el modulo `Admin`, el interruptor `Recepcion de predicciones abierta` controla si los jugadores pueden guardar predicciones.

- Activado: los jugadores pueden guardar predicciones que aun no hayan guardado y que no tengan marcador final.
- Desactivado: ningun jugador puede guardar predicciones.
- Una vez un jugador guarda una prediccion completa, queda bloqueada para ese jugador.
- Si el administrador ya cargo el marcador final de un partido, los jugadores tampoco pueden modificar esa prediccion.
- El administrador siempre puede editar predicciones y marcadores.

## Importante

La version local anterior usa `localStorage`. Esta version usa Supabase cuando `SUPABASE_URL` y `SUPABASE_ANON_KEY` estan configurados. Si no los configuras, funcionara solo localmente y los datos no seran compartidos.

# Guía de uso (Español)

`agent-handoff-audit` es un protocolo que permite que **Claude Code** y **OpenAI Codex** trabajen en el mismo repositorio, uno después del otro, sin perder el contexto ni tener que releer toda la conversación anterior. Esta guía asume que nunca has instalado un *skill* (un conjunto de instrucciones que un agente de IA sigue) y explica cada término la primera vez que aparece.

Documentación completa en inglés: [`README.md`](../README.md) · [guía extensa](USAGE_GUIDE.md) · [solución de problemas](TROUBLESHOOTING.md)

---

## ¿Qué es esto?

Cuando alternas entre Claude Code y Codex en el mismo proyecto, cada uno empieza "en frío": no sabe qué hizo el otro, puede repetir trabajo, puede pisar cambios en curso, y no hay forma de comprobar si una prueba que el otro agente dijo haber ejecutado realmente se ejecutó.

Este skill soluciona eso con una **bitácora compartida**: una carpeta llamada `.agent-coordination/` con archivos de texto plano que ambos agentes leen antes de trabajar y actualizan después de trabajar. Ningún agente le habla al otro directamente — todo pasa por esta carpeta, así que un traspaso de tarea (lo que llamamos un **handoff**) funciona igual de bien si ocurre segundos después o días después.

---

## Instalación

Necesitas:

- **Git** (control de versiones)
- Una terminal
- **Bash** (viene instalado en macOS y Linux; en Windows usa WSL)
- Opcionalmente, Claude Code y/o Codex CLI instalados — el protocolo funciona incluso con un solo agente

Comprueba lo que ya tienes:

```bash
git --version
claude --version
codex --version
bash --version
```

Clona el repositorio e instala:

```bash
git clone https://github.com/DavidMume/agent-handoff-audit-sandbox.git
cd agent-handoff-audit-sandbox
bash install.sh
```

`install.sh` copia el skill a `~/.local/share/agent-handoff-audit` (la única copia real) y crea dos **enlaces simbólicos** — un enlace simbólico es un archivo que actúa como puntero hacia otra ubicación, en vez de ser una copia independiente — uno en `~/.claude/skills/agent-handoff-audit` para Claude y otro en `~/.agents/skills/agent-handoff-audit` para Codex. Así nunca hay dos copias del skill que puedan desincronizarse.

Comprueba que todo quedó en su lugar:

```bash
ls -la ~/.local/share/agent-handoff-audit
ls -la ~/.claude/skills/agent-handoff-audit
ls -la ~/.agents/skills/agent-handoff-audit
```

Las dos últimas líneas deben empezar con `l` (de "link") y apuntar hacia la primera ruta.

---

## Inicializar un proyecto existente

Instalar el skill una vez lo deja disponible para todos tus proyectos. Cada **repositorio** (una carpeta de proyecto con historial de Git) debe inicializarse por separado, una sola vez:

```bash
cd ~/Proyectos/mi-proyecto
bash ~/.local/share/agent-handoff-audit/scripts/init-project.sh .
```

Esto crea:

```text
.agent-coordination/
├── ACTIVE_SESSION.md   (quién está trabajando ahora mismo)
├── CURRENT_STATE.md    (resumen actual del proyecto)
├── DECISIONS.md        (decisiones que no deben revertirse sin más)
├── FINAL_AUDIT.md       (resultado de la auditoría final)
├── RISKS.md            (riesgos abiertos)
└── WORKLOG.md          (historial de traspasos, solo se añade, nunca se edita)
```

También añade un bloque corto a `AGENTS.md` (para Codex) y a `CLAUDE.md` (para Claude), y agrega `.agent-coordination/` al `.gitignore` — el archivo que le dice a Git qué carpetas/archivos ignorar — para que la bitácora se quede en tu máquina y no termine en un repositorio público.

**El script es idempotente**: puedes ejecutarlo una segunda vez sin miedo. Si algo ya existe, lo deja tal cual (verás "Kept existing ...") en vez de duplicarlo.

Si prefieres que la bitácora sí quede versionada en Git (por ejemplo, en un repositorio privado de equipo), usa:

```bash
bash ~/.local/share/agent-handoff-audit/scripts/init-project.sh . --tracked
```

---

## Claude empieza

Dentro de tu conversación con Claude Code, en el proyecto ya inicializado:

```text
/agent-handoff-audit start
```

Claude lee, en orden: las instrucciones del repositorio (`AGENTS.md`/`CLAUDE.md`), `CURRENT_STATE.md`, los riesgos abiertos en `RISKS.md`, las decisiones recientes en `DECISIONS.md`, y solo las últimas dos entradas de `WORKLOG.md`. Luego registra en `ACTIVE_SESSION.md` que está trabajando, desde qué **rama** (branch, una línea de trabajo independiente dentro del repositorio) y qué **commit** (una foto guardada del proyecto en un momento dado).

Claude implementa la tarea, ejecuta las pruebas del proyecto, y revisa su propio diff (los cambios exactos que hizo) antes de terminar.

## Claude hace el handoff

```text
/agent-handoff-audit handoff
```

Esto escribe **una sola** entrada compacta en `WORKLOG.md` con lo que se hizo, qué se verificó (con resultado real, no una afirmación vaga), y qué debería hacer el siguiente agente. Luego cierra `ACTIVE_SESSION.md`.

## Codex continúa

Horas o días después, en una sesión de Codex sobre el mismo repositorio:

```text
$agent-handoff-audit takeover
```

Codex lee el último handoff de Claude, revisa el diff o commit real que menciona, comprueba que lo que Claude dijo haber verificado tenga sentido con lo que realmente hay en el repositorio, y busca problemas obvios antes de seguir — sin necesidad de leer toda la conversación anterior con Claude.

Cuando termina:

```text
$agent-handoff-audit handoff
```

---

## Auditoría

Hay dos niveles:

- **`audit`** — una revisión enfocada e independiente de los cambios recientes del *otro* agente. Útil a mitad de proyecto.
- **`final-audit`** — la auditoría recíproca completa en un hito importante: Claude audita todo lo atribuido a Codex, y Codex audita todo lo atribuido a Claude, usando una lista de verificación compartida (seguridad, privacidad, dependencias, accesibilidad, despliegue, riesgos legales potenciales).

Reglas clave:

- **Quien hizo un arreglo no puede ser el único que lo verifique** — el otro agente debe confirmar que realmente quedó resuelto.
- **Ningún proyecto puede marcarse como aprobado si queda un hallazgo de severidad `CRITICAL` o `HIGH` sin resolver.**
- **Una auditoría hecha por un solo agente es provisional** y debe etiquetarse como tal.

```text
/agent-handoff-audit final-audit      (Claude)
$agent-handoff-audit final-audit      (Codex)
```

---

## Seguridad: qué nunca debe escribirse en la bitácora

Nunca escribas en `.agent-coordination/`: contraseñas, claves de API, tokens, claves privadas, cookies, datos personales, historiales médicos, datos financieros, datos de menores de edad, registros reales de producción, o el contenido completo de un error que incluya un secreto.

**Si un secreto se escribió por accidente:**

1. Detén el trabajo.
2. No hagas push — como `.agent-coordination/` está en `.gitignore` por defecto, en el caso normal el secreto nunca salió de tu máquina.
3. Rota o revoca el secreto de inmediato, sin importar si crees que fue expuesto o no.
4. Limpia el archivo.
5. Si el archivo llegó a comprometerse (por ejemplo, en modo `--tracked`), revisa el historial de Git — un simple cambio no basta, porque Git conserva versiones anteriores.
6. Registra que ocurrió el incidente en `RISKS.md`, **sin copiar el valor del secreto**.

Las auditorías de este skill no reemplazan una prueba de penetración profesional, una revisión de seguridad especializada, asesoría legal, ni una evaluación formal de privacidad o cumplimiento normativo.

---

## Solución de errores básicos

| Problema | Causa probable | Solución |
|---|---|---|
| `claude: command not found` | Claude Code no está instalado o no está en el `PATH` | Instala Claude Code o agrega su carpeta al `PATH` |
| El skill no aparece | Instalación incompleta o proyecto no inicializado | Verifica los symlinks con `ls -la` y corre `init-project.sh` |
| `.agent-coordination/` no se creó | Ruta incorrecta al ejecutar el script | Vuelve a correr `init-project.sh` con la ruta correcta; es idempotente |
| Un agente anterior dejó la sesión activa | No se ejecutó `handoff` antes de terminar | Anota en tu próximo handoff que estaba obsoleta y actualiza `ACTIVE_SESSION.md` |
| Apareció un secreto en la bitácora | Se escribió información sensible por error | Sigue los pasos de la sección de seguridad, arriba |

Para más casos (symlink roto, permisos denegados, `AGENTS.md` duplicado, dos agentes editando el mismo archivo, etc.), consulta [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) (en inglés, pero con comandos copiables que funcionan igual).

# Claude Code Status Line

The script reads JSON from stdin (provided by Claude Code) and prints a **two-line status bar**.

---
## How to use ?
- Either clone this repo or just copy the `statusline.sh` file
- Add the following in your `~/.claude.settings.json`:
```json
  "statusLine": {
    "type": "command",
    "command": "path/to/statusline.sh",
    "padding": 1 // ← optional
  }
```
## Description
### Line 1 — Workspace location

```
~/workspace/my-project | 🐙 my-repo 🔗 | ⌥ feature/my-branch
```

| Part                     | Shown when                                              |
|--------------------------|---------------------------------------------------------|
| `~/workspace/my-project` | Always — current directory with `$HOME` replaced by `~` |
| `🐙 my-repo`             | Only when inside a git repo                             |
| `🔗` (after repo name)   | Only when inside a git worktree                         |
| `⌥ feature/my-branch`    | Only when on a named branch (not detached HEAD)         |

---

### Line 2 — Model, context window, and updates

```
🤖 Claude Sonnet 4.6 — normal | 🟢 ████████████░░░░░░░░ 58% | +12 -3
```

**Model segment:**
```
🤖 Claude Sonnet 4.6 — normal
```
- Always shown.
- `💡` appended only when extended thinking is enabled.

**Context window segment** — a 20-char gradient bar from green → yellow → red:

| Usage   | Icon | Bar color             | Percentage color | Example                       |
|---------|------|-----------------------|------------------|-------------------------------|
| 0–19%   | 🟢   | Mostly green          | Green            | `🟢 ██░░░░░░░░░░░░░░░░░░ 8%`  |
| 20–69%  | ⚡️   | Green→yellow gradient | Green            | `⚡️ ████████████░░░░░░░░ 58%` |
| 70–89%  | 🔥   | Yellow→orange         | Yellow           | `🔥 ████████████████░░░░ 78%` |
| ≥ 90%   | 🚨   | Deep orange/red       | Red              | `🚨 ████████████████████ 94%` |
| No data | 🟢   | All grey `░`          | `--`             | `🟢 ░░░░░░░░░░░░░░░░░░░░ --%` |

**Lines diff segment** — lines added/removed by Claude this session:
```
+12 -3
```
- Always shown (zero when nothing changed). 
- Green `+N`, red `-N`.

---

### Full examples

No git repo, fresh context:
```
~/workspace/tmp-project
🤖 Claude Haiku 4.5 — normal | 🟢 ██░░░░░░░░░░░░░░░░░░ 8% | +0 -0
```

Git repo, mid-session with extended thinking:
```
~/workspace/my-app | 🐙 my-app | ⌥ feat/auth
🤖 Claude Sonnet 4.6 — high💡 | ⚡️ ██████████░░░░░░░░░░ 49% | +87 -23
```

Git worktree, context nearly full:
```
~/workspace/my-app | 🐙 my-app 🔗 | ⌥ fix/hotfix
🤖 Claude Opus 4.8 — normal | 🚨 ████████████████████ 96% | +412 -58
```

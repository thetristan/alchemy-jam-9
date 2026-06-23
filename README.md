# Game Template

A Godot 4.6 project template for jam games.

## Creating a new project

Use `bin/init.sh` to create a new project from this template:

```sh
bin/init.sh <name> <path>
```

- `<name>` — the project name (used as the folder name and replaces `alchemy-jam-9` throughout the project files)
- `<path>` — the parent directory where the new project folder will be created

**Example:**

```sh
bin/init.sh MyGame ~/Jams/Games
```

This will create a new project at `~/Jams/Games/MyGame` with:

- All template files copied over
- Git history removed and a fresh repository initialized
- `alchemy-jam-9` replaced with `MyGame` in all text files (including `project.godot`)

## Project structure

| Path | Description |
|------|-------------|
| `main.tscn` / `main.gd` | Entry point |
| `game/` | Main gameplay scene |
| `ui/` | UI scenes (title, options, pause, boot splash, theme) |
| `globals/` | Autoloaded singletons (SceneManager, GameOptions, SignalBus) |
| `etc/` | Utility classes (logging, async helpers, collections) |
| `bin/` | Developer scripts |
| `build/` | Export output |

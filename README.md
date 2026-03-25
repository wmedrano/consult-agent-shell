# consult-agent-shell

Consult integration for [agent-shell](https://github.com/agent-shell/agent-shell),
providing completing-read commands to interact with LLM agents.

## Installation

```elisp
(use-package consult-agent-shell
  :after consult
  :demand t
  :config
  (define-key consult-mode-map (kbd "a") #'consult-agent-shell-switch))
```

## Usage

### Switching to agent shells

`consult-agent-shell-switch` opens a completing-read interface to switch between
agent-shell buffers with live preview. If you enter a new name, it creates an
agent-shell with that name.

```
M-x consult-agent-shell-switch
```

### Sending regions to agent shells

`consult-agent-shell-send-region` sends the active region to a selected
agent-shell. Useful for piping code or text to an agent.

```
M-x consult-agent-shell-send-region
```

### Killing agent shells

`consult-agent-shell-kill` kills selected agent-shell buffers. Supports multi-select
with `M` marking candidates.

```
M-x consult-agent-shell-kill
```

### Status annotations

Existing agent shells show their status in the minibuffer:
- `[idle]` - Shell is ready (green)
- `[busy]` - Shell is processing (yellow)

## Configuration

### Buffer name format

Customize the buffer name format:

```elisp
(setq consult-agent-shell-buffer-name-format "%s @ (%s)")
```

The format supports:
- `%s` for the user-entered name
- `%s` for the project name (second occurrence)

### Preview window behavior

When an agent-shell window is visible, previews display there. Otherwise, the
original window is used.

### Kill confirmation

`consult-agent-shell-kill` supports three confirmation modes:

```elisp
;; Only prompt if shells are busy (default)
(setq consult-agent-shell-kill-confirm 'when-busy)

;; Always prompt
(setq consult-agent-shell-kill-confirm 'always)

;; Never prompt
(setq consult-agent-shell-kill-confirm 'never)
```

## Keybindings

| Command                           | Description                              |
| --------------------------------- | ---------------------------------------- |
| `consult-agent-shell-switch`      | Switch to or create an agent-shell      |
| `consult-agent-shell-send-region` | Send region to an agent-shell            |
| `consult-agent-shell-kill`        | Kill selected agent-shells (multi-select)|

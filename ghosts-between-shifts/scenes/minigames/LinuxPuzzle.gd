extends "res://scripts/minigames/minigame_base.gd"
## Linux/programming puzzle — a FULLY SIMULATED, sandboxed, fictional terminal.
## It NEVER touches the real OS and NEVER executes real commands. Everything is
## an in-memory model. Objective: the fake service "printerd" is failing; find
## why (unreadable config) and fix it, then restart the service.

var _output: RichTextLabel
var _input: LineEdit
var _cwd := "/home/yasen"
var _commands_used := 0
var _hints_used := 0
var _solved := false

# In-memory fake filesystem: path -> { type, mode, content }
var _fs := {}
# Fake service state.
var _service := { "printerd": { "state": "failed", "reason": "cannot read /etc/printerd/printerd.conf: Permission denied" } }
var _packages := ["coreutils", "bash", "systemd"]

func _ready() -> void:
	setup("Linux пъзел: счупена услуга (симулация)",
		"Фиктивен, безопасен терминал. Никакви реални команди не се изпълняват. "
		+ "Услугата 'printerd' не тръгва. Открий причината и я поправи, после я рестартирай. "
		+ "Напиши 'help' за команди, 'hint' за подсказка.")
	_init_fs()
	_build_ui()
	_print("printerd се провали при последното зареждане. Диагностицирай проблема.")
	_print("Съвет: започни с 'systemctl status printerd'.")
	_prompt()


func _init_fs() -> void:
	_fs = {
		"/": { "type": "dir", "children": ["home", "etc", "var"] },
		"/home": { "type": "dir", "children": ["yasen"] },
		"/home/yasen": { "type": "dir", "children": ["notes.txt"] },
		"/home/yasen/notes.txt": { "type": "file", "mode": "644",
			"content": "TODO: оправи principa; принтер услугата пада всяка сутрин." },
		"/etc": { "type": "dir", "children": ["printerd"] },
		"/etc/printerd": { "type": "dir", "children": ["printerd.conf"] },
		# The bug: config exists but is unreadable (mode 000).
		"/etc/printerd/printerd.conf": { "type": "file", "mode": "000",
			"content": "listen=127.0.0.1:6310\nspool=/var/spool/printerd\n" },
		"/var": { "type": "dir", "children": ["log", "spool"] },
		"/var/log": { "type": "dir", "children": ["printerd.log"] },
		"/var/log/printerd.log": { "type": "file", "mode": "644",
			"content": "ERROR open(/etc/printerd/printerd.conf): Permission denied (mode 000)\n" },
		"/var/spool": { "type": "dir", "children": ["printerd"] },
		"/var/spool/printerd": { "type": "dir", "children": [] },
	}


func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(60, 220)
	panel.custom_minimum_size = Vector2(1500, 620)
	content.add_child(panel)
	var vb := VBoxContainer.new()
	panel.add_child(vb)
	_output = RichTextLabel.new()
	_output.bbcode_enabled = true
	_output.scroll_following = true
	_output.custom_minimum_size = Vector2(1460, 540)
	_output.add_theme_font_size_override("normal_font_size", 20)
	vb.add_child(_output)
	_input = LineEdit.new()
	_input.placeholder_text = "въведи команда и Enter (help)"
	_input.custom_minimum_size = Vector2(1460, 40)
	_input.text_submitted.connect(_on_submit)
	vb.add_child(_input)
	_input.grab_focus()


func _prompt() -> void:
	_input.grab_focus()


func _print(line: String) -> void:
	_output.append_text(line + "\n")


func _on_submit(text: String) -> void:
	_input.clear()
	var cmd := text.strip_edges()
	if cmd == "":
		return
	_print("[color=#8ad]yasen@kardzhali[/color]:%s$ %s" % [_cwd, cmd])
	_commands_used += 1
	_run(cmd)
	_prompt()


func _run(cmd: String) -> void:
	var parts := cmd.split(" ", false)
	var name := parts[0]
	var args := parts.slice(1)
	match name:
		"help":
			_print("Команди: ls [-l] [път], cd <път>, pwd, cat <файл>, chmod <mode> <файл>, "
				+ "systemctl status|restart <услуга>, journalctl [-u услуга], apt list, clear, hint, exit")
		"pwd":
			_print(_cwd)
		"clear":
			_output.clear()
		"ls":
			_cmd_ls(args)
		"cd":
			_cmd_cd(args)
		"cat":
			_cmd_cat(args)
		"chmod":
			_cmd_chmod(args)
		"systemctl":
			_cmd_systemctl(args)
		"journalctl":
			_cmd_journal(args)
		"apt":
			_print("Инсталирани пакети: " + ", ".join(_packages))
		"hint":
			_hints_used += 1
			_print("[color=#fc6]Подсказка:[/color] логът сочи 'Permission denied (mode 000)'. "
				+ "Виж правата с 'ls -l /etc/printerd' и ги оправи с chmod.")
		"exit":
			_finish_puzzle()
		_:
			_print("[color=#f66]%s: команда не е намерена (това е симулация)[/color]" % name)


func _resolve(path: String) -> String:
	if path == "":
		return _cwd
	if path.begins_with("/"):
		return _norm(path)
	if _cwd == "/":
		return _norm("/" + path)
	return _norm(_cwd + "/" + path)


func _norm(path: String) -> String:
	var parts := path.split("/", false)
	var stack: Array = []
	for p in parts:
		if p == ".":
			continue
		elif p == "..":
			if stack.size() > 0:
				stack.pop_back()
		else:
			stack.append(p)
	return "/" + "/".join(stack) if stack.size() > 0 else "/"


func _cmd_ls(args: Array) -> void:
	var long := false
	var target := _cwd
	for a in args:
		if a == "-l":
			long = true
		else:
			target = _resolve(a)
	if not _fs.has(target):
		_print("ls: няма такъв път: %s" % target)
		return
	var node: Dictionary = _fs[target]
	if node["type"] == "file":
		_print(target.get_file())
		return
	for child in node["children"]:
		var cp := _norm(target + "/" + child)
		var cnode: Dictionary = _fs.get(cp, {})
		if long:
			var mode := String(cnode.get("mode", "755"))
			var kind := "d" if cnode.get("type", "") == "dir" else "-"
			_print("%s%s  %s" % [kind, _mode_str(mode), child])
		else:
			_print(child)


func _mode_str(mode: String) -> String:
	# Turn "644" into rw-r--r-- style (fictional, for readability).
	var map := { "0": "---", "1": "--x", "2": "-w-", "3": "-wx",
		"4": "r--", "5": "r-x", "6": "rw-", "7": "rwx" }
	var s := ""
	for ch in mode:
		s += map.get(ch, "---")
	return s


func _cmd_cd(args: Array) -> void:
	if args.is_empty():
		_cwd = "/home/yasen"
		return
	var target := _resolve(args[0])
	if _fs.has(target) and _fs[target]["type"] == "dir":
		_cwd = target
	else:
		_print("cd: няма такава директория: %s" % args[0])


func _cmd_cat(args: Array) -> void:
	if args.is_empty():
		_print("cat: липсва аргумент")
		return
	var target := _resolve(args[0])
	if not _fs.has(target) or _fs[target]["type"] != "file":
		_print("cat: няма такъв файл: %s" % args[0])
		return
	var node: Dictionary = _fs[target]
	if String(node.get("mode", "644")).begins_with("0"):
		_print("[color=#f66]cat: %s: Permission denied[/color]" % args[0])
		return
	_print(String(node.get("content", "")))


func _cmd_chmod(args: Array) -> void:
	if args.size() < 2:
		_print("chmod: употреба: chmod <mode> <файл>")
		return
	var mode := String(args[0])
	var target := _resolve(args[1])
	if not _fs.has(target):
		_print("chmod: няма такъв файл: %s" % args[1])
		return
	_fs[target]["mode"] = mode
	_print("правата на %s са зададени на %s" % [args[1], mode])


func _cmd_systemctl(args: Array) -> void:
	if args.size() < 2:
		_print("systemctl: употреба: systemctl status|restart <услуга>")
		return
	var action := String(args[0])
	var svc := String(args[1])
	if not _service.has(svc):
		_print("Unit %s.service could not be found." % svc)
		return
	if action == "status":
		var st: Dictionary = _service[svc]
		_print("● %s.service — Fictional Print Daemon" % svc)
		_print("   Active: [color=%s]%s[/color]" % [
			"#6f6" if st["state"] == "active" else "#f66", st["state"]])
		if st["state"] != "active":
			_print("   Причина: " + String(st.get("reason", "unknown")))
	elif action == "restart":
		# Restart succeeds only if the config is now readable.
		var conf: Dictionary = _fs["/etc/printerd/printerd.conf"]
		if String(conf.get("mode", "000")).begins_with("0"):
			_service[svc]["state"] = "failed"
			_print("[color=#f66]Job for %s.service failed: config unreadable.[/color]" % svc)
		else:
			_service[svc]["state"] = "active"
			_print("[color=#6f6]%s.service рестартирана успешно — Active: active[/color]" % svc)
			_check_solved()
	else:
		_print("systemctl: непозната команда: %s" % action)


func _cmd_journal(args: Array) -> void:
	_print(String(_fs["/var/log/printerd.log"]["content"]).strip_edges())


func _check_solved() -> void:
	if _service["printerd"]["state"] == "active" and not _solved:
		_solved = true
		_print("[color=#6f6]Готово! printerd работи. Напиши 'exit' за да приключиш.[/color]")


func _finish_puzzle() -> void:
	var score := 0.0
	if _solved:
		# Fewer commands + fewer hints = higher score.
		score = clampf(1.0 - 0.03 * float(maxi(0, _commands_used - 5)) - 0.15 * _hints_used, 0.4, 1.0)
	else:
		score = 0.2
	var summary := ("Linux пъзел решен (%d команди, %d подсказки)." % [_commands_used, _hints_used]) \
		if _solved else "Linux пъзел незавършен."
	finish(score, summary)

extends Node

var defaultSave = {
	"levels": [
		{
			"level_name": "",
			"creator": "",
			"runs": "",
			"completed": false,
			"goal": "",
			"lvlType": 0,
			"notes": "",
			"noclip": "",
			"image_path": "res://Difficulties/extremeDemon.png"
		}
	]
}

var data = {}

var buttons = []
var selected_level = 0

var delay = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/LinkButton.hide()
	check_for_update()
	
	data = load_file()
	if data["levels"] == []:
		data = defaultSave
		save_file(data)
	
	_check_valid_save()
	
	buttons.append($UI/LevelsList/VBoxContainer/levelButton)
	
	$UI/LevelsList/VBoxContainer/levelButton.text = data["levels"][0].level_name
	_refresh()
	
	for i in range(1, data["levels"].size()):
		_add_level_on_launch(i)

func _refresh():
	$UI/Panel/LevelName.text = data["levels"][selected_level].level_name
	$UI/Panel/Runs.text = data["levels"][selected_level].runs
	$UI/Panel/CompletionStatus.button_pressed = data["levels"][selected_level].completed
	$UI/Panel/Creators.text = data["levels"][selected_level].creator
	$UI/Panel/Goal.text = data["levels"][selected_level].goal
	$UI/Panel/Type.selected = data["levels"][selected_level].lvlType
	$UI/Panel/Notes.text = data["levels"][selected_level].notes
	$UI/Panel/NoclipAcc.text = data["levels"][selected_level].noclip
	$UI/Panel/TextureRect.texture = load(data["levels"][selected_level].image_path)

# basically just to check if ur save has every key that it needs to prevent crashes or save corruption
func _check_valid_save():
	for i in range(data["levels"].size()):
		if !data["levels"][i].has("level_name"):
			data["levels"][i].level_name = ""
		if !data["levels"][i].has("creator"):
			data["levels"][i].creator = ""
		if !data["levels"][i].has("runs"):
			data["levels"][i].runs = ""
		if !data["levels"][i].has("completed"):
			data["levels"][i].completed = false
		if !data["levels"][i].has("goal"):
			data["levels"][i].runs = ""
		if !data["levels"][i].has("lvlType"):
			data["levels"][i].lvlType = 0
		if !data["levels"][i].has("notes"):
			data["levels"][i].notes = ""
		if !data["levels"][i].has("noclip"):
			data["levels"][i].noclip = ""
		if !data["levels"][i].has("image_path"):
			data["levels"][i].image_path = "res://Difficulties/extremeDemon.png"
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _open_credits_window():
	$UI/Panel/BorderTop/CreditsButton/CreditsWindow.show()

func save_file(dict):
	var saveGame = FileAccess.open("user://gdptsave.json", FileAccess.WRITE)
	var json_string = JSON.stringify(dict)
	saveGame.store_line(json_string)
	saveGame.close()

func load_file():
	if not FileAccess.file_exists("user://gdptsave.json"):
		return defaultSave
	var saveGame = FileAccess.open("user://gdptsave.json", FileAccess.READ)
	while saveGame.get_position() < saveGame.get_length():
		var json_string = saveGame.get_line()
		var json = JSON.new()
		var _parse_result = json.parse(json_string)
		var node_data = json.get_data()
		saveGame.close()
		return node_data

func check_for_update():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("https://api.github.com/repos/nile64/GeometryDashProgressionTracker/releases/latest")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if(!json.has("name")):
		return
	
	print(json["name"])
	if json["name"] != ProjectSettings.get_setting("application/config/version"):
		$UI/LinkButton.show()
		$UI/LinkButton.text = "Click here to Update! (Installed: " + ProjectSettings.get_setting("application/config/version") + ", Latest: " + json["name"] + ")"

func _add_level():
	var lvlButton
	if has_node("UI/LevelsList/VBoxContainer/levelButton"):
		lvlButton = $UI/LevelsList/VBoxContainer/levelButton.duplicate()
	elif has_node("UI/LevelsList/VBoxContainer/levelButton2"):
		lvlButton = $UI/LevelsList/VBoxContainer/levelButton2.duplicate()
	else:
		print("cannot add level")
	$UI/LevelsList/VBoxContainer.add_child(lvlButton)
	lvlButton.name = "levelButton"
	lvlButton.text = ""
	
	buttons.append(lvlButton)
	data["levels"].append(
		{
			"level_name": "",
			"creator": "",
			"runs": "",
			"completed": false,
			"goal": "",
			"lvlType": 0,
			"notes": "",
			"noclip": "",
			"image_path": "res://Difficulties/extremeDemon.png"
		}
	)
	
	save_file(data)

func _add_level_on_launch(panel_num : int):
	var lvlButton = $UI/LevelsList/VBoxContainer/levelButton.duplicate()
	$UI/LevelsList/VBoxContainer.add_child(lvlButton)
	lvlButton.text = data["levels"][panel_num].level_name
	lvlButton.queue_redraw()
	await get_tree().process_frame
	lvlButton.set_size(lvlButton.get_minimum_size())
	
	buttons.append(lvlButton)
	
	save_file(data)

func _remove_level():
	data["levels"].remove_at(selected_level)
	save_file(data)
	if data["levels"] == []:
		name = "levelPanel"
		_add_level()
	buttons[selected_level].queue_free()
	buttons.remove_at(selected_level)
	selected_level = 0
	_refresh()

func _level_button_press(btn : Button):
	selected_level = buttons.find(btn)
	print(selected_level)
	_refresh()


func _on_change_title(new_text):
	buttons[selected_level].text = new_text
	data["levels"][selected_level].level_name = new_text
	save_file(data)


func _on_text_edit_text_changed():
	data["levels"][selected_level].runs = $UI/Panel/Runs.text
	save_file(data)


func _on_complete_check_box_pressed():
	data["levels"][selected_level].completed = $UI/Panel/CompletionStatus.toggle_mode
	save_file(data)


func _on_complete_check_box_toggled(toggled_on):
	data["levels"][selected_level].completed = toggled_on
	save_file(data)

func _on_change_creator(new_text):
	data["levels"][selected_level].creator = new_text
	save_file(data)

func _on_change_goal(new_text):
	data["levels"][selected_level].goal = new_text
	save_file(data)


func _on_type_item_selected(index):
	data["levels"][selected_level].lvlType = index
	save_file(data)


func _on_noclip_acc_text_changed():
	data["levels"][selected_level].noclip = $UI/Panel/NoclipAcc.text
	save_file(data)

func _on_notes_text_changed():
	data["levels"][selected_level].notes = $UI/Panel/Notes.text
	save_file(data)


func _on_open_filedialog():
	$UI/Panel/Button/FileDialog.popup()


func _on_file_dialog_file_selected(path):
	print(path)
	$UI/Panel/TextureRect.texture = load(path)
	data["levels"][selected_level].image_path = path
	save_file(data)

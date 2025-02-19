extends Node

var defaultSave = {
	"levels": [
		{
			"level_name": "",
			"runs": "",
			"completed": false
		}
	]
}

var data = {}

var buttons = []
var selected_level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/LinkButton.hide()
	check_for_update()
	
	data = load_file()
	if data["levels"] == []:
		data = defaultSave
		save_file(data)
	
	buttons.append($UI/LevelsList/VBoxContainer/levelButton)
	
	$UI/LevelsList/VBoxContainer/levelButton.text = data["levels"][0].level_name
	$UI/Panel/LineEdit.text = data["levels"][0].level_name
	$UI/Panel/TextEdit.text = data["levels"][0].runs
	
	for i in range(1, data["levels"].size()):
		_add_level_at_beginning(i)


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
	data["levels"].append({"level_name":"", "runs":""})
	
	save_file(data)

func _add_level_at_beginning(panel_num : int):
	var lvlButton = $UI/LevelsList/VBoxContainer/levelButton.duplicate()
	$UI/LevelsList/VBoxContainer.add_child(lvlButton)
	lvlButton.text = data["levels"][panel_num].level_name
	
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
	$UI/Panel/LineEdit.text = data["levels"][selected_level].level_name
	$UI/Panel/TextEdit.text = data["levels"][selected_level].runs

func _level_button_press(btn : Button):
	selected_level = buttons.find(btn)
	print(selected_level)
	$UI/Panel/LineEdit.text = data["levels"][selected_level].level_name
	$UI/Panel/TextEdit.text = data["levels"][selected_level].runs


func _on_change_title(new_text):
	buttons[selected_level].text = new_text
	data["levels"][selected_level].level_name = new_text
	save_file(data)


func _on_text_edit_text_changed():
	data["levels"][selected_level].runs = $UI/Panel/TextEdit.text
	save_file(data)


func _on_complete_check_box_pressed():
	data["levels"][selected_level].completed = $UI/Panel/CheckBox.toggle_mode
	save_file(data)

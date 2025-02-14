extends Node

var defaultSave = {
	"level_name": "",
	"runs": ""
}

var data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/LinkButton.hide()
	check_for_update()
	
	data = load_file()
	
	$UI/Panel/ScrollContainer/VBoxContainer/levelPanel/Panel/LineEdit.text = data["level_name"]
	$UI/Panel/ScrollContainer/VBoxContainer/levelPanel/Panel/TextEdit.text = data["runs"]


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

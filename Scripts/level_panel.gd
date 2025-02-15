extends Control

var panel_number = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_undrop_panel()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_change_title(new_text):
	var current_save = get_parent().get_parent().get_parent().get_parent().get_parent().data
	current_save["levels"][panel_number].level_name = new_text
	get_parent().get_parent().get_parent().get_parent().get_parent().save_file(current_save)


func _on_text_edit_text_changed():
	var current_save = get_parent().get_parent().get_parent().get_parent().get_parent().data
	current_save["levels"][panel_number].runs = $mainPanel/Panel/TextEdit.text
	get_parent().get_parent().get_parent().get_parent().get_parent().save_file(current_save)


func _remove_level():
	var current_save = get_parent().get_parent().get_parent().get_parent().get_parent().data
	current_save["levels"].remove_at(panel_number)
	if current_save["levels"] == []:
		name = "levelPanel"
		get_parent().get_parent().get_parent().get_parent().get_parent()._add_level()
	get_parent().get_parent().get_parent().get_parent().get_parent().save_file(current_save)
	queue_free()

func _dropdown_panel():
	$DropdownPanel.show()
	size = Vector2(789, 500)

func _undrop_panel():
	$DropdownPanel.hide()
	size = Vector2(789, 150)

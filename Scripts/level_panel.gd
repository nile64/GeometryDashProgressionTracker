extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_change_title(new_text):
	var current_save = get_parent().get_parent().get_parent().get_parent().get_parent().data
	current_save["level_name"] = new_text
	get_parent().get_parent().get_parent().get_parent().get_parent().save_file(current_save)


func _on_text_edit_text_changed():
	var current_save = get_parent().get_parent().get_parent().get_parent().get_parent().data
	current_save["runs"] = $Panel/TextEdit.text
	get_parent().get_parent().get_parent().get_parent().get_parent().save_file(current_save)

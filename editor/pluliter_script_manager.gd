@tool
extends Control

@export var ks_path_edit: LineEdit
@export var load_path_btn: Button
@export var load_dialog: FileDialog
@export var generate_btn: Button
@export var empty_btn: Button

var data_list
var _data_list

func _enter_tree():
	load_path_btn.pressed.connect(_on_load_btn_pressed)
	generate_btn.pressed.connect(_on_all_generate)
	empty_btn.pressed.connect(_clean_all)
	if !ks_path_edit.text_changed.is_connected(_get_data_list):
		ks_path_edit.text_changed.connect(_get_data_list)
	load_dialog.file_selected.connect(_get_data_list)

func _get_data_list(path: String):
	ks_path_edit.text = path
	print("从路径"+path+"加载剧本资源列表")
	if ks_path_edit.text.length() == 0:
		data_list = null
	else:
		data_list = ResourceLoader.load(ks_path_edit.text)
		if data_list:
			print(data_list)
			_data_list = data_list.dialog_data_list
func _clean_all():
	if data_list:
		for data in _data_list:
			data._clean_dialog_data()
		print("清空预生成的剧情文件")
		
func _on_all_generate():
	if data_list:
		for data in _data_list:
			data._generate_dialog_data()
		print("脚本解析生成完毕")
		
func _on_load_btn_pressed():
	load_dialog.popup()
	

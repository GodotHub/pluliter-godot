@tool
extends Resource
class_name PreloadDialogData

# 备注名称
@export var note_name: String
# 文件路径
@export_file("*.txt") var _dialog_data_file_path : String:
	set(v):
		_dialog_data_file_path = v
		# 如果在编辑器模式下自动预生成
		if Engine.is_editor_hint():
			_generate_dialog_data()
# 剧情
@export var _dialog_data: DialogueData = DialogueData.new()

## 生成剧情数据
func _generate_dialog_data() -> void:
	if _dialog_data_file_path.length() >= 0:
		_dialog_data = pscripts.process_scripts_to_data(_dialog_data_file_path)
	else:
		_dialog_data = null
		
## 清除剧情数据
func _clean_dialog_data() -> void:
	if _dialog_data.dialogs.size() >= 0:
		_dialog_data.chapter_id = ""
		_dialog_data.chapter_name = ""
		_dialog_data.dialogs.clear()
	else:
		return

### 保存资源数据
#func save_to_resource():
	#var error = ResourceSaver.save(_dialog_data, _dialog_data_file_path.get_base_dir())
	#if error:
		#print("生成资源保存到" + str(_dialog_data_file_path.get_base_dir()))
	#pass

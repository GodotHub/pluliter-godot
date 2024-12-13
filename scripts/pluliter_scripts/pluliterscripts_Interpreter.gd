@tool
extends Node

# Konado脚本解释器
func process_scripts_to_data(path: String) -> DialogueData :
	var diadata = DialogueData.new()
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var lines: PackedStringArray
	if file.get_as_text() != null:
		lines = file.get_as_text().split("\n")
	# 获取章节ID并取出
	if !lines[0].begins_with("chapter_id") || lines[0].split(" ")[1] == null || lines[0].split(" ")[1].length() <= 0:
		_scripts_debug(path, 1,"无法找到剧情ID 脚本第一行应该为剧情ID")
		return
	else:
		diadata.chapter_id = lines[0].split(" ")[1]
		lines.remove_at(0)
	# 获取章节名称并取出
	if !lines[0].begins_with("chapter_name") || lines[0].split(" ")[1] == null || lines[0].split(" ")[1].length() <= 0:
		_scripts_debug(path, 2,"无法找到标题名称! 脚本第二行应该为剧情章节名称")
		return
	else:
		diadata.chapter_name = lines[0].split(" ")[1]
		#lines.pop_front()
		lines.remove_at(0)
	# 遍历脚本
	if lines != null:
		var line_index: int
		# 行标
		line_index = 2
		for line in lines:
			# 忽略注释行
			if line.is_empty() || line.begins_with("#"):
				line_index += 1
				continue
			# 背景切换处理
			if line.begins_with("background"):
				var dialog = Dialogue.new()
				dialog.dialog_type = Dialogue.Type.Switch_Background
				# 如果有特效
				if line.split(" ").size() == 3:
					if line.split(" ")[2] == "erase":
						dialog.background_toggle_effects = ActingInterface.EffectsType.EraseEffect
					if line.split(" ")[2] == "blinds":
						dialog.background_toggle_effects = ActingInterface.EffectsType.BlindsEffect
					if line.split(" ")[2] == "wave":
						dialog.background_toggle_effects = ActingInterface.EffectsType.WaveEffect
					if line.split(" ")[2] == "fade":
						dialog.background_toggle_effects = ActingInterface.EffectsType.FadeInAndOut
				else:
					dialog.background_toggle_effects = ActingInterface.EffectsType.None
				dialog.background_image_name = line.split(" ")[1]
				line_index += 1
				diadata.dialogs.append(dialog)
				continue
			# 角色表演处理
			if line.begins_with("actor"):
				var dialog = Dialogue.new()
				var values = line.split(" ")
				var t = values[1]
				# 如果是显示角色
				if t == "show":
					dialog.dialog_type = Dialogue.Type.Display_Actor
					var actor: DialogueActor = DialogueActor.new()
					if values[2] != null:
						actor.character_name = values[2]
					else:
						pass
					actor.character_state = values[3]
					actor.actor_position.x = values[5].to_float()
					actor.actor_position.y = values[6].to_float()
					actor.actor_scale = values[7].to_float()
					dialog.show_actor = actor
				# 如果是退出角色
				if t == "exit":
					dialog.dialog_type = Dialogue.Type.Exit_Actor
					dialog.exit_actor = values[2]
				# 如果是切换角色
				if t == "change":
					dialog.dialog_type = Dialogue.Type.Actor_Change_State
					dialog.change_state_actor = values[2]
					dialog.change_state = values[3]
				# 如果是移动角色
				if t == "move":
					dialog.dialog_type = Dialogue.Type.Move_Actor
					dialog.target_move_chara = values[2]
					dialog.target_move_pos.x = values[3].to_float()
					dialog.target_move_pos.y = values[4].to_float()
				line_index += 1
				diadata.dialogs.append(dialog)
				continue
			# 解析音频播放处理
			if line.begins_with("play"):
				var dialog = Dialogue.new()
				var values = line.split(" ")
				var t = values[1]
				if t == "bgm":
					dialog.dialog_type = Dialogue.Type.Play_BGM
					dialog.bgm_name = values[2]
				if t == "soundeffect":
					dialog.dialog_type = Dialogue.Type.Play_SoundEffect
					dialog.soundeffect_name = values[2]
				line_index += 1
				diadata.dialogs.append(dialog)
				continue
			# 解析音频停止处理
			if line.begins_with("stop"):
				var dialog = Dialogue.new()
				var values = line.split(" ")
				var t = values[1]
				if t == "bgm":
					dialog.dialog_type = Dialogue.Type.Stop_BGM
				line_index += 1
				diadata.dialogs.append(dialog)
				continue
			# 解析选项
			if line.begins_with("choice"):
				var dialog = Dialogue.new()
				dialog.dialog_type = Dialogue.Type.Show_Choice
				var values = line.split(" ")
				# 遍历选项
				var i = 1
				while (2*i-1) < values.size():
					var choices = DialogueChoice.new()
					var ct = values[2*i-1]
					if ct == null:
						break
					var ct_t = ct.split("\"")[1]
					var cj = values[2*i]
					if cj == null:
						break
					choices.choice_text = ct_t
					choices.jumpdata_id = cj
					dialog.choices.append(choices)
					i+=1
				line_index += 1
				diadata.dialogs.append(dialog)
				continue
			# 解析剧情跳转
			if line.begins_with("jump"):
				var dialog = Dialogue.new()
				var values = line.split(" ")
				var data_name = values[1]
				dialog.dialog_type = Dialogue.Type.JUMP
				dialog.jump_data_name = data_name
				diadata.dialogs.append(dialog)
				line_index += 1
				continue
			# 解锁成就
			if line.begins_with("unlock_achievement"):
				var dialog = Dialogue.new()
				dialog.dialog_type = Dialogue.Type.UNLOCK_ACHIEVEMENTS
				var values = line.split(" ")
				var target_achievement_id = values[1]
				dialog.achievement_id = target_achievement_id
				diadata.dialogs.append(dialog)
				line_index += 1
				continue
			# 剧情结束
			if line.begins_with("end"):
				var dialog = Dialogue.new()
				dialog.dialog_type = Dialogue.Type.THE_END
				diadata.dialogs.append(dialog)
				line_index += 1
				continue
			# 解析对话
			if line.begins_with("\""):
				var dialog = Dialogue.new()
				dialog.dialog_type = Dialogue.Type.Ordinary_Dialog
				var values = line.split("\"")
				if values.size() == 5:
					dialog.character_id = values[1]
					dialog.dialog_content = values[3]
					# 如果有播放配音
					if values[4].split(" ").size() == 2:
						dialog.voice_id = values[4].split(" ")[1] # 去掉前面空格
					diadata.dialogs.append(dialog)
					line_index += 1
					continue
				else:
					_scripts_debug(path, line_index+1,"对话格式错误")
				line_index += 1
				continue
			# 无法识别的语法
			else:
				_scripts_tip(path, line_index+1,"无法识别的语法，请删除")
				continue
		print_rich("[color=cyan]文件：[/color]" + path + "  [color=cyan]剧情预生成完毕 (｀・ω・´)[/color]" + "  章节名称：" + str(diadata.chapter_name) + \
		"  章节ID：" + str(diadata.chapter_id) + "  对话数量：" + str(line_index))
		return diadata
	return

# 输出错误
func _scripts_debug(path: String, line: int, error_info: String):
	print_rich("[color=cyan]错误： >_<¦¦¦[/color]   " + 
	"[color=FLORAL_WHITE]文件：[/color]" + path + 
	"  [color=DEEP_SKY_BLUE]行： [/color]"+ str(line) + 
	"  [color=DARK_ORANGE]信息：[/color]" + error_info)

# 输出提示
func _scripts_tip(path: String, line: int, error_info: String):
	print_rich("[color=cyan]警告： O_o[/color]   " + 
	"[color=FLORAL_WHITE]文件：[/color]" + path + 
	"  [color=DEEP_SKY_BLUE]行： [/color]"+ str(line) + 
	"  [color=LIME]信息：[/color]" + error_info)

@tool
@icon("res://Assets/UI Pack Kenney/PNG/Yellow/Default/PNG/Default (64px)/pawns.png")
class_name Party
extends Resource

@export var meteormytes: Array[Meteormyte] = []

func add_meteormyte(meteormyte: Meteormyte) -> void:
	if meteormyte:
		meteormytes.append(meteormyte)

func remove_meteormyte(meteormyte: Meteormyte) -> void:
	var idx := meteormytes.find(meteormyte)
	print("Removing meteormyte...")
	if idx != -1:
		print("REMOVED AT THE CORRECT INDEX!!! IT WORKED!")
		meteormytes.remove_at(idx)
	

func removeMeteormyteByNickname(name: String) -> void:
	for meteormyte in meteormytes:
		if meteormyte.nickname == name:
			print("REMOVING WITH FUNC IN HOUSE")
			remove_meteormyte(meteormyte)

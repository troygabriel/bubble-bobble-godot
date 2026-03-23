extends SceneTree


func _initialize() -> void:
	var main_scene = load("res://Main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	main._start_new_game()
	for _frame in range(180):
		await process_frame
	for child in root.get_children():
		child.queue_free()
	await process_frame
	quit()

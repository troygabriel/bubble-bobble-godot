extends Node

const SFX_STREAMS := {
	"jump": preload("res://assets_ai/processed/audio/sfx/jump.wav"),
	"fire": preload("res://assets_ai/processed/audio/sfx/fire.wav"),
	"trap": preload("res://assets_ai/processed/audio/sfx/trap.wav"),
	"pop": preload("res://assets_ai/processed/audio/sfx/pop.wav"),
	"hurt": preload("res://assets_ai/processed/audio/sfx/hurt.wav"),
	"clear": preload("res://assets_ai/processed/audio/sfx/clear.wav"),
	"game_over": preload("res://assets_ai/processed/audio/sfx/game_over.wav"),
	"start": preload("res://assets_ai/processed/audio/sfx/start.wav")
}
const MUSIC_STREAM = preload("res://assets_ai/processed/audio/music/reef_loop.wav")

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var next_sfx_player := 0


func _ready() -> void:
	_ensure_bus("Music", -10.0)
	_ensure_bus("SFX", -4.0)

	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	music_player.volume_db = -9.5
	add_child(music_player)
	_assign_looping_music()

	for index in range(8):
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % index
		player.bus = "SFX"
		player.volume_db = -3.0
		add_child(player)
		sfx_players.append(player)

	play_music()


func _ensure_bus(bus_name: StringName, volume_db: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		AudioServer.add_bus(AudioServer.get_bus_count())
		bus_index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(bus_index, bus_name)
		AudioServer.set_bus_send(bus_index, &"Master")
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func _assign_looping_music() -> void:
	var looped_stream = MUSIC_STREAM.duplicate()
	if looped_stream is AudioStreamWAV:
		looped_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		looped_stream.loop_begin = 0
		looped_stream.loop_end = int(looped_stream.get_length() * looped_stream.mix_rate)
	music_player.stream = looped_stream


func play_music() -> void:
	if music_player == null or music_player.playing:
		return
	music_player.play()


func stop_music() -> void:
	if music_player != null and music_player.playing:
		music_player.stop()


func play_sfx(name: StringName) -> void:
	if not SFX_STREAMS.has(name) or sfx_players.is_empty():
		return

	var player := sfx_players[next_sfx_player]
	next_sfx_player = (next_sfx_player + 1) % sfx_players.size()
	player.stop()
	player.stream = SFX_STREAMS[name]
	player.play()

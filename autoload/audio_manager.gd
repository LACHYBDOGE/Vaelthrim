class_name AudioManagerClass
extends Node

## Sound and music control system.
## Handles all audio playback, volume control, and audio buses.

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const AMBIENCE_BUS := "Ambience"
const UI_BUS := "UI"

# Audio players
var _music_player: AudioStreamPlayer
var _ambience_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []

const MAX_SFX_PLAYERS := 16

# Current track info
var _current_music: AudioStream
var _current_ambience: AudioStream

# Fade settings
var _music_fade_tween: Tween
var _ambience_fade_tween: Tween

signal music_changed(track: AudioStream)
signal ambience_changed(track: AudioStream)


func _ready() -> void:
	_setup_audio_players()


func _setup_audio_players() -> void:
	# Music player
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = MUSIC_BUS
	add_child(_music_player)

	# Ambience player
	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.bus = AMBIENCE_BUS
	add_child(_ambience_player)

	# SFX player pool
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		_sfx_players.append(player)


# --- Music ---

func play_music(track: AudioStream, fade_duration: float = 1.0) -> void:
	if track == _current_music and _music_player.playing:
		return

	_current_music = track

	if _music_fade_tween:
		_music_fade_tween.kill()

	if fade_duration > 0 and _music_player.playing:
		# Fade out current, then fade in new
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(_music_player, "volume_db", -40.0, fade_duration * 0.5)
		_music_fade_tween.tween_callback(_start_new_music.bind(track, fade_duration * 0.5))
	else:
		_music_player.stream = track
		_music_player.volume_db = 0.0
		_music_player.play()

	music_changed.emit(track)


func _start_new_music(track: AudioStream, fade_in_duration: float) -> void:
	_music_player.stream = track
	_music_player.volume_db = -40.0
	_music_player.play()

	_music_fade_tween = create_tween()
	_music_fade_tween.tween_property(_music_player, "volume_db", 0.0, fade_in_duration)


func stop_music(fade_duration: float = 1.0) -> void:
	if not _music_player.playing:
		return

	if _music_fade_tween:
		_music_fade_tween.kill()

	if fade_duration > 0:
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(_music_player, "volume_db", -40.0, fade_duration)
		_music_fade_tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()

	_current_music = null


# --- Ambience ---

func play_ambience(track: AudioStream, fade_duration: float = 2.0) -> void:
	if track == _current_ambience and _ambience_player.playing:
		return

	_current_ambience = track

	if _ambience_fade_tween:
		_ambience_fade_tween.kill()

	if fade_duration > 0 and _ambience_player.playing:
		_ambience_fade_tween = create_tween()
		_ambience_fade_tween.tween_property(_ambience_player, "volume_db", -40.0, fade_duration * 0.5)
		_ambience_fade_tween.tween_callback(_start_new_ambience.bind(track, fade_duration * 0.5))
	else:
		_ambience_player.stream = track
		_ambience_player.volume_db = 0.0
		_ambience_player.play()

	ambience_changed.emit(track)


func _start_new_ambience(track: AudioStream, fade_in_duration: float) -> void:
	_ambience_player.stream = track
	_ambience_player.volume_db = -40.0
	_ambience_player.play()

	_ambience_fade_tween = create_tween()
	_ambience_fade_tween.tween_property(_ambience_player, "volume_db", 0.0, fade_in_duration)


func stop_ambience(fade_duration: float = 2.0) -> void:
	if not _ambience_player.playing:
		return

	if _ambience_fade_tween:
		_ambience_fade_tween.kill()

	if fade_duration > 0:
		_ambience_fade_tween = create_tween()
		_ambience_fade_tween.tween_property(_ambience_player, "volume_db", -40.0, fade_duration)
		_ambience_fade_tween.tween_callback(_ambience_player.stop)
	else:
		_ambience_player.stop()

	_current_ambience = null


# --- SFX ---

func play_sfx(sound: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	var player := _get_available_sfx_player()
	if not player:
		push_warning("No available SFX player")
		return

	player.stream = sound
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()


func play_sfx_at_position(sound: AudioStream, position: Vector3, volume_db: float = 0.0) -> void:
	# For 3D positional audio - would need AudioStreamPlayer3D
	# For now, just play as 2D with volume falloff approximation
	play_sfx(sound, volume_db)


func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	# If all are busy, use the first one (oldest sound)
	return _sfx_players[0]


# --- Volume Control ---

func set_master_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(linear))


func set_music_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), linear_to_db(linear))


func set_sfx_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), linear_to_db(linear))


func set_ambience_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AMBIENCE_BUS), linear_to_db(linear))


func get_master_volume() -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))


func get_music_volume() -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS)))


func get_sfx_volume() -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(SFX_BUS)))

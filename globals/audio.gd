extends Node

const MUSIC_MAIN_MENU: AudioStream = preload("res://audio/music/Alc9_MainMenu.mp3")
const MUSIC_GAME: AudioStream = preload("res://audio/music/Alc9_GamePlayBackground.mp3")
const MUSIC_GAME_WON: AudioStream = preload("res://audio/music/Alc9_Win_Outro.mp3")
const MUSIC_GAME_OVER: AudioStream = preload("res://audio/music/Alc9_GameOver.mp3")

const SFX_UI_ACCEPT: AudioStream = preload("res://audio/sfx/ui_accept/SFX_ClickConfirmationOnev1.mp3")
const SFX_UI_CANCEL: AudioStream = preload("res://audio/sfx/ui_cancel/SFX_BackOptionOnev1.mp3")


@onready var sfx_player: AudioStreamPlayer = %SFX
@onready var music_player: AudioStreamPlayer = %Music


func _ready() -> void:
	sfx_player.play()


func play_sfx(stream: AudioStream) -> void:
	if sfx_player:
		var playback: AudioStreamPlaybackPolyphonic = sfx_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
		if playback:
			playback.play_stream(stream)


func play_music(stream: AudioStream, next_stream: AudioStream = null, from: float = 0.0) -> void:
	if music_player and (music_player.stream != stream or not music_player.playing):
		music_player.stream = stream
		music_player.play(from)
		if next_stream:
			await music_player.finished
			music_player.stream = next_stream
			music_player.play()
	
	
func stop_music() -> void:
	if music_player:
		music_player.stop()

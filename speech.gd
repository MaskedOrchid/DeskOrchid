extends MarginContainer

@onready var timer:= $sTimer
@onready var speech:=$MarginContainer/Label
@export var UTILS: Node

@onready var squeaker:=$AudioStreamPlayer2D

var phrases=[]
var squeaks=[]
var whatplaying=[]
var check=0
#setting up to get the timer loop
func _ready():
	phrases=UTILS.getCatchPhrases("General")
	loadsounds()
	timer.start()

func loadsounds():
	var dir = DirAccess.open("res://squeaks/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.get_file().ends_with(".wav.import"):
					#print("Found file: " + file_name)
					squeaks.append("res://squeaks/"+file_name)
			file_name = dir.get_next()
	

func getNewCatchPhrase():
	#reseting the phrases
	phrases=UTILS.getCatchPhrases("General")
	whatplaying=UTILS.getCanWatch()
	if(len(whatplaying)>0):
		for g in whatplaying:
			print(g)
			phrases+=UTILS.getCatchPhrases(g)


func _on_s_timer_timeout():
	#reseting catch phrases
	getNewCatchPhrase();
	#print(phrases)
	speech.text=phrases[randi_range(0,len(phrases)-1)]
	var file_name = squeaks[randi_range(0,len(squeaks)-1)].replace(".import", "")
	squeaker.stream=load(file_name)
	squeaker.play()
	timer.set_wait_time(randi_range(5, 10))
	timer.start()

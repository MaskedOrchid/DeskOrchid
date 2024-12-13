extends Node2D

@onready var Pet = $pet
@onready var squeaker=$AudioStreamPlayer2D
var squeaks=[]
@onready var petSprite = $pet/AnimatedSprite2D
@onready var petemitter=$pet/GPUParticles2D
@export var PetSize = Vector2i(512, 512)
@export var Scale=.75

@onready var _MainWindow: Window = get_window()
var screen_width: int
var taskbar_pos: int

var mouse_offset: Vector2 = Vector2.ZERO
var selected: bool = false

var walkDirect = true
var Speed = 200
var isWalking = false

func _ready():
	loadsounds()
	#changing the scale
	PetSize.x*=Scale
	PetSize.y*=Scale
	
	Pet.scale=Vector2(Scale,Scale)
	Pet.position.x*=Scale
	Pet.position.y=PetSize.y*.61
	
	# Calculate screen size and taskbar position
	screen_width = DisplayServer.screen_get_usable_rect().size.x
	taskbar_pos = DisplayServer.screen_get_usable_rect().size.y - PetSize.y
	
	# Change the size of the window
	_MainWindow.min_size = PetSize
	_MainWindow.size = _MainWindow.min_size
	# Places the character in the middle of the screen and on top of the taskbar
	_MainWindow.position = Vector2i(DisplayServer.screen_get_size().x / 2 - PetSize.x / 2, taskbar_pos - PetSize.y)
	_MainWindow.position = Vector2i(clamp_on_screen_width(_MainWindow.position.x,PetSize.x), taskbar_pos) 
	#print(screen_width)

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

func _process(delta):
	if Input.is_action_just_pressed("pet"):
		if !squeaker.is_playing():
			var file_name = squeaks[randi_range(0,len(squeaks)-1)].replace(".import", "")
			squeaker.stream=load(file_name)
			squeaker.play()
			petemitter.emitting=true
	if selected:
		follow_mouse()
	if isWalking:
		# Check for edge collision
		if _MainWindow.position.x >= (screen_width - PetSize.x):
			#print("Switching to left")
			walkDirect = true
			petSprite.flip_h = false
		elif _MainWindow.position.x <= 0:
			#print("Switching to Right")
			walkDirect = false
			petSprite.flip_h = true
			
		#moving the pet
		if(walkDirect):
			#print("walking Left")
			_MainWindow.position.x = _MainWindow.position.x+Speed * delta * -1
			_MainWindow.position.x = clamp_on_screen_width(_MainWindow.position.x,PetSize.x)
			#print(_MainWindow.position.x)
		else:
			#print("walking Right")
			_MainWindow.position.x = _MainWindow.position.x+Speed * delta
			_MainWindow.position.x = clamp_on_screen_width(_MainWindow.position.x,PetSize.x)
			#print(_MainWindow.position.x)
	move_pet()

func follow_mouse():
	#Follows mouse cursor but clamps it on the taskbar
	_MainWindow.position = Vector2i(clamp_on_screen_width((get_global_mouse_position().x + mouse_offset.x),PetSize.x), taskbar_pos) 

func move_pet():
	#On right click and hold it will follow the pet and when released
	#it will stop following
	if Input.is_action_pressed("move"):
		selected = true
		mouse_offset = _MainWindow.position - Vector2i(get_global_mouse_position()) 
	if Input.is_action_just_released("move"):
		selected = false

func clamp_on_screen_width(pos, player_width):
	return clamp(pos, 0, screen_width - player_width)

func newDirection():
	if randi_range(1, 2) == 1:
		walkDirect = false
		petSprite.flip_h = true
	else:
		walkDirect = true
		petSprite.flip_h = false

func _on_pet_done_walking():
	isWalking = false

func _on_pet_walking():
	isWalking = true
	newDirection()


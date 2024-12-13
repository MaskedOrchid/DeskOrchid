extends Node2D

#This script will control the current state and behavoir of the pet
@onready var animTree : AnimationTree= $AnimationPlayer/AnimationTree
var animState
@onready var timer = $pTimer
@onready var wtimer=$wTimer
@onready var utils =$Utils
@onready var speechbubble=$TextBox
var orgpos;
var watchpos;

var phrases=[]
#the states of the pet
var state : int = 0
#what the pet can currently watch
var playingnow=[]
#signals to send when entering and leaving states
signal walking
signal doneWalking




# Called when the node enters the scene tree for the first time.
func _ready():
	animTree.active=true
	animTree["parameters/conditions/is_idle"]=true
	animTree["parameters/conditions/is_walking"]=false
	animTree["parameters/conditions/is_watching"]=false
	orgpos=speechbubble.position;
	watchpos=speechbubble.position;
	watchpos.y=-100;
	timer.start()
	wtimer.start()

func changeState():
	#this function changes the state of the pet
	#can't idle back to back
	#checking if I can watch the screen
	var newstate=null
	var lowerboun=0
	#making sure we do not get idle twice
	if(state==0):
		lowerboun=1
	#if we can watch or not
	if(len(playingnow)>0):
		newstate =randi_range(lowerboun,2)
		#making sure it does not sleep twice
		if(state==2 and newstate==2):
			newstate=1
	elif(len(playingnow)==0 ):
		newstate =randi_range(lowerboun,1)
		#making sure it does not sleep twice
		if(state==2 and newstate==2):
			newstate=1
	state=newstate
	if(state==1):
		walking.emit()
	

func _on_p_timer_timeout():
	#when the timer times out
	var waswalking=false
	if(state==1):
		waswalking=true
	#changing states
	await changeState()
	#Reseting the timer
	if(state==0):
		#print("Idling")
		animTree["parameters/conditions/is_idle"]=true
		animTree["parameters/conditions/is_walking"]=false
		animTree["parameters/conditions/is_watching"]=false
		timer.set_wait_time(randi_range(10, 25))
		speechbubble.position=orgpos;
	elif(state==1):
		#print("Walking")
		animTree["parameters/conditions/is_idle"]=false
		animTree["parameters/conditions/is_walking"]=true
		animTree["parameters/conditions/is_watching"]=false
		timer.set_wait_time(randi_range(10, 15))
		speechbubble.position=orgpos;
	elif(state==2):
		#print("Watching")
		animTree["parameters/conditions/is_idle"]=false
		animTree["parameters/conditions/is_walking"]=false
		animTree["parameters/conditions/is_watching"]=true
		timer.set_wait_time(randi_range(60, 120))
		speechbubble.position=watchpos;
	if(state!=1 and waswalking):
		doneWalking.emit()
	#print("Wait Time: ")
	#print(timer.wait_time)
	timer.start()


func _on_w_timer_timeout():
	#checks to see if we can watch anything every five minutes if nothing is playing, 
	#else it will wait 10 minutes before checking
	if(len(playingnow)==0):
		utils.getWhatPlaying()
		playingnow=utils.getCanWatch()
		wtimer.set_wait_time(300)
	else:
		wtimer.set_wait_time(600)
	wtimer.start()

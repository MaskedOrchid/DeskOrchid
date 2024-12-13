extends Node


#the array listing the possible games to watcj
var posgames=[]
var canWatch=[]
var configList=[]
#a dict of catch phrases to say
var catchPhrases={}
func _ready():
	parseGameConfig()
	
func parseGameConfig():
	var file=FileAccess.open("res://GameConfig.txt",FileAccess.READ)
	#parsing config file into an array for faster access
	while file.get_position() < file.get_length():
		configList.append(file.get_line())
	#print(configList)
	#Getting games and that one general phrases
	for line in configList:  
		if("games: " in line):
			var templine=line.replace("games: ","")
			templine=templine.replace("\n", "")
			posgames=templine.split(",")
		elif("phrases: " in line):
			var templine=line.replace("phrases: ","")
			templine=templine.replace("\n", "")
			catchPhrases["General"]=templine.split(",")
		
	#parsing out game specific phrases
	for line in configList: 
		for g in posgames:
			if(g+"comments: " in line):
				var templine=line.replace(g+"comments: ","")
				templine=templine.replace("\n", "")
				catchPhrases[g]=templine.split(",")
	
func getWhatPlaying():
	canWatch=[]
	# Verify that we are on Windows
	if OS.get_name() == "Windows": 
		#running an OS command to get the list of processes running
		var output = []
		for g in posgames:
			#Running a Commandline function to see if a possible game is running

			var checker=OS.execute('powershell.exe', ['-Command', "Get-Process -Name "+g],output,false,false)
			#print(output)
			#print(checker)
			if(checker==0 and len(output)<=1):
				#if the commandline function does not error, meaning that it found a process with the game's name
				canWatch.append(g)
	
func getCanWatch():
	return canWatch

func getCatchPhrases(game):
	#returns the catch phrases for a certain game
	if(catchPhrases.has(game)):
		return catchPhrases[game]
	else:
		return null

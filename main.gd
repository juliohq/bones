extends Spatial

signal roll_phase_begin
signal roll_phase_end
signal target_phase_begin
signal target_phase_end
signal combat_phase_begin
signal combat_phase_end


var rerolls: int = 2
var round_num: int = 1
var turn_owner: bool = false # if true player turn, false: enemy
var turn_phase: int = 0 # 
var roll_phase: bool = false
var target_phase: bool = false
var combat_phase: bool = false

onready var units = $Units
onready var players = get_node("Units/PlayerUnits")
onready var enemies = get_node("Units/EnemyUnits")

func _ready() -> void:
	setup_signals()
	emit_signal("roll_phase_begin")

func _physics_process(delta: float) -> void:
	units.turn_label.text = "Player Turn" if turn_owner else "Enemy Turn"
	units.phase_label.text = "Phase: Roll" if roll_phase else "Phase: Target" if target_phase else "Phase: Combat"
	$Button.visible = true if turn_owner else false

func _on_Button_pressed() -> void:
	set_reroll(1)
	var dice = get_tree().get_nodes_in_group("die")
	for die in dice:
		die.set_gravity_scale(4)
		die.apply_impulse(die.translation, Vector3(randi() % 5 + .5,randi() % 5 + .5,randi() % 5 + .5))

func set_reroll(amount) -> void:
	rerolls -= amount
	if rerolls <= 0:
		$Button.set_disabled(true)
		rerolls = 0
#		emit_signal("roll_phase_end")

func _on_Roll_Phase_Begin():
	print("Entering ROLL PHASE")
	roll_phase = true
	if turn_owner:
		for i in players.get_children():
			i.enter_roll_phase()
	else:
		for i in enemies.get_children():
			i.enter_roll_phase()
			yield(get_tree().create_timer(4.0), "timeout")
			emit_signal("roll_phase_end")

func _on_Roll_Phase_End():
	print("EXITING ROLL PHASE")
	if turn_owner:
		for i in players.get_children():
			if !i.selected:
				i._on_Selected(i.get_child(2).actions[i.get_child(2).roll])
		rerolls = 0
	else:
		for i in enemies.get_children():
			i._on_Selected(i.get_child(2).actions[i.get_child(2).roll])
		rerolls = 3
	roll_phase = false
	emit_signal("target_phase_begin")

func _on_targetPhase_begin():
	print("ENTERING TARGET PHASE")
	target_phase = true
	if turn_owner:
		var characters = []
		for i in players.get_children():
			print("in here")
			if i.face_choice.name != "Miss":
				characters.append(i)
			else:
				i.emit_signal("target_selected", false)
		for j in characters:
			units.current_attacker = j
			print("SELECTING TARGET FOR: ", j.name)
			j.choose_target()
			yield(units, "target_picked")
			j.set_selected(false)
		
	if !turn_owner:
		for i in enemies.get_children():
			if i.face_choice.name != "Miss":
				i.choose_target()
#			else:
#				i.emit_signal("target_selected", false)
#		turn_owner = !turn_owner
	emit_signal("target_phase_end")

func _on_targetPhase_end():
	print("EXITING TARGET PHASE")
	target_phase = false
	if turn_owner:
		emit_signal("combat_phase_begin")
	else:
		turn_owner = !turn_owner
		emit_signal("roll_phase_begin")

func _on_combatPhase_begin():
	print("ENTERING COMBAT PHASE")
	combat_phase = true
	if turn_owner:
		var characters = []
		for i in players.get_children():
			if i.target:
				characters.append(i)
		for j in characters:
			if !j.disabled:
				j.action()
				yield(get_tree().create_timer(2.0), "timeout")
		turn_owner = !turn_owner
		emit_signal("combat_phase_begin")
	else:
		for j in enemies.get_children():
			if j.target && !j.disabled:
				j.action()
				yield(get_tree().create_timer(2.0), "timeout")
		emit_signal("combat_phase_end")

func _on_combatPhase_end():
	print("EXITING COMBAT PHASE")
	round_num +=1
	rerolls = 2
	turn_owner = false
	units.enemy_actions_selected = 0
	units.player_actions_selected = 0
	$Button.set_disabled(false)
	# reset actions
	# increase round num
	for i in units.unit_refs:
		i.reset()
	combat_phase = false
	if check_for_win():
		$Label.visible = true
		set_pause_mode(true)
	else:
		emit_signal("roll_phase_begin")
	
func _on_ActionsSelected():
	if !turn_owner:
		yield(get_tree().create_timer(1.0), "timeout")
	emit_signal("roll_phase_end")

func setup_signals():
	connect("roll_phase_begin", self, "_on_Roll_Phase_Begin")
	connect("roll_phase_end", self, "_on_Roll_Phase_End")	
	connect("target_phase_end", self, "_on_targetPhase_end")
	connect("target_phase_begin", self, "_on_targetPhase_begin")
	connect("combat_phase_begin", self, "_on_combatPhase_begin")
	connect("combat_phase_end", self, "_on_combatPhase_end")
	units.connect("actions_selected", self, "_on_ActionsSelected")


func check_for_win():
	for i in enemies.get_children():
		if !i.disabled:
			return false
	return true
		

extends RigidBody2D

#
# Electric Tower
#

var global

var time = 0.0
var level = 1
var level_max = 3
var fire_delta = 1.0/10.0
var fire_next = 0.0
var fire_range = 120
var enemy_at_range = 0
var enemy_direction = Vector2(0,-1)
var damage = [ 0, 1, 2, 3 ]

var upgrade_cost = [0, 5, 10, 15]
var sell_price = [0, 2, 5, 8]

const ammunition = "res://bullet.scn"


func _ready():
	global = get_node("/root/global")
	set_fixed_process(true)
	if global.debug:
		# Show fire range
		var f_range = get_node("FireRange")
		f_range.set_scale(Vector2(fire_range/100.0, fire_range/100.0))
		f_range.show()


func _fixed_process(delta):
	time += delta
	#if enemy_at_range > 0:
	fire()


func get_sell_price():
	return sell_price[level]


func sell():
	global.cash += sell_price[level]
	queue_free()


func get_upgrade_cost():
	return upgrade_cost[level]


func upgrade():
	if level < level_max and global.cash >= upgrade_cost[level]:
		global.cash -= upgrade_cost[level]
		level += 1
		var sprite = get_node("Sprite")
		var hframes = sprite.get_hframes()
		sprite.set_frame(hframes * (level-1 ))
		print(get_name(), " upgraded to level ", level)


func choose_target():
	var target = null
	var pos = get_global_pos()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if pos.distance_to(enemy.get_global_pos()) <= fire_range:
			if target == null or enemy.get_global_pos().x > target.get_global_pos().x:
				target = enemy
	return target


func fire():
	if time > fire_next:
		var ray = get_node("ParticlesRay")
		var target_enemy = choose_target()
		if target_enemy == null:
			ray.set_emitting(false)
			return
		var ray_direction = (target_enemy.get_global_pos() - get_global_pos()).normalized()
		var rad_angle = atan2(ray_direction.x, ray_direction.y) + atan2(0, -1)
		var angle = (180 + int(rad_angle * global.DEG_PER_RAD)) % 360
		ray.set_param(Particles2D.PARAM_DIRECTION, angle)
		ray.set_emitting(true)
		get_node("ParticlesRay/RayAttractor").set_global_pos(target_enemy.get_global_pos())
		target_enemy.hit(damage[level], true)
		fire_next = time + fire_delta


func _on_body_enter(body):
	#print("Body enter " + str(body))
	if body.is_in_group("enemy"):
		#get_node("ParticlesRay").set_emitting(true)
		enemy_at_range += 1


func _on_body_exit(body):
	#print("Body exit " + str(body))
	if body.is_in_group("enemy"):
		enemy_at_range -= 1

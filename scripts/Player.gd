extends KinematicBody

export(bool) var verbose
export(NodePath) var animation_tree_path
export(NodePath) onready var camera = get_node(camera)

onready var _animation_tree = get_node(animation_tree_path)
var gravity = Vector3.ZERO

var cumulative = 0

func _physics_process(delta):
	var root_motion : Transform = _animation_tree.get_root_motion_transform()
	var v = root_motion.origin / delta

	if is_on_floor():
		gravity = Vector3.ZERO
	else:
		gravity += Vector3(0, -9.83, 0) * delta
	v += gravity

	var dir : Vector3 = Vector3.ZERO

	if Input.is_action_pressed("forward"):
		dir.z += 1.0
	elif Input.is_action_pressed("backward"):
		dir.z -= 1.0
	elif Input.is_action_pressed("left"):
		dir.x += 1.0
	elif Input.is_action_pressed("right"):
		dir.x -= 1.0

	if dir.length_squared() > 0.01:
		dir = dir.rotated(Vector3.UP, camera.setup.rotation.y)

		var player_heading_2d := Vector2(self.transform.basis.z.x, self.transform.basis.z.z)
		var desired_heading_2d := Vector2(dir.x, dir.z)

		var phi : float = desired_heading_2d.angle_to(player_heading_2d)
		phi = phi * delta * 3.0
		self.rotation.y += phi
		v = v.rotated(Vector3.UP, self.rotation.y)

		if Input.is_action_pressed("sprint"):
			_animation_tree["parameters/playback"].travel("Running")
		else:
			_animation_tree["parameters/playback"].travel("Walking")
	else:
		v = v.rotated(Vector3.UP, self.rotation.y)
		_animation_tree["parameters/playback"].travel("Idle")

	_animation_tree["parameters/conditions/jump"] = Input.is_action_pressed("jump")

	move_and_slide(v, Vector3.UP)

	cumulative += delta
	if cumulative > 0.2:
		cumulative -= 0.2
		if verbose:
			print("root motion transform origin:", root_motion.origin)

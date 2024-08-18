extends CharacterBody2D


const SPEED = 50
const ROLLSPEED = 200
const ROTATIONSPEED = 90


var rolling = false
var rollingRight
var rollingTime = 0.75
var rollingTimer = 0

var relMouseVec
var lookVec
var AngleLookMouse

@export var AimRotation : Node2D
@export var AimLine : Line2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	rollingTimer -= delta
	AimLine.hide()
	#print(rad_to_deg( rotation))
	#print(rotation_degrees)
	# ROLLING MOVEMENT
	if rolling:
		if rollingRight:
			$AnimatedSprite2D.play("RollR")
			velocity.x = ROLLSPEED * cos(rotation + PI/2)
			velocity.y = ROLLSPEED * sin(rotation + PI/2)
		else:
			$AnimatedSprite2D.play("RollL")
			velocity.x = -ROLLSPEED * cos(rotation + PI/2)
			velocity.y = -ROLLSPEED * sin(rotation + PI/2)
			
		if rollingTimer < 0:
			rolling = false
			velocity = Vector2(0,0)
	
	elif Input.is_action_pressed("Aim"):
		velocity = Vector2(0,0)
		$AnimatedSprite2D.play("Aim")
		
		# LASER
		AimLine.show()
		var hitVec = to_local(AimRotation.get_child(0).get_collision_point()) - \
		AimRotation.get_child(0).position
		var vLength = sqrt(pow(hitVec.x, 2) + pow(hitVec.y, 2))
		#print($Line2D/RayCast2D.get_collision_point())
		AimLine.points[1].x = vLength
		
		
		# AIM RESTRICTIONS
		AimLine.rotation = AimRotation.rotation + rotation
		AimLine.position =  AimRotation.global_position
		AimRotation.look_at(get_global_mouse_position())
		
		
		if AimRotation.rotation < -PI/4:
			AimRotation.rotation = -PI/4
		elif AimRotation.rotation > PI/4:
			AimRotation.rotation = PI/4
		
		# SET AIM FRAME BASED ON ROTATION
		if AimRotation.rotation < -0.6:
			$AnimatedSprite2D.set_frame_and_progress(0, 0.0)
		elif AimRotation.rotation > 0.6:
			$AnimatedSprite2D.set_frame_and_progress(4, 0.0)
		elif AimRotation.rotation < -0.3:
			$AnimatedSprite2D.set_frame_and_progress(1, 0.0)
		elif AimRotation.rotation > 0.3:
			$AnimatedSprite2D.set_frame_and_progress(3, 0.0)
		else:
			$AnimatedSprite2D.set_frame_and_progress(2, 0.0)
		
		
		# ROLLING INPUT + DIRECTION
		if Input.is_action_just_pressed("Right") && Input.is_action_pressed("Shift") && \
		rollingTimer < 0:
			rolling = true
			rollingTimer = rollingTime
			if rotation_degrees > 30 && rotation_degrees < 150:
				rollingRight = false
			else:
				rollingRight = true
		elif Input.is_action_just_pressed("Left") && Input.is_action_pressed("Shift") && \
		rollingTimer < 0:
			rolling = true
			rollingTimer = rollingTime
			if rotation_degrees > 30 && rotation_degrees < 150:
				rollingRight = true
			else:
				rollingRight = false
	else:
		# MOVE v ^
		if Input.is_action_pressed("Forward"):
			# MOVE FASTER WITH SHIFT
			if Input.is_action_pressed("Shift"):
				velocity.x = SPEED * 2 * cos(rotation)
				velocity.y = SPEED * 2 * sin(rotation)
				$AnimatedSprite2D.play("CrawlFast")
			else:
				velocity.x = SPEED * cos(rotation)
				velocity.y = SPEED * sin(rotation)
				$AnimatedSprite2D.play("Crawl")
		elif Input.is_action_pressed("Backward"):
			velocity.y = -SPEED * 0.75 * sin(rotation)
			velocity.x = -SPEED * 0.75 * cos(rotation)
			$AnimatedSprite2D.play("CrawlBack")
		else:
			velocity = Vector2(0,0)
		
		# LOCK ROTATION IF HITTING WALL
		var lockLeft = false
		var lockRight = false
		
		if ($CollisionShape2D/rotateCheckBL.is_colliding() || \
		$CollisionShape2D/rotateCheckBL2.is_colliding() || \
		$CollisionShape2D/rotateCheckBL3.is_colliding()) && \
		($CollisionShape2D/rotateCheckTR.is_colliding() || \
		$CollisionShape2D/rotateCheckTR2.is_colliding() || \
		$CollisionShape2D/rotateCheckTR3.is_colliding()):
			lockRight = true
			print("lockright")
		if ($CollisionShape2D/rotateCheckBR.is_colliding() || \
		$CollisionShape2D/rotateCheckBR2.is_colliding() || \
		$CollisionShape2D/rotateCheckBR3.is_colliding()) && \
		($CollisionShape2D/rotateCheckTL.is_colliding() || \
		$CollisionShape2D/rotateCheckTL2.is_colliding() || \
		$CollisionShape2D/rotateCheckTL3.is_colliding()):
			lockLeft = true
			print("lockleft")
		
		# ROTATION
		if Input.is_action_pressed("Left") && !lockLeft:
			rotation -= deg_to_rad(ROTATIONSPEED) * delta
			if !Input.is_action_pressed("Forward") && !Input.is_action_pressed("Backward"):
				$AnimatedSprite2D.play("Crawl")
			#elif $AnimatedSprite2D.animation != "Crawl" || $AnimatedSprite2D.animation != "CrawlBack" || $AnimatedSprite2D.animation != "CrawlFast":
			#$AnimatedSprite2D.play("Crawl")
		elif Input.is_action_pressed("Right") && !lockRight:
			rotation += deg_to_rad(ROTATIONSPEED) * delta
			if !Input.is_action_pressed("Forward") && !Input.is_action_pressed("Backward"):
				$AnimatedSprite2D.play("Crawl")
			#elif $AnimatedSprite2D.animation != "Crawl" || $AnimatedSprite2D.animation != "CrawlBack" || $AnimatedSprite2D.animation != "CrawlFast":
			#$AnimatedSprite2D.play("Crawl")
		lockLeft = false
		lockRight = false
		# IDLE UPON NO INPUT
		if !Input.is_action_pressed("Forward") && !Input.is_action_pressed("Backward") && \
		!Input.is_action_pressed("Left") && !Input.is_action_pressed("Right"):
			$AnimatedSprite2D.play("Idle")
	
	
		
	move_and_slide()
	

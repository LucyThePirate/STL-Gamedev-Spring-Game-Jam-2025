extends Area2D

@export var speed: float = 800.0
@export var damage: int = 30
var direction: Vector2 = Vector2.RIGHT


func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta


func setup(direction_vector: Vector2) -> void:
	direction = direction_vector
	rotation = direction.angle()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  #or ghost
		if body.has_method("get_hit"):
			body.get_hit(damage)
	queue_free()

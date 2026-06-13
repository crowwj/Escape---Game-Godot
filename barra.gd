extends Area3D

func _ready():
	# Conectamos la señal de colisión por código para que sea más fácil
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verificamos si el objeto que tocó la barra tiene la función para reaparecer
	if body.has_method("reaparecer"):
		body.reaparecer()

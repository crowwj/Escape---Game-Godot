extends StaticBody3D

@export var nombre_del_boton: String = "Run"

func _ready():
	if has_node("Label3D"):
		$Label3D.text = nombre_del_boton
	add_to_group("botones_acertijo")

func presionar():
	print("¡Botón presionado! Intentando activar: ", nombre_del_boton)
	
	# Buscamos al controlador (el que tiene el script de la puerta)
	var controladores = get_tree().get_nodes_in_group("controladores")
	if controladores.size() > 0:
		controladores[0].verificar_secuencia(nombre_del_boton)
	else:
		print("ERROR: No encontré ningún nodo en el grupo 'controladores'")
	
	# Animación de hundirse
	position.z -= 0.05
	await get_tree().create_timer(0.2).timeout
	position.z += 0.05

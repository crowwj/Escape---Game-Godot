extends Node3D

#Abrir puerta
@export var puerta_a_abrir: Node3D
# Esta es la secuencia que el jugador debe seguir
var secuencia_correcta = ["INPUT", "READ", "PROCESS", "CHECK", "RUN"]
var indice_actual = 0

func verificar_secuencia(nombre_presionado):
	# Si el botón presionado es el que toca en el orden correcto
	if nombre_presionado == secuencia_correcta[indice_actual]:
		indice_actual += 1
		print("Correcto, vamos por el paso: ", indice_actual)
		
		# Si llegamos al final (el paso 5)
		if indice_actual == secuencia_correcta.size():
			print("¡Secuencia completada! Abriendo puerta...")
			abrir_puerta()
	else:
		# Si se equivoca, reiniciamos el contador a 0
		print("Error, secuencia reiniciada.")
		indice_actual = 0


func abrir_puerta():
	var pared = get_node("../ParedFalsa")
	if pared:
		pared.visible = false
		var colision = pared.get_node_or_null("CollisionShape3D")
		if colision:
			colision.disabled = true
	print("¡ParedFalsa desactivada!")

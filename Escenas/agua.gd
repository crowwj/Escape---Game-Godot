extends CSGBox3D

var tiempo : float = 0.0

func _process(delta: float) -> void:
	tiempo += delta
	
	# Buscamos el material ya sea en el override o en el material base
	var mat = material_override if material_override else material
	
	if mat and mat is StandardMaterial3D:
		# Desplazamos directamente el mapeo de la textura del Normal Map (ondas)
		mat.uv1_offset = Vector3(tiempo * 0.01, tiempo * 0.005, 0)

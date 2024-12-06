@tool
extends Node3D

@export_category("Face")
@export_range(0, 9, 1) var face_var: int = 0  #얼 모양 인덱스
@export var face_grid_size: int = 8  # 8x8 그리드 크기
@export var face_uv_size: Vector2
var material_face : ShaderMaterial  # ShaderMaterial로 명시적으로 정의
@export var FaceMesh : MeshInstance3D
var face_uv_offset

func _ready() -> void:
	print('FaceMesh, ', FaceMesh.get_surface_override_material_count())

func _process(delta: float) -> void:
	material_face = FaceMesh.get_surface_override_material(0)
	#_set_uv_offset_in_mouth_tres()
	material_face.set_shader_parameter('_MainTex_ST', Vector4(0.333,2.96,(1.0/9.0) *face_var, 0))
	
func _set_uv_offset_in_mouth_tres():
	# mouth_var 값을 바탕으로 UV 오프셋 계산
	var column = face_var % face_grid_size
	var row = face_var / face_grid_size
	face_uv_offset = Vector2(column * face_uv_size.x, row * face_uv_size.y)

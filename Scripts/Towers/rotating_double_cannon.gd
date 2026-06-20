extends RotatingTowers

@export var canon_offset = 25.0

func offset_canon():
	canon_offset = abs(canon_offset) if canon_offset < 0 else -abs(canon_offset)
	return canon_offset

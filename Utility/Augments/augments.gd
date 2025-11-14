extends Resource
class_name Augments

@export var title: title_types
@export var value: float

enum title_types {
	ATTACK_SPEED,
	ATTACK_DAMAGE,
	HEALTH
}

func find_title():
	var title: String
	match title_types:
		0:
			title = "Attack Speed Upgrade"
		1:
			title = "Attack Damange Upgrade"
		2:
			title = "Health Upgrade"
	return title

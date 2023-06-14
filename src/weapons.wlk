class Weapon {
	method attack(damageEntity)	
}

object nullWeapon inherits Weapon {
	override method attack(damageEntity) {}
}

class MeleeWeapon inherits Weapon {
	override method attack(damageEntity) {
		
	}
}
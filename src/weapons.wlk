import Global.*

class Weapon {
	method attack(dealer)	
}

object nullWeapon inherits Weapon {
	override method attack(dealer) {}
}

class MeleeWeapon inherits Weapon {
	override method attack(dealer) {
		const facingDirection = dealer.movementController().facingDirection()
		const colliders = facingDirection.collisionsFrom(dealer.position().x(), dealer.position().y())
		colliders.forEach {
			collider => 
				if(global.isEnemy(collider)) { dealer.damageManager().dealDmg(collider) }
		}
	}
}
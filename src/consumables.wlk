import Entities.GravityEntity
import Global.*
import gameConfig.*

class Consumable inherits GravityEntity(initialY = gameConfig.yMiddle() + 2, initialX = gameConfig.xMiddle()) {
	
	method consumedBy(player)
		
	override method onCollision(collider) {
		if(collider == global.player()) {
			self.consumedBy(collider)
			self.onRemove()
		}
	}
	
}

class DamageModifierConsumable inherits Consumable {
	const damage
	
	override method consumedBy(player) {
		console.println(player.damage())
		player.addDamage(damage)
		console.println(player.damage())
	}
}

class LifeModifier inherits Consumable {
	const healing
	
	override method consumedBy(player) {
		console.println(player.hp())
		player.heal(healing)
		console.println(player.hp())
	}
}

class Mate inherits DamageModifierConsumable(damage = 10, baseImageName = "consumible-mate"){}

class CanioncitoDDL inherits LifeModifier(healing = 20, baseImageName = "consumible-cañoncito")
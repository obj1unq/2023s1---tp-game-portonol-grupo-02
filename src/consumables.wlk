import Entities.GravityEntity
import Global.*
import gameConfig.*

class Consumable inherits GravityEntity(initialY = gameConfig.yMiddle() + 2, initialX = gameConfig.xMiddle()) {
	const forRoom
	
	method consumedBy(player) {
		forRoom.removeConsumable(self)
	}
		
	override method onCollision(collider) {
		if(collider == global.player()) {
			self.consumedBy(collider)
			self.onRemove()
		}
	}
	
}

object nullishConsumable inherits Consumable(gravity = null, forRoom = null) {
	override method consumedBy(player){}
	override method onAttach() {}
	override method onRemove() {}
}

class DamageModifierConsumable inherits Consumable {
	const damage
	
	override method consumedBy(player) {
		super(player)
		player.addDamage(damage)
	}
}

class LifeModifier inherits Consumable {
	const healing
	
	override method consumedBy(player) {
		super(player)
		player.heal(healing)
	}
}

class Mate inherits DamageModifierConsumable(damage = 10, baseImageName = "consumible-mate"){}

object mateFactory {
	method getConsumable(forRoom) {
		return new Mate(forRoom = forRoom, gravity = global.gravity())
	}
}

class CanioncitoDDL inherits LifeModifier(healing = 20, baseImageName = "consumible-cañoncito"){}

object canioncitoDDLFactory {
	method getConsumable(forRoom) {
		return new CanioncitoDDL(forRoom = forRoom, gravity = global.gravity())
	}
}

class consumableFactory {
	method getConsumable(forRoom)
}
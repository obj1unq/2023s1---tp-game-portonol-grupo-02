import Entities.GravityEntity
import Global.*
import gameConfig.*
import SoundEffect.itemPickedUpEffect
import transitionManager.Transition
import transitionManager.transitionManager

class Consumable inherits GravityEntity(initialY = gameConfig.yMiddle() + 2, initialX = gameConfig.xMiddle()) {
	const forRoom
	
	method consumedBy(player) {
		forRoom.removeConsumable(self)
		self.playPickupAnimation()
		itemPickedUpEffect.play()
	}
	
	method playPickupAnimation() {}
		
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
	
	override method playPickupAnimation() {
		const transition = 
			new Transition(
					frames = [
						"mate-pickup-anim-1",
						"mate-pickup-anim-2",
						"mate-pickup-anim-3",
						"mate-pickup-anim-4",
						"mate-pickup-anim-5",
						"mate-pickup-anim-6",
						"mate-pickup-anim-7",
						"mate-pickup-anim-8",
						"mate-pickup-anim-8",
						"mate-pickup-anim-8",
						"mate-pickup-anim-8",
						"mate-pickup-anim-8",
						"mate-pickup-anim-8",
						"mate-pickup-anim-8",
						"mate-pickup-anim-8"
					],
				duration = 1200
			)
		transitionManager.play(transition)
		itemPickedUpEffect.play()
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
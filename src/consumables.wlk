import Entities.GravityEntity
import Global.*
import gameConfig.*
import transitionManager.Transition
import transitionManager.transitionManager
import wollok.game.*

class Consumable inherits GravityEntity(initialY = gameConfig.yMiddle() + 2, initialX = gameConfig.xMiddle()) {
	const forRoom
	
	method consumedBy(player) {
		forRoom.removeConsumable(self)
		self.playPickupAnimation()
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
						"mate-pickup-anim-9",
						"mate-pickup-anim-10",
						"mate-pickup-anim-11",
						"mate-pickup-anim-12",
						"mate-pickup-anim-13",
						"mate-pickup-anim-14",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16"
					],
				duration = 2000,
				sfx = game.sound("item-pickup-sound.mp3"),
				delay = 1000
			)
		transitionManager.play(transition)
		
	}
}

class LifeModifier inherits Consumable {
	const healing
	
	override method consumedBy(player) {
		super(player)
		player.heal(healing)
	}
	
	override method playPickupAnimation() {
		const transition = 
			new Transition(
					frames = [
						"canon-pickup-anim-1",
						"canon-pickup-anim-2",
						"canon-pickup-anim-3",
						"canon-pickup-anim-4",
						"canon-pickup-anim-5",
						"canon-pickup-anim-6",
						"canon-pickup-anim-7",
						"canon-pickup-anim-8",
						"canon-pickup-anim-9",
						"canon-pickup-anim-10",
						"canon-pickup-anim-11",
						"canon-pickup-anim-12",
						"canon-pickup-anim-13",
						"canon-pickup-anim-14",
						"canon-pickup-anim-15",
						"canon-pickup-anim-16",
						"canon-pickup-anim-15",
						"canon-pickup-anim-16",
						"canon-pickup-anim-15",
						"canon-pickup-anim-16",
						"canon-pickup-anim-15",
						"canon-pickup-anim-16"
					],
				duration = 2000,
				sfx = game.sound("item-pickup-sound.mp3"),
				delay = 1000
			)
		transitionManager.play(transition)
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
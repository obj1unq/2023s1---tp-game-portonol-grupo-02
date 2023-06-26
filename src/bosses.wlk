import Entities.Slime
import pools.consumablesPool
import transitionManager.*
import Movement.CooldownMovementController
import pools.globalRemoveBehaviour
import wollok.game.*

// Por limitaciones del lenguaje, no hay interfaces. Usar esta clase como interfaz para 
// aprovecharse del polimorfismo que ofrece wollok

class IBoss {
	
	const bossRoom
	
	method spawnItem()
	
	method animation()
	
	method makeEntryAnimation() {
		transitionManager.play(self.animation())
	}
		
	/*
	 * override method die() {
	 * 
	 * 	self.spawnItem()
	 * 
	 * }
	 */
	
}

class SlimeTurret inherits Slime(baseImageName = "king-slime", removeBehaviour = globalRemoveBehaviour) /* implements IBoss */ {
	const bossRoom
	
	method animation() {
		return new Transition(duration = 2000, frames = [
			"kingSlimeScreen-1",
			"kingSlimeScreen-2",
			"kingSlimeScreen-3",
			"kingSlimeScreen-4",
			"kingSlimeScreen-5",
			"kingSlimeScreen-5"
		], sfx = game.sound("enter-boss.mp3"))
	}
	
	override method onAttach() {
		super()
		self.makeEntryAnimation()
	}
	
	method makeEntryAnimation() {
		transitionManager.play(self.animation())
	}
	
	method spawnItem() {
		const item = consumablesPool.getRandomItem(bossRoom)
		bossRoom.addConsumable(item)
		item.onAttach()
	}
	
	override method die() {
		super()
		self.spawnItem()
	}
	
}
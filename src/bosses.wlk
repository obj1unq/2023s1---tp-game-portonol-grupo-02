import Entities.Slime
import Entities.PingPongEnemyEntity
import pools.consumablesPool
import transitionManager.*
import Movement.CooldownMovementController
import pools.globalRemoveBehaviour
import wollok.game.*
import enemiesFactories.flyEnemyFactory
import CooldownManager.FlySpawnerCooldown

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

class LordOfFlies inherits PingPongEnemyEntity(baseImageName = "pingpongenemy", removeBehaviour = globalRemoveBehaviour) /* implements IBoss */ {
	const bossRoom
	const spawnCooldown = new FlySpawnerCooldown(entityFlySpawner = self)
	
	method animation() {
		return new Transition(duration = 1200, frames = [
			"kingSlimeScreen-1",
			"kingSlimeScreen-2",
			"kingSlimeScreen-3",
			"kingSlimeScreen-4",
			"kingSlimeScreen-5",
			"kingSlimeScreen-6",
			"kingSlimeScreen-7",
			"kingSlimeScreen-8",
			"kingSlimeScreen-9",
			"kingSlimeScreen-10",
			"kingSlimeScreen-11",
			"kingSlimeScreen-12"
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
	
	override method update(time) {
		super(time)
		spawnCooldown.onTimePassed(time)
	}
	
	method spawnFly() {
		const fly = flyEnemyFactory.generate(1, 1)
		fly.initialPositions(self.position().x(), self.position().y())
		bossRoom.addEnemy(fly)
	}
	
	override method die() {
		super()
		self.spawnItem()
	}
	
}

class SlimeTurret inherits Slime(baseImageName = "king-slime", removeBehaviour = globalRemoveBehaviour) /* implements IBoss */ {
	const bossRoom
	
	method animation() {
		return new Transition(duration = 1200, frames = [
			"kingSlimeScreen-1",
			"kingSlimeScreen-2",
			"kingSlimeScreen-3",
			"kingSlimeScreen-4",
			"kingSlimeScreen-5",
			"kingSlimeScreen-6",
			"kingSlimeScreen-7",
			"kingSlimeScreen-8",
			"kingSlimeScreen-9",
			"kingSlimeScreen-10",
			"kingSlimeScreen-11",
			"kingSlimeScreen-12"
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
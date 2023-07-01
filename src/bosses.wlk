import Entities.Slime
import Entities.EnemyDamageEntity
import Entities.PingPongEnemyEntity
import Entities.ChargeToPlayerEnemy
import pools.consumablesPool
import transitionManager.*
import Movement.CooldownMovementController
import pools.globalRemoveBehaviour
import wollok.game.*
import enemiesFactories.flyEnemyFactory
import CooldownManager.FlySpawnerCooldown
import LifeUI.LifeUI
import LifeUI.BossBarUI
import gameConfig.*
import pools.lordOfFliesPool
import SoundEffect.bossTheme
import SoundEffect.mainTheme

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
	 * override method onAttach() {
	 * 
	 *   self.makeEntryAnimation()
	 *	 lifeBar.render()
	 *   bossTheme.play()
	 * 
	 * }
	 * 
	 */
		
	/*
	 * override method onDamageTaken(newHP) {
	 *	  lifeBar.onDamageTaken(self)
	 * }
	 * 
	 */
		
		
	/*
	 * override method die() {
	 * 
	 * 	self.spawnItem()
	 * 	bossTheme.stop()
	 * 
	 * }
	 */
	
}

class DoubleBoss inherits EnemyDamageEntity(damage = null, maxHp = null, cooldown = null, gravity = null) {
	var leftBoss
	var rightBoss
	const bossRoom
	
	override method onAttach() {
		leftBoss.onAttach()
		rightBoss.onAttach()
		self.makeEntryAnimation()
		bossTheme.play()
		mainTheme.stop()
		self.setDeathCallbackForBosses()
	}
	
	method setDeathCallbackForBosses() {
		leftBoss.setDeathCallback {
			self.onBossDeath(leftBoss)
		}
		rightBoss.setDeathCallback{
			self.onBossDeath(rightBoss)
		}
	}
	
	method onBossDeath(boss) {
		
		if(leftBoss == boss) {
			leftBoss = null
		} else {
			rightBoss = null
		}
		
		self.checkIfBossesAreDead()
	}
	
	method checkIfBossesAreDead() {
		if(leftBoss == null and rightBoss == null) {
			self.die()
		}
	}
	
	method spawnItem() {
		const item = consumablesPool.getRandomItem(bossRoom)
		bossRoom.addConsumable(item)
		item.onAttach()
	}
	
	override method die() {
		super()
		self.spawnItem()
		bossTheme.stop()
		mainTheme.play()
	}
	
	method animation() {
		return new Transition(duration = 1200, frames = [
			"riderScreen-1",
			"riderScreen-2",
			"riderScreen-3",
			"riderScreen-4",
			"riderScreen-5",
			"riderScreen-6",
			"riderScreen-7",
			"riderScreen-8",
			"riderScreen-9",
			"riderScreen-10",
			"riderScreen-11",
			"riderScreen-12"
		], sfx = game.sound("enter-boss.mp3"))
	}
	
	override method onRemove() {
		deathCallback.apply()
	}
	
	method makeEntryAnimation() {
		transitionManager.play(self.animation())
	}
	
	override method hitSound() = null
	
}

class LordOfFlies inherits PingPongEnemyEntity(hp = 300, baseImageName = "lordofflies", velocity = 1.5, removeBehaviour = globalRemoveBehaviour) /* implements IBoss */ {
	const bossRoom
	const spawnCooldown = new FlySpawnerCooldown(entityFlySpawner = self)
	const lifeBar = new BossBarUI(startingPosition = gameConfig.width() - 3)
	
	method animation() {
		return new Transition(duration = 1200, frames = [
			"lordOfFliesScreen-1",
			"lordOfFliesScreen-2",
			"lordOfFliesScreen-3",
			"lordOfFliesScreen-4",
			"lordOfFliesScreen-5",
			"lordOfFliesScreen-6",
			"lordOfFliesScreen-7",
			"lordOfFliesScreen-8",
			"lordOfFliesScreen-9",
			"lordOfFliesScreen-10",
			"lordOfFliesScreen-11",
			"lordOfFliesScreen-12"
		], sfx = game.sound("enter-boss.mp3"))
	}
	
	override method onAttach() {
		super()
		self.makeEntryAnimation()
		bossTheme.play()
		mainTheme.stop()
		lifeBar.render()
	}
	
	method makeEntryAnimation() {
		transitionManager.play(self.animation())
	}
	
	override method onDamageTaken(newHP) {
		lifeBar.onDamageTaken(self)
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
		const fly = lordOfFliesPool.getEnemy()
		fly.initialPositions(self.position().x(), self.position().y())
		bossRoom.addEnemy(fly)
	}
	
	override method die() {
		super()
		self.spawnItem()
		bossTheme.stop()
		mainTheme.play()
	}
	
}

class Rider inherits ChargeToPlayerEnemy(velocityX = 10, velocityY = 5, hp = 300, baseImageName = "rider", removeBehaviour = globalRemoveBehaviour) /* implements IBoss */ {
	const intialXLifebarPosition = gameConfig.width() - 3
	const lifeBar = new BossBarUI(startingPosition = intialXLifebarPosition)
	
	override method onAttach() {
		super()
		lifeBar.render()
	}
	
	override method onDamageTaken(newHP) {
		lifeBar.onDamageTaken(self)
	}
	
}

class SlimeTurret inherits Slime(baseImageName = "king-slime", removeBehaviour = globalRemoveBehaviour) /* implements IBoss */ {
	const bossRoom
	
	const lifeBar = new BossBarUI(startingPosition = gameConfig.width() - 3)
	
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
	
	override method onDamageTaken(newHP) {
		lifeBar.onDamageTaken(self)
	}
	
	override method onAttach() {
		super()
		self.makeEntryAnimation()
		bossTheme.play()
		mainTheme.stop()
		lifeBar.render()
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
		bossTheme.stop()
		mainTheme.play()
	}
	
}
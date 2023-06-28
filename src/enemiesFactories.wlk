import Entities.*
import Global.*
import Sprite.*
import Movement.*
import bosses.SlimeTurret
import gameConfig.*
import bosses.LordOfFlies
import pools.lordOfFliesPoolBehaviour
import bosses.Rider

class LevelEnemyFactory {
	const scaleDamage
	const scaleHP
	const enemiesFactories = []
	
	method getRandomEnemy() {
		return enemiesFactories.anyOne().generate(scaleDamage, scaleHP)
	}
	
	method boss(forRoom)
}

object level1EnemyFactory inherits LevelEnemyFactory(
	enemiesFactories = [slimeEnemyFactory, zombieEnemyFactory, flyEnemyFactory],
	scaleDamage = 1, 
	scaleHP = 1
) {
	
	override method boss(forRoom) {
		const boss = new LordOfFlies(bossRoom = forRoom, damage = 40, maxHp = 300, cooldown = 500, gravity = global.gravity(), initialX = gameConfig.xMiddle(), initialY = gameConfig.yMiddle())
		boss.changeMovementController(new CollidableMovementController(movableEntity = boss))
		return boss
	}

}

object level2EnemyFactory inherits LevelEnemyFactory(
	enemiesFactories = [pingpongEnemyFactory, slimeEnemyFactory, zombieEnemyFactory],
	scaleDamage = 1.5, 
	scaleHP = 1.5
) {
	
	override method boss(forRoom) {
		const boss = new SlimeTurret(player = global.player(), bossRoom = forRoom, damage = 40, maxHp = 300, cooldown = 500, gravity = global.gravity(), initialX = gameConfig.xMiddle(), initialY = gameConfig.yMiddle())
		boss.changeMovementController(new CooldownMovementController(movableEntity = boss))
		return boss
	}
	
}

object level3EnemyFactory inherits LevelEnemyFactory(
	enemiesFactories = [chargeEnemyFactory, pingpongEnemyFactory, slimeEnemyFactory],
	scaleDamage = 1.5, 
	scaleHP = 1.5
) {
	
	override method boss(forRoom) {
		const boss = new Rider(player = global.player(), bossRoom = forRoom, damage = 100, maxHp = 300, cooldown = 500, gravity = global.gravity(), initialX = gameConfig.xMiddle(), initialY = gameConfig.yMiddle())
		boss.changeMovementController(new CollidableMovementController(movableEntity = boss))
		return boss
	}
	
}

object lordOfFliesFactory inherits LevelEnemyFactory(
	enemiesFactories = [flyEnemyFactory],
	scaleHP = 1,
	scaleDamage = 1
) {
	override method boss(forRoom) {
		self.error("No hay bosses para este pool")
	}
	
	override method getRandomEnemy() {
		const fly = flyEnemyFactory.generate(scaleHP, scaleDamage)
		fly.removeBehaviour(lordOfFliesPoolBehaviour)
		return fly
	}
}

class EnemyFactory {
	method generate(scaleDamage, scaleHP)
}

object slimeEnemyFactory inherits EnemyFactory {
	override method generate(scaleDamage, scaleHP) {
		const slime = new Slime(player = global.player(), damage = 10 * scaleDamage, maxHp = 50 * scaleHP, cooldown = 1000, gravity = global.gravity(), baseImageName = "slime")
		slime.changeMovementController(new CooldownMovementController(movableEntity = slime))
		return slime
	}
}

object chargeEnemyFactory inherits EnemyFactory {
	override method generate(scaleDamage, scaleHP) {
		const charge = new ChargeToPlayerEnemy(player = global.player(), damage = 10 * scaleDamage, maxHp = 50 * scaleHP, cooldown = 1000, gravity = global.gravity(), baseImageName = "charge-enemy")
		charge.changeMovementController(new CollidableMovementController(movableEntity = charge))
		return charge
	}
}

object flyEnemyFactory inherits EnemyFactory {
	override method generate(scaleDamage, scaleHP) {
		const fly = new Fly(player = global.player(), damage = 5 * scaleDamage, maxHp = 15 * scaleHP, cooldown = 1000, gravity = global.gravity(), baseImageName = "fly")
		fly.changeMovementController(new CollidableMovementController(movableEntity = fly))
		return fly
	}
}

object pingpongEnemyFactory inherits EnemyFactory {
	override method generate(scaleDamage, scaleHP) {
		const pingpong = new PingPongEnemy(damage = 5 * scaleDamage, maxHp = 15 * scaleHP, cooldown = 1000, gravity = global.gravity(), baseImageName = "pingpongenemy")
		pingpong.changeMovementController(new CollidableMovementController(movableEntity = pingpong))
		return pingpong
	}
}

object zombieEnemyFactory inherits EnemyFactory {
	override method generate(scaleDamage, scaleHP) {
		const zombie = new Zombie(player = global.player(), damage = 20 * scaleDamage, maxHp = 50 * scaleHP, cooldown = 1000, gravity = global.gravity(), baseImageName = "zombie")
		zombie.changeMovementController(new CollidableMovementController(movableEntity = zombie))
		return zombie
	}
}
import Entities.*
import Global.*
import Sprite.*
import Movement.*
import bosses.SlimeTurret
import gameConfig.*

class LevelEnemyFactory {
	const scaleDamage
	const scaleHP
	const enemiesFactories = []
	method getRandomEnemy()
	method boss(forRoom)
}

object level1EnemyFactory inherits LevelEnemyFactory(
	enemiesFactories = [slimeEnemyFactory, zombieEnemyFactory, flyEnemyFactory],
	scaleDamage = 1, 
	scaleHP = 1
) {
	
	override method boss(forRoom) {
		const boss = new SlimeTurret(bossRoom = forRoom, player = global.player(), damage = 40, maxHp = 300, cooldown = 500, gravity = global.gravity(), initialX = gameConfig.xMiddle(), initialY = gameConfig.yMiddle())
		boss.changeMovementController(new CooldownMovementController(movableEntity = boss))
		return boss
	}
	
	override method getRandomEnemy() {
		return enemiesFactories.anyOne().generate(scaleDamage, scaleHP)
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

object flyEnemyFactory inherits EnemyFactory {
	override method generate(scaleDamage, scaleHP) {
		const fly = new Fly(player = global.player(), damage = 5 * scaleDamage, maxHp = 15 * scaleHP, cooldown = 1000, gravity = global.gravity(), baseImageName = "fly")
		fly.changeMovementController(new CollidableMovementController(movableEntity = fly))
		return fly
	}
}

object zombieEnemyFactory inherits EnemyFactory {
	override method generate(scaleDamage, scaleHP) {
		const zombie = new Zombie(player = global.player(), damage = 20 * scaleDamage, maxHp = 50 * scaleHP, cooldown = 1000, gravity = global.gravity(), baseImageName = "zombie")
		zombie.changeMovementController(new CollidableMovementController(movableEntity = zombie))
		return zombie
	}
}
import Entities.*
import Global.*
import Sprite.*
import Movement.*

class LevelEnemyFactory {
	const scaleDamage
	const scaleHP
	const enemiesFactories = []
	method getRandomEnemy()

}

object level1EnemyFactory inherits LevelEnemyFactory(
	enemiesFactories = [slimeEnemyFactory, zombieEnemyFactory, flyEnemyFactory],
	scaleDamage = 1, 
	scaleHP = 1
) {
	
	override method getRandomEnemy() {
		return enemiesFactories.anyOne().generate(scaleDamage, scaleHP)
	}

}

class EnemyFactory {
	method generate(scaleDamage, scaleHP)
}

object slimeEnemyFactory inherits EnemyFactory {
	override method generate(scaleDamage, scaleHP) {
		const slime = new Slime(player = global.player(), damage = 10 * scaleDamage, maxHp = 50 * scaleHP, cooldown = 1000, gravity = global.gravity())
		slime.imageMap([[new Image(imageName = "slime.png")]])
		slime.movementController(new CooldownMovementController(movableEntity = slime))
		return slime
	}
}

object flyEnemyFactory inherits EnemyFactory {
	override method generate(scaleDamage, scaleHP) {
		const fly = new Fly(player = global.player(), damage = 5 * scaleDamage, maxHp = 15 * scaleHP, cooldown = 1000, gravity = global.gravity())
		fly.imageMap([[new Image(imageName = "fly.png")]])
		fly.movementController(new EnemyMovementController(movableEntity = fly))
		return fly
	}
}

object zombieEnemyFactory inherits EnemyFactory {
	override method generate(scaleDamage, scaleHP) {
		const zombie = new Zombie(player = global.player(), damage = 20 * scaleDamage, maxHp = 50 * scaleHP, cooldown = 1000, gravity = global.gravity())
		zombie.imageMap([[new Image(imageName = "pepita.png")]])
		zombie.movementController(new EnemyMovementController(movableEntity = zombie))
		return zombie
	}
}
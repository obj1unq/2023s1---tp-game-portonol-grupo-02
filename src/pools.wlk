import Entities.*
import gameConfig.*
import Sprite.*
import structureGenerator.*
import enemiesFactories.*

class LevelEnemyPool {

	const levelFactory

	method getEnemy()
	method getRandomEnemies(quantity)
	method getRandomBoss()
	method appendPool(_pool)
	method addEnemy(enemy)
}

object emptyEnemyPool inherits LevelEnemyPool(levelFactory = level1EnemyFactory) {
	
	var property pool = []
	
	override method getEnemy(){
	}
	override method getRandomEnemies(quantity) = []
	override method getRandomBoss(){
	}
	override method appendPool(_pool){
	}
	override method addEnemy(enemy){
	}
}

object level1EnemyPool inherits LevelEnemyPool(levelFactory = level1EnemyFactory) {
	
	var property pool = new Queue(elements=[])
	
	override method getEnemy() {
		return if(not pool.isEmpty()) {
			const enemy = pool.dequeue()
			enemy.resetState()
			return enemy
		} else {
			const enemy = levelFactory.getRandomEnemy()
			console.println(enemy)
			return enemy
		}
	}
	
	// TODO: Agregar posiciones
	override method getRandomEnemies(quantity){
		const enemiesToRender = []
		if(quantity > 0) {
			(0 .. quantity - 1).forEach{ i =>
				const e = self.getEnemy()
				enemiesToRender.add(e)
			}			
		}
		return enemiesToRender
	}
	
	override method addEnemy(enemy){
		pool.enqueue(enemy)
	}
	
	override method getRandomBoss() {
		// TODO: This should create a boss. This is an entity, not a boss.
		return new Slime(gravity = gameConfig.gravity(), hp = 50, maxHp = 50, damage = 25, cooldown = 2000, player = gameConfig.player())
	}
	
	override method appendPool(_pool) {
		pool.enqueueList(_pool.pool().asList())
	}
}



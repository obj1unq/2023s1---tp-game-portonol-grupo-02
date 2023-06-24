import Entities.*
import gameConfig.*
import Sprite.*
import structureGenerator.*
import enemiesFactories.*
import consumables.*
import Global.global
import dungeonRooms.levelManager

class LevelEnemyPool {

	const levelFactory

	method getEnemy()
	method getRandomEnemies(quantity)
	method getRandomBoss()
	method appendPool(_pool)
	method addEnemy(enemy)
	method boss(forRoom)
	method removeEnemy(enemy)
	
}

object consumablesPool {
	const items = [mateFactory, canioncitoDDLFactory]
	
	method getRandomItem(forRoom) {
		const item = items.anyOne()
		return item.getConsumable(forRoom)	
	}
}

object emptyEnemyPool inherits LevelEnemyPool(levelFactory = level1EnemyFactory) {
	
	var property pool = []
	
	override method boss(forRoom) {}
	override method getEnemy(){}
	override method getRandomEnemies(quantity) = []
	override method getRandomBoss(){}
	override method appendPool(_pool){}
	override method addEnemy(enemy){}
	override method removeEnemy(enemy){}
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
			return enemy
		}
	}
	
	override method removeEnemy(enemy) {
		pool.remove(enemy)
	}
	
	override method boss(forRoom) {
		return levelFactory.boss(forRoom)
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

class RemoveBehaviour {
	method onRemove(entity)
	method onAdd(entity)
}

class GlobalRemoveBehaviour inherits RemoveBehaviour {
	override method onRemove(entity) {
	 	global.removeEnemy(entity)
	 }
	 
	 override method onAdd(entity) {
	 	global.addEnemy(entity)
	 }
}

object poolRemoveBehaviour inherits GlobalRemoveBehaviour {
	
	 override method onRemove(entity) {
	 	super(entity)
	 	levelManager.lastPool().addEnemy(entity)
	 }
	 
	 override method onAdd(entity) {
	 	super(entity)
	 	levelManager.lastPool().removeEnemy(entity)
	 }
	 
}

object globalRemoveBehaviour inherits GlobalRemoveBehaviour {}

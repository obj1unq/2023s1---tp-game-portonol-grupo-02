import Entities.*
import gameConfig.*
import Sprite.*
import structureGenerator.*
import enemiesFactories.*
import consumables.*
import Global.global
import dungeonRooms.levelManager

class EnemyPool {

	const enemyFactory

	var property pool = new Queue(elements=[])
	
	method getEnemy() {
		return if(not pool.isEmpty()) {
			const enemy = pool.dequeue()
			enemy.resetState()
			return enemy
		} else {
			const enemy = enemyFactory.getRandomEnemy()
			return enemy
		}
	}
	
	method mix() {
		pool.mix()
	}
	
	method removeEnemy(enemy) {
		pool.remove(enemy)
	}
	
	method boss(forRoom) {
		return enemyFactory.boss(forRoom)
	}
	
	// TODO: Agregar posiciones
	method getRandomEnemies(quantity){
		const enemiesToRender = []
		if(quantity > 0) {
			(0 .. quantity - 1).forEach{ i =>
				const e = self.getEnemy()
				enemiesToRender.add(e)
			}			
		}
		return enemiesToRender
	}
	
	method addEnemy(enemy){
		pool.enqueue(enemy)
	}
		
	method appendPool(_pool) {
		pool.enqueueList(_pool.pool().asList())
	}
	
}

object consumablesPool {
	const items = [mateFactory, canioncitoDDLFactory, dragonSlayerFactory]
	
	method getRandomItem(forRoom) {
		if(items.size() == 0) {
			return nullishConsumable
		} else {
			const item = items.anyOne()
			items.remove(item)
			return item.getConsumable(forRoom)				
		}
	}
}

object emptyEnemyPool inherits EnemyPool(enemyFactory = level1EnemyFactory) {
		
	override method boss(forRoom) = null
	override method getEnemy() = null
	override method getRandomEnemies(quantity) = []
	override method appendPool(_pool){}
	override method addEnemy(enemy){}
	override method removeEnemy(enemy){}
}

object lordOfFliesPool inherits EnemyPool(enemyFactory = lordOfFliesFactory) {}

object level1EnemyPool inherits EnemyPool(enemyFactory = level1EnemyFactory) {}

object level2EnemyPool inherits EnemyPool(enemyFactory = level2EnemyFactory) {}

object level3EnemyPool inherits EnemyPool(enemyFactory = level3EnemyFactory) {}

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

object lordOfFliesPoolBehaviour inherits GlobalRemoveBehaviour {
	override method onRemove(entity) {
	 	super(entity)
	 	lordOfFliesPool.addEnemy(entity)
	 }
	 
	 override method onAdd(entity) {
	 	super(entity)
	 	lordOfFliesPool.removeEnemy(entity)
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

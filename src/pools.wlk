import Entities.*
import gameConfig.*
import Sprite.*
import structureGenerator.*
import enemiesFactories.*

class StructureFactory {
	method piso()
	method paredIzquierda()
	method paredDerecha()
	method paredAbajo()
	method paredArriba()
}

object level1StructureFactory inherits StructureFactory {
	override method piso() {
		const structure = []
		(gameConfig.doorXOffset().. gameConfig.width() - gameConfig.doorXOffset()).forEach {
			x =>
				const column = []
				(gameConfig.doorYOffset() .. gameConfig.height() - gameConfig.doorYOffset()).forEach {
					y =>
						column.add(new Image(imageName = "piso.png"))
				}
				structure.add(column)
		}
		const piso = new Entity(withCollisions = false)
		piso.initialPositions(gameConfig.doorXOffset(), gameConfig.height() - gameConfig.doorYOffset())
		piso.imageMap(structure)
		return piso
	}
	
	override method paredIzquierda() {
		const structure = []
		const column = []
		(gameConfig.doorYOffset().. gameConfig.height() - gameConfig.doorYOffset()).forEach {
			y =>
				column.add(new Image(imageName = "paredIzquierda.png"))
		}
		structure.add(column)
		const pared = new Entity(withCollisions = false)
		pared.initialPositions(gameConfig.doorYOffset(), gameConfig.height() - gameConfig.doorYOffset())
		pared.imageMap(structure)
		return pared
	}
	
	override method paredDerecha() {
		const structure = []
		const column = []
		(gameConfig.doorYOffset().. gameConfig.height() - gameConfig.doorYOffset()).forEach {
			y =>
				column.add(new Image(imageName = "paredDerecha.png"))
		}
		structure.add(column)
		const pared = new Entity(withCollisions = false)
		pared.initialPositions(gameConfig.width() - gameConfig.doorXOffset(), gameConfig.height() - gameConfig.doorYOffset())
		pared.imageMap(structure)
		return pared
	}
	
	override method paredAbajo() {
		const structure = []
		(gameConfig.doorXOffset().. gameConfig.width() - gameConfig.doorXOffset()).forEach {
			x =>
				structure.add([new Image(imageName = "paredAbajo.png")])
		}
		const pared = new Entity(withCollisions = false)
		pared.imageMap(structure)
		pared.initialPositions(gameConfig.doorXOffset(), gameConfig.doorYOffset())
		return pared
	}
	
	override method paredArriba() {
		const structure = []
		(gameConfig.doorXOffset().. gameConfig.width() - gameConfig.doorXOffset()).forEach {
			x =>
				structure.add([new Image(imageName = "paredArriba.png")])
		}
		const pared = new Entity(withCollisions = false)
		pared.imageMap(structure)
		pared.initialPositions(gameConfig.doorXOffset(), gameConfig.height() - gameConfig.doorYOffset())
		return pared
	}
	
}

class LevelEnemyPool {

	const levelFactory

	method getEnemy()
	method getRandomEnemies(quantity)
	method getRandomBoss()
	method appendPool(_pool)
	method addEnemy(enemy)
}

class LevelAssets {
	method getParedIzquierda()
	method getParedDerecha()
	method getPiso()
	method getParedArriba()
	method getParedAbajo()
}

object level1Assets {
	method getParedIzquierda() = "paredIzquierda.png"
	method getParedDerecha() = "paredDerecha.png"
	method getPiso() = "piso.png"
	method getParedArriba() = "paredArriba.png"
	method getParedAbajo() = "paredAbajo.png"
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
		(0..quantity).forEach{ i =>
			const e = self.getEnemy()
			enemiesToRender.add(e)
		}
		console.println(enemiesToRender)
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



import Entities.*
import gameConfig.*
import Sprite.*
import structureGenerator.*

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
		const piso = new Entity()
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
		const pared = new Entity()
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
		const pared = new Entity()
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
		const pared = new Entity()
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
		const pared = new Entity()
		pared.imageMap(structure)
		pared.initialPositions(gameConfig.doorXOffset(), gameConfig.height() - gameConfig.doorYOffset())
		return pared
	}
	
}

class LevelEnemyPool {

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

object emptyEnemyPool inherits LevelEnemyPool {
	
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

object level1EnemyPool inherits LevelEnemyPool {
	
	var property pool = new Queue(elements=[
		new Slime(gravity = gameConfig.gravity(), hp = 50, maxHp = 50, damage = 25, cooldown = 2000, player = gameConfig.player()),
		new Slime(gravity = gameConfig.gravity(), hp = 50, maxHp = 50, damage = 25, cooldown = 2000, player = gameConfig.player()),
		new Slime(gravity = gameConfig.gravity(), hp = 50, maxHp = 50, damage = 25, cooldown = 2000, player = gameConfig.player()),
		new Slime(gravity = gameConfig.gravity(), hp = 50, maxHp = 50, damage = 25, cooldown = 2000, player = gameConfig.player())	
	])
	
	override method getEnemy() {
		return if (not pool.isEmpty()) pool.dequeue() else null
	}
	
	override method getRandomEnemies(quantity){
		const enemiesToRender = #{}
		(0..quantity).forEach{ i =>
			const e = self.getEnemy()
			if (e != null) enemiesToRender.add(e)
		}
		return enemiesToRender
	}
	
	override method addEnemy(enemy){
		pool.add(enemy)
	}
	
	override method getRandomBoss() {
		// TODO: This should create a boss. This is an entity, not a boss.
		return new Slime(gravity = gameConfig.gravity(), hp = 50, maxHp = 50, damage = 25, cooldown = 2000, player = gameConfig.player())
	}
	
	override method appendPool(_pool) {
		_pool.pool().asList().forEach{e => pool.enqueue(e)}
	}
}



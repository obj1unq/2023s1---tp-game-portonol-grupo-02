import Entities.*
import gameConfig.*
import Sprite.*

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
		(2.. gameConfig.width() - 2).forEach {
			x =>
				const columna = []
				(2 .. gameConfig.height() - 2).forEach {
					y =>
						columna.add(new Image(imageName = "piso.png"))
				}
				structure.add(columna)
		}
		const piso = new Entity()
		piso.initialPositions(2, gameConfig.height() - 2)
		piso.imageMap(structure)
		return piso
	}
	
	override method paredIzquierda() {
		const structure = []
		(2.. gameConfig.height() - 2).forEach {
			y =>
				const columna = []
				columna.add(new Image(imageName = "paredIzquierda.png"))
				structure.add(columna)
		}
		const pared = new Entity()
		pared.initialPositions(2, gameConfig.height() - 2)
		pared.imageMap(structure)
		return pared
	}
	
	override method paredDerecha() {
		const structure = []
		(2.. gameConfig.height() - 2).forEach {
			y =>
				const columna = []
				columna.add(new Image(imageName = "paredDerecha.png"))
				structure.add(columna)
		}
		const pared = new Entity()
		pared.initialPositions(gameConfig.width() - 2, gameConfig.height() - 2)
		pared.imageMap(structure)
		return pared
	}
	
	override method paredAbajo() {
		const structure = []
		(2.. gameConfig.width() - 2).forEach {
			x =>
				structure.add([new Image(imageName = "paredAbajo.png")])
		}
		const pared = new Entity()
		pared.imageMap(structure)
		pared.initialPositions(2, 2)
		return pared
	}
	
	override method paredArriba() {
		const structure = []
		(2.. gameConfig.height() - 2).forEach {
			x =>
				structure.add([new Image(imageName = "paredArriba.png")])
		}
		const pared = new Entity()
		pared.imageMap(structure)
		pared.initialPositions(gameConfig.height() - 2, 2)
		return pared
	}
	
}

class LevelEnemyPool {
	
	method getRandomRoomEnemies()
	method getRandomBoss()
	
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

object level1EnemyPool inherits LevelEnemyPool {
	override method getRandomRoomEnemies() {
		return [new Slime(gravity = gameConfig.gravity(), hp = 50, maxHp = 50, damage = 25, cooldown = 2000, player = gameConfig.player())]
	}
	
	override method getRandomBoss() {
		// TODO: This should create a boss. This is an entity, not a boss.
		return new Slime(gravity = gameConfig.gravity(), hp = 50, maxHp = 50, damage = 25, cooldown = 2000, player = gameConfig.player())
	}
}


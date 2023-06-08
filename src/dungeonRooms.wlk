import structureGenerator.*
import Entities.*
import gameConfig.*
import Sprite.*
import pools.*
import Global.*

class ImageCopy {
	const property image
	const property position
}

object levelManager {
	
	var lastLevel = null
	var property lastPool = emptyEnemyPool
	
	const levels = new Queue(elements = [
		new Level(levelEnemyPool = level1EnemyPool, player = gameConfig.player(), roomQuantity = 4),
		new Level(levelEnemyPool = level1EnemyPool, player = gameConfig.player(), roomQuantity = 6),
		new Level(levelEnemyPool = level1EnemyPool, player = gameConfig.player(), roomQuantity = 8)
	])
	
	method loadNextLevel() {
		// TODO: Inicializar con null objects
		if(lastLevel != null) {
			lastLevel.clearLevel()
		}
		
		if(not levels.isEmpty()){
			gameConfig.player().initialPositions(gameConfig.xMiddle(), gameConfig.yMiddle())
			const level = levels.dequeue()
			level.levelEnemyPool().appendPool(lastPool)
			level.initializeLevel()
			lastLevel = level
			lastPool = lastLevel.levelEnemyPool()
		} else {
			global.deathScreen()
		}
	}

}

class Trapdoor inherits GravityEntity {
	const fromRoom
	
	override method onCollision(colliders) {
		super(colliders)
		if(colliders.any {
			collider => collider.hasEntity() and collider.entity() == gameConfig.player()
		}) {
			self.goToNextLevel()			
		}
	}
	
	method goToNextLevel() {
		fromRoom.unrender()
		levelManager.loadNextLevel()
	}
	
}

class DoorState {
	method getAsset()
	method isOpen()
}

object closedDoor inherits DoorState {
	override method getAsset() = "-closed.png"
	override method isOpen() = false
}

object openedDoor inherits DoorState {
	override method getAsset() = ".png"
	override method isOpen() = true
}


class Door inherits GravityEntity {
	const from
	const to
	const direction
	const property getPosition = direction.positionInMiddle()
	var state = openedDoor
	
	override method onCollision(colliders) {
		if(state.isOpen() and self.collidedWithPlayer(colliders)) {
			self.movePlayerToOpositeDoor()
			from.unrender()
			to.render()
		}
	}
	
	override method imageName(){
		return super() + state.getAsset()
	}
	
	method movePlayerToOpositeDoor() {
		const nextPosition = direction.oposite().positionNStepsInto(1)
		gameConfig.player().initialPositions(nextPosition.x(), nextPosition.y())
	}
	
	method close() {
		state = closedDoor
	}
	
	method open() {
		state = openedDoor
	}
	
	method collidedWithPlayer(collider) {
		return collider.hasEntity() and collider.entity() == gameConfig.player()
	}
	
}
 
class DungeonRoom inherits Node {	
	const property doors = #{}
	const property structures = #{}
	
	method piso()
	
	method render() {
		self.renderDoors()
		self.renderStructures()
	}
	
	method unrender() {
		self.unrenderDoors()
		self.unrenderStructures()
	}
	
	method renderStructures() {
		structures.forEach {
			structure => structure.onAttach()
		}
	}
	
	method unrenderStructures() {
		structures.forEach {
			structure => structure.onRemove()
		}
	}
	
	method renderDoors() {
		doors.forEach {
			structure => structure.onAttach()
		}
	}
	
	method unrenderDoors() {
		doors.forEach {
			structure => structure.onRemove()
		}
	}
	
	method generateRoom() {
		neighbours.keys().forEach {
			direction =>
				self.generateDoorIn(direction)
		}
	}
	
	method openDoors() {
		doors.forEach {
			door =>
				door.open()
		}
	}
	
	method closeDoors() {
		doors.forEach {
			door =>
				door.close()
		}
	}
	
	method generateDoorIn(direction) {
		const neighbour = self.neighbourIn(direction)
		const door = new Door(from = self, to = neighbour, direction = direction, gravity = gameConfig.gravity(), imageName = direction.doorAsset())
		door.initialPositions(door.getPosition().x(), door.getPosition().y())
		door.setImageMap()
		doors.add(door)
	}
	
}

class PlayerDungeonRoom inherits DungeonRoom {
	var player
	
	override method render() {
		super()
		player.onAttach()
	}

	override method unrender() {
		super()
		player.onRemove()
	}
	
	method player(_player) {
		player = _player
	}
	
	override method piso() = "celeste.png"
		
}

class EnemiesDungeonRoom inherits PlayerDungeonRoom {
	var enemies = #{}
	var enemiesCap = 3
	
	override method piso() = "muro.png"
	
	override method render() {
		super()
		self.closeDoors()
		self.addEnemies()
		self.renderEnemies()
		self.checkIfOpenDoors()
	}
	
	method renderEnemies() {
		enemies.forEach {
			enemy => 
				enemy.setDeathCallback{
					enemies.remove(enemy)
					levelManager.lastPool().addEnemy(enemy)
					self.checkIfOpenDoors()
				}
				enemy.initialPositions(gameConfig.xMiddle(), gameConfig.yMiddle())
				enemy.onAttach()
		}
	}
	
	method addEnemies() {
		 enemies.addAll(levelManager.lastPool().getRandomEnemies(enemiesCap))
	}
	
	method checkIfOpenDoors() {
		if(self.thereAreNoEnemies()) {
			self.onDoorOpening()
		}
	}
	
	method onDoorOpening() {
		self.openDoors()
	}
	
	override method unrender() {
		super()
		enemies.forEach {
			enemy => enemy.onRemove()
		}
	}
	
	method thereAreNoEnemies() {
		return enemies.size() == 0
	}
	
}

class BossDungeonRoom inherits EnemiesDungeonRoom {
	override method piso() = "rojo.png"
	
	override method onDoorOpening() {
		super()
		self.spawnTrapdoor()
	}
	
	method spawnTrapdoor() {
		const trapdoor = new Trapdoor(fromRoom = self, gravity = gameConfig.gravity(), imageName = "trapdoor.jpg")
		trapdoor.initialPositions(gameConfig.xMiddle(), gameConfig.yMiddle())
		structures.add(trapdoor)
		trapdoor.onAttach()
	}
	
}

class Level {
	const property levelEnemyPool
	const roomQuantity
	const player
	var structureGenerator = null
	var structure = null
	var levelRoomAssets = null
	var spawnRoom = null
	var bossRoom = null
	
	method initializeLevel() {
		self.generateStructure()
		self.setBossRoom()
		self.generateRoomAsset()
		self.generateLevel()
		self.renderSpawnPoint()
		self.initGravity()
	}
	
	method levelEnemyPool() = levelEnemyPool
		
	method generateLevel() {
		structure.forEach {
			room => room.generateRoom()
		}
	}
		
	method clearLevel() {
		levelRoomAssets.forEach {
			asset => asset.onRemove()
		}
	}
	
	method initGravity() {
		gameConfig.gravity().init()
	}
	
	method renderSpawnPoint() {
		spawnRoom.render()
	}
	
	method generateRoomAsset() {
		
	}
	
	
	method generateStructure() {
		structureGenerator = new DungeonStructureGenerator(maxQuantity = roomQuantity)
		structureGenerator.generate()
		structure = structureGenerator.rooms()
		spawnRoom = structureGenerator.startingRoom()
	}
 	
	method setBossRoom() {
		var roomsWithOneNeighbour = structureGenerator.roomsWithNNeighbours(1)
		
		if(roomsWithOneNeighbour == []) {
			roomsWithOneNeighbour = structureGenerator.roomsWithNNeighbours(2)
		}
		
		const replaced = roomsWithOneNeighbour.last()
		structure.remove(replaced)
		bossRoom = new BossDungeonRoom(player = gameConfig.player(), position = replaced.position())
		bossRoom.replace(replaced)
		structure.add(bossRoom)
		
	}
	
}

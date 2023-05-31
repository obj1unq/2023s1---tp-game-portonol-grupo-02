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
		new Level(levelEnemyPool = level1EnemyPool, structureFactory = level1StructureFactory, player = gameConfig.player(), roomQuantity = 4),
		new Level(levelEnemyPool = level1EnemyPool, structureFactory = level1StructureFactory, player = gameConfig.player(), roomQuantity = 6),
		new Level(levelEnemyPool = level1EnemyPool, structureFactory = level1StructureFactory, player = gameConfig.player(), roomQuantity = 8)
	])
	
	method loadNextLevel() {
		if(lastLevel != null) {
			lastLevel.clearLevel()
			lastPool = lastLevel.levelEnemyPool()
		}
		
		if(not levels.isEmpty()){
			gameConfig.player().initialPositions(gameConfig.xMiddle(), gameConfig.yMiddle())
			const level = levels.dequeue()
			level.initializeLevel()
			level.levelEnemyPool().appendPool(lastPool)
			lastLevel = level
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

class Door inherits GravityEntity {
	const from
	const to
	const direction
	const property getPosition = direction.positionInMiddle()
	const property getImage = direction.doorAsset()
	var isOpen = true
	
	override method onCollision(colliders) {
		super(colliders)
		if(isOpen and self.collidedWithPlayer(colliders)) {
			self.movePlayerToOpositeDoor()
			from.unrender()
			to.render()
		}
	}
	
	method movePlayerToOpositeDoor() {
		const nextPosition = direction.oposite().positionNStepsInto(1)
		gameConfig.player().initialPositions(nextPosition.x(), nextPosition.y())
	}
	
	method close() {
		isOpen = false	
	}
	
	method open() {
		isOpen = true
	}
	
	method collidedWithPlayer(colliders) {
		return colliders.any {
			collider =>
				collider.hasEntity() and collider.entity() == gameConfig.player()
		}
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
	
	method generateLevel() {
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
		const door = new Door(from = self, to = neighbour, direction = direction, gravity = gameConfig.gravity())
		door.initialPositions(door.getPosition().x(), door.getPosition().y())
		door.imageMap([[new Image(imageName = door.getImage())]])
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
	var enemiesCap = 4
	
	override method piso() = "muro.png"
	
	override method render() {
		super()
		self.closeDoors()
		enemies.forEach {
			enemy => 
				enemy.setDeathCallback{
					enemies.remove(enemy)
					levelManager.lastPool().addEnemy(enemy)
					self.checkIfOpenDoors()
				}
				enemy.onAttach()
		}
		self.checkIfOpenDoors()
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
	
	override method generateLevel(){
		super()
		enemies = enemies + levelManager.lastPool().getRandomEnemies(enemiesCap)
	}
}

class BossDungeonRoom inherits EnemiesDungeonRoom {
	override method piso() = "rojo.png"
	
	override method onDoorOpening() {
		super()
		self.spawnTrapdoor()
	}
	
	method spawnTrapdoor() {
		const trapdoor = new Trapdoor(fromRoom = self, gravity = gameConfig.gravity())
		trapdoor.initialPositions(gameConfig.xMiddle(), gameConfig.yMiddle())
		trapdoor.imageMap([[new Image(imageName = "trapdoor.jpg")]])
		structures.add(trapdoor)
		trapdoor.onAttach()
	}
	
}

class Level {
	const levelEnemyPool
	const structureFactory
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
			room => room.generateLevel()
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
		levelRoomAssets = [
			structureFactory.piso(),
			structureFactory.paredIzquierda(),
			structureFactory.paredDerecha(),
			structureFactory.paredAbajo(),
			structureFactory.paredArriba()	
		]
		
		levelRoomAssets.forEach {
			roomAsset => 
				roomAsset.onAttach()
		}
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

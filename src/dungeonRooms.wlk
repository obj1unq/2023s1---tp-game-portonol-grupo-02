import example.*
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
	
	var actualLevel = 0
	
	const levels = [
		new Level(levelEnemyPool = level1EnemyPool, structureFactory = level1StructureFactory, player = gameConfig.player(), roomQuantity = 4),
		new Level(levelEnemyPool = level1EnemyPool, structureFactory = level1StructureFactory, player = gameConfig.player(), roomQuantity = 6),
		new Level(levelEnemyPool = level1EnemyPool, structureFactory = level1StructureFactory, player = gameConfig.player(), roomQuantity = 8)
	]
	
	method loadNextLevel() {
		if(actualLevel > 0) {
			levels.get(actualLevel - 1).clearLevel()
		}
		if(actualLevel < levels.size()){
			gameConfig.player().initialPositions(gameConfig.xMiddle(), gameConfig.yMiddle())
			levels.get(actualLevel).initializeLevel()
		} else {
			global.deathScreen()
		}
		actualLevel++
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
		self.onRemove()
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
	
	method piso()
	
	method render() {
		self.renderDoors()
	}
	
	method renderDoors() {
		doors.forEach {
			door => door.onAttach()
		}
	}
	
	method generateDoors() {
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
	
	method unrender() {
		doors.forEach {
			door => door.onRemove()
		}
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
	const enemies = #{}
	
	override method piso() = "muro.png"
	
	override method render() {
		super()
		self.closeDoors()
		enemies.forEach {
			enemy => 
				enemy.setDeathCallback{
					enemies.remove(enemy)
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
		trapdoor.onAttach()
	}
	
}

class Level {
	const levelEnemyPool
	const structureFactory
	const roomQuantity
	const player
	var graph = null
	var structure = null
	var levelRoomAssets = null
	var bossNode = null
	var spawnNode = null
	var spawnRoom = null
	var bossRoom = null
	const nodeRoomRelation = new Dictionary()
	const property dungeonRooms = []
	
	method initializeLevel() {
		self.generateStructure()
		self.setSpawnPointRoom()
		self.setBossRoom()
		self.setLeftoversAsRooms()
		self.connectRooms()
		self.generateRoomAsset()
		self.renderSpawnPoint()
		self.initGravity()
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
	
	method connectRooms() {
		nodeRoomRelation.keys().forEach {
			node =>
				const room = nodeRoomRelation.get(node)
				self.copyNeighboursFrom(node, room)
				room.generateDoors()
		}
	}
	
	method copyNeighboursFrom(node, room) {
		node.neighboursDirections().forEach {
			neighbourDirection => 
				const neighbour = node.neighbourIn(neighbourDirection)
				const neighbourRoom = nodeRoomRelation.get(neighbour)
				room.addNeighbourInDirection(neighbourRoom, neighbourDirection)
		}
	}
	
	method generateStructure() {
		graph = new Graph(maxQuantity = roomQuantity)
		graph.generate()
		structure = graph.nodes()
	}
	
	method setSpawnPointRoom() {
		spawnNode = graph.startingNode()
		spawnRoom = new PlayerDungeonRoom(player = player, position = spawnNode.position())
		nodeRoomRelation.put(spawnNode, spawnRoom)
		dungeonRooms.add(spawnRoom)
	}
 	
	method setBossRoom() {
		var nodesWithOneNeighbour = graph.nodesWithNNeighbours(1)
		
		if(nodesWithOneNeighbour == []) {
			nodesWithOneNeighbour = graph.nodesWithNNeighbours(2)
		}
		
		bossNode = nodesWithOneNeighbour.last()
		bossRoom = new BossDungeonRoom(player = gameConfig.player(), position = bossNode.position())
		nodeRoomRelation.put(bossNode, bossRoom)
		dungeonRooms.add(bossRoom)
	}
	
	method setLeftoversAsRooms() {
		structure.forEach {
			node => 
				if(node != bossNode and node != spawnNode) {
					const dungeonRoom = new EnemiesDungeonRoom(player = gameConfig.player(), position = node.position())
					dungeonRooms.add(dungeonRoom)
					nodeRoomRelation.put(node, dungeonRoom)
				}
		}
	}
	
}

import example.*
import Entities.*
import gameConfig.*
import Sprite.*

class ImageCopy {
	const property image
	const property position
}

class Door inherits CollapsableEntity {
	const from
	const to
	const direction
	const property position = direction.positionInMiddle()
	const property image = direction.doorAsset()
	var isOpen = true
	
	override method onCollision(colliders) {
		if(isOpen and self.collidedWithPlayer(colliders)) {
			from.unrender()
			to.render()
		}
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
				collider.hasEntity() and collider.entity().isPlayer()
		}
	}
	
}
 
class DungeonRoom inherits Node {
	const structureFactory
	const structures = #{
		structureFactory.piso(),
		structureFactory.paredIzquierda(),
		structureFactory.paredDerecha(),
		structureFactory.paredAbajo(),
		structureFactory.paredArriba()
	}
	
	const property doors = #{}
	
	method piso()
	
	method render() {
		structures.forEach {
			structure => 
				structure.onAttach()
		}
		self.generateDoors()
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
		const door = new Door(from = self, to = neighbour, direction = direction)
		door.initialPositions(door.position().x(), door.position().y())
		door.imageMap([[new Image(imageName = door.image())]])
		structures.add(door)
		doors.add(door)
	}
	
	method unrender() {
		structures.forEach {
			structure => 
				structure.onRemove()
		}
	}
	
	method addStructure(structure) {
		structures.add(structure)
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
	}
	
	method checkIfOpenDoors() {
		if(self.thereAreNoEnemies()) {
			self.openDoors()
		}
	}
	
	override method unrender() {
		super()
		enemies.forEach {
			enemy => enemy.onRemove()
		}
	}
	
	method thereAreNoEnemies() {
		return enemies.length() == 0
	}
}

class BossDungeonRoom inherits EnemiesDungeonRoom {
	override method piso() = "rojo.png"
}

class Level {
	const levelEnemyPool
	const structureFactory
	const roomQuantity
	const player
	var graph = null
	var structure = null
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
		self.spawnPlayer()
	}
	
	method spawnPlayer() {
		spawnRoom.render()
	}
	
	method connectRooms() {
		nodeRoomRelation.keys().forEach {
			node =>
				self.copyNeighboursFrom(node, nodeRoomRelation.get(node))
		}
	}
	
	method copyNeighboursFrom(node, room) {
		node.neighboursDirections().forEach {
			neighbourDirection => 
				const neighbour = nodeRoomRelation.get(node)
				room.addNeighbourInDirection(neighbour, neighbourDirection)
		}
	}
	
	method generateStructure() {
		graph = new Graph(maxQuantity = roomQuantity)
		graph.generate()
		structure = graph.nodes()
	}
	
	method setSpawnPointRoom() {
		spawnNode = graph.startingNode()
		spawnRoom = new PlayerDungeonRoom(player = player, position = spawnNode.position(), structureFactory = structureFactory)
		nodeRoomRelation.put(spawnNode, spawnRoom)
		dungeonRooms.add(spawnRoom)
	}
 	
	method setBossRoom() {
		var nodesWithOneNeighbour = graph.nodesWithNNeighbours(1)
		
		if(nodesWithOneNeighbour == []) {
			nodesWithOneNeighbour = graph.nodesWithNNeighbours(2)
		}
		
		bossNode = nodesWithOneNeighbour.last()
		bossRoom = new BossDungeonRoom(player = gameConfig.player(), position = bossNode.position(), structureFactory = structureFactory)
		nodeRoomRelation.put(bossNode, bossRoom)
		dungeonRooms.add(bossRoom)
	}
	
	method setLeftoversAsRooms() {
		structure.forEach {
			node => 
				if(node != bossNode and node != spawnNode) {
					const dungeonRoom = new EnemiesDungeonRoom(player = gameConfig.player(), position = node.position(), structureFactory = structureFactory)
					dungeonRooms.add(dungeonRoom)
					nodeRoomRelation.put(node, dungeonRoom)
				}
		}
	}
	
}

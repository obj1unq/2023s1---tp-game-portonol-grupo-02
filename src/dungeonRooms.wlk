import structureGenerator.*
import Entities.*
import gameConfig.*
import Sprite.*
import pools.*
import Global.*
import Blocks.Block

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
	
	override method onCollision(collider) {
		super(collider)
		if(global.isPlayer(collider)){
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
	override method getAsset() = "-closed"
	override method isOpen() = false
}

object openedDoor inherits DoorState {
	override method getAsset() = ""
	override method isOpen() = true
}


class Door inherits GravityEntity {
	const from
	const to
	const facingDirection
	const property getPosition = facingDirection.positionInMiddle()
	var state = openedDoor
	
	override method onCollision(collider) {
		if(state.isOpen() and global.isPlayer(collider)) {
			self.movePlayerToOpositeDoor()
			from.unrender()
			to.render()
		}
	}
	
	override method state(){
		return super() + state.getAsset()
	}
	
	method movePlayerToOpositeDoor() {
		const nextPosition = facingDirection.oposite().positionNStepsInto(1)
		gameConfig.player().initialPositions(nextPosition.x(), nextPosition.y())
	}
	
	method close() {
		state = closedDoor
	}
	
	method open() {
		state = openedDoor
	}
	
}
 
class DungeonRoom inherits Node {	
	const property doors = #{}
	const property structures = #{}
	const property decorations = #{}
	const property consumables = #{}
	
	method piso()
	
	method render() {
		self.renderDoors()
		self.renderStructures()
		self.renderDecorations()
		self.renderConsumables()
	}
	
	method unrender() {
		self.unrenderDoors()
		self.unrenderStructures()
		self.unrenderDecorations()
		self.unrenderConsumables()
	}
	
	method addDecoration(decoration) {
		decorations.add(decoration)
	}
	
	method renderStructures() {
		structures.forEach {
			structure => structure.onAttach()
		}
	}
	
	method addConsumable(consumable) {
		consumables.add(consumable)
	}
	
	method removeConsumable(consumable) {
		consumables.remove(consumable)
	}
	
	method renderConsumables() {
		consumables.forEach {
			consumable => consumable.onAttach()
		}
	}
	
	method unrenderConsumables() {
		consumables.forEach {
			consumable => consumable.onRemove()
		}
	}
	
	
	method unrenderStructures() {
		structures.forEach {
			structure => structure.onRemove()
		}
	}
	
	method renderDecorations() {
		decorations.forEach {
			decoration => decoration.render()
		}
	}
	
	method unrenderDecorations() {
		decorations.forEach {
			decoration => decoration.unrender()
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
		const door = new Door(from = self, to = neighbour, facingDirection = direction, gravity = gameConfig.gravity(), baseImageName = direction.doorAsset())
		door.initialPositions(door.getPosition().x(), door.getPosition().y())
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
	var cleaned = false
	
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
					self.checkIfOpenDoors()
				}
				enemy.initialPositions(gameConfig.xMiddle(), gameConfig.yMiddle())
				enemy.onAttach()
		}
	}
	
	method addEnemies() {
		 if(not cleaned) {
			 enemies.addAll(levelManager.lastPool().getRandomEnemies(enemiesCap))		 	
		 }
	}
	
	method checkIfOpenDoors() {
		if(self.thereAreNoEnemies()) {
			self.onDoorOpening()
		}
	}
	
	method onDoorOpening() {
		self.openDoors()
		cleaned = true
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

class BossDungeonRoom inherits EnemiesDungeonRoom(enemies = #{}) {
	const levelEnemyFactory
	
	override method piso() = "rojo.png"
	
	override method onDoorOpening() {
		super()
		self.spawnTrapdoor()
	}
	
	override method addEnemies() {
		if (not cleaned) {
			const boss = levelEnemyFactory.boss(self)
			boss.setDeathCallback {
				enemies.remove(boss)
				self.checkIfOpenDoors()
			}
			enemies.add(boss)
		}	
	}
	
	method spawnTrapdoor() {
		const trapdoor = new Trapdoor(fromRoom = self, gravity = gameConfig.gravity(), baseImageName = "trapdoor")
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
	var spawnRoom = null
	var bossRoom = null
	
	method initializeLevel() {
		self.generateStructure()
		self.setBossRoom()
		self.generateLevel()
		self.renderSpawnPoint()
//		self.initGravity()
	}
	
	method levelEnemyPool() = levelEnemyPool
		
	method generateLevel() {
		structure.forEach {
			room => room.generateRoom()
		}
	}
		
	method clearLevel() {
// 		Acá estaría bueno sacarle decoracioens al nivel
//		levelRoomAssets.forEach {
//			asset => asset.onRemove()
//		}
	}
	
//	method initGravity() {
//		gameConfig.gravity().init()
//	}
	
	method renderSpawnPoint() {
		spawnRoom.render()
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
		bossRoom = new BossDungeonRoom(levelEnemyFactory = levelEnemyPool, player = gameConfig.player(), position = replaced.position())
		bossRoom.replace(replaced)
		structure.add(bossRoom)
		
	}
	
}

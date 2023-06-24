import wollok.game.*
import gameConfig.*
import dungeonRooms.*
import Position.*
import Sprite.Image

class DungeonStructureGenerator {
	
	const property rooms = []
	const maxQuantity
	const pendingRooms = new Queue()
	var roomsQuantity = 0
	const property startingRoom = new PlayerDungeonRoom(position = game.at(0, 0), player = gameConfig.player() /* , decorations = decorationFactory.getSpawnDecorations() */)
		
	method generate() {
		pendingRooms.enqueue(startingRoom)
		rooms.add(startingRoom)
		roomsQuantity++
		self.generateStructureUntilFinish()
	}
	
	method roomsWithNNeighbours(n) {
		return rooms.filter { room => room.neighboursQuantity() == n}
	}
	
	method generateStructureUntilFinish() {
		if(roomsQuantity < maxQuantity && not pendingRooms.isEmpty()) {
			self.generateNeighboursFor(pendingRooms.dequeue())
			self.generateStructureUntilFinish()
		} else if(roomsQuantity < maxQuantity) {
			pendingRooms.enqueue(rooms.anyOne())
			self.generateStructureUntilFinish()
		}
	}
	
	method generateNeighboursFor(room) {
		directionManager.directions().forEach { dir =>
				const newNeighbourDirection = room.getRandomNeighbourDirection()
				const newNeighbourPosition = newNeighbourDirection.getFromPosition(room.position())
				
				if(self.canVisitNeighbour(newNeighbourPosition)) {
					const neighbour = self.neighbourFor(room, newNeighbourDirection)
					room.addNeighbourInDirection(neighbour, newNeighbourDirection)
					neighbour.addNeighbourInDirection(room, newNeighbourDirection.oposite())
					pendingRooms.enqueue(neighbour)
				}
		}
	}
	
	method isNeighbourInPosition(position) {
		return rooms.any {
			node => node.position() == position
		}
	}
	
	method canVisitNeighbour(neighbourPosition) {
		return randomizer.fiftyBool() and not self.isNeighbourInPosition(neighbourPosition) and roomsQuantity < maxQuantity
	}
	
	method neighbourFor(dungeonRoom, direction) {
		
		const neighbourPosition = direction.getFromPosition(dungeonRoom.position())
		
		const neighbour = rooms.findOrDefault({
						room => room.position() == neighbourPosition and room.position().y() == neighbourPosition.y()
			   		}, null)
		
		return if(neighbour == null) {
			const newNeighbour = new EnemiesDungeonRoom(position = neighbourPosition, player = gameConfig.player())
			// Acá deberíamos de agregar decoraciones de un factory
			const blood = new Image(baseImageName = "blood")
			blood.position().inPosition(1, 1)
			newNeighbour.addDecoration(blood)
			rooms.add(newNeighbour)
			roomsQuantity++
			return newNeighbour
		} else {
			neighbour
		}
	}
}

object randomizer {
	const roomCreation = [dontDo, do]
	const bool = [true, false]
	
	method do(cb) {
		roomCreation.anyOne().create(cb)
	}
	
	method fiftyBool() = return bool.anyOne()
	
}

object dontDo {
	method create(cb) {}
}

object do {
	method create(cb) {
		cb.apply()
	}
}


class Node {
	const property position
	const neighbours = new Dictionary()
	
	method addNeighbourInDirection(neighbour, direction) {
		neighbours.put(direction, neighbour)
	}
	
	method getRandomNeighbourDirection() {
		return directionManager.getRandomDirection()
	}
	
	method neighbourIn(direction) {
		return neighbours.get(direction)
	}
	
	method neighboursDirections() {
		return neighbours.keys()
	}
	
	method replace(node) {
		node.neighboursDirections().forEach {
			direction =>
				const neighbour = node.neighbourIn(direction)
				self.addNeighbourInDirection(neighbour, direction)
				self.replaceNeighbourForSelf(neighbour, direction)
		}
	}
	
	method replaceNeighbourForSelf(neighbour, direction) {
		neighbour.addNeighbourInDirection(self, direction.oposite())
	}
		
	method neighboursQuantity() = neighbours.size()
}

object directionManager {
	
	const property directions = [top, bottom, left, right]
	
	method getRandomDirection() = directions.anyOne()
}

object top {
	method oposite() = bottom
	
	method onInput(movementController) {
		movementController.movableEntity().goUp()
	}
	
	method collisionsFrom(x, y) {
		return game.getObjectsIn(dummiePosition.withPosition(x, y.truncate(0) + 1))
	}
	
	method getFromPosition(position) {
		return game.at(position.x(), position.y() + 1)
	}
	
	method getXFromPosition(position) {
		return position.x()
	}
	
	method getYFromPosition(position) {
		return position.y() + 1
	}
	
	method doorAsset() = "topDoor"
	
	method imageModifier() = "-up"
	
	method positionInMiddle() {
		return game.at(gameConfig.xMiddle(), gameConfig.height() - gameConfig.doorYOffset())
	}
	
	method positionNStepsInto(n) {
		return self.positionInMiddle().down(n)
	}
	
}

object bottom {
	method oposite() = top
	
	method onInput(movementController) {
		movementController.movableEntity().goDown()
	}
	
	method collisionsFrom(x, y) {
		return game.getObjectsIn(dummiePosition.withPosition(x, y.truncate(0) - 1))
	}
	
	method getFromPosition(position) {
		return game.at(position.x(), position.y() - 1)
	}
	
	method getXFromPosition(position) {
		return position.x()
	}
	
	method getYFromPosition(position) {
		return position.y() - 1
	}
	
	method doorAsset() = "bottomDoor"
	
	method imageModifier() = "-down"
	
	method positionInMiddle() {
		return game.at(gameConfig.xMiddle(), gameConfig.doorYOffset())
	}
	
	method positionNStepsInto(n) {
		return self.positionInMiddle().up(n)
	}
	
}

object left {
	method oposite() = right
	
	method onInput(movementController) {
		movementController.movableEntity().goLeft()
	}
	
	method collisionsFrom(x, y) {
		return game.getObjectsIn(dummiePosition.withPosition(x.truncate(0) - 1, y))
	}
	
	method getFromPosition(position) {
		return game.at(position.x() - 1, position.y())
	}
	
	method getXFromPosition(position) {
		return position.x() - 1
	}
	
	method getYFromPosition(position) {
		return position.y()
	}
	
	method doorAsset() = "leftDoor"
	
	method positionInMiddle() {
		return game.at(gameConfig.doorXOffset(), gameConfig.yMiddle())
	}
	
	method imageModifier() = "-left"
	
	method positionNStepsInto(n) {
		return self.positionInMiddle().right(n)
	}
	
}

object right {
	method oposite() = left
	
	method onInput(movementController) {
		movementController.movableEntity().goRight()
	}
	
	method collisionsFrom(x, y) {
		return game.getObjectsIn(dummiePosition.withPosition(x.truncate(0) + 1, y))
	}
	
	method getFromPosition(position) {
		return game.at(position.x() + 1, position.y())
	}
	
	method getXFromPosition(position) {
		return position.x() + 1
	}
	
	method getYFromPosition(position) {
		return position.y()
	}
	
	method imageModifier() = "-right"
	
	method doorAsset() = "rightDoor"
	
	method positionInMiddle() {
		return game.at(gameConfig.width() - gameConfig.doorXOffset(), gameConfig.yMiddle())
	}
	
	method positionNStepsInto(n) {
		return self.positionInMiddle().left(n)
	}
	
}

class Stack {
	var elements = []
	
	method pop() {
		const element = elements.last()
		elements = elements.subList(0, elements.size() - 1)
		return element
	}
	
	method push(element) {
		elements.add(element)
	}
	
	method isEmpty(){
		return elements.size() == 0
	}
	
}

class Queue {
	var elements = []
	
	method dequeue() {
		const element = elements.first()
		elements = elements.drop(1)
		return element
	}
	
	method head() = elements.first()
	
	method size() = elements.size()
	
	method enqueue(element) {
		elements.add(element)
	}
	
	method remove(element) {
		elements.remove(element)
	}
	
	method isEmpty(){
		return elements.size() == 0
	}
	
	method enqueueList(list) {
		elements.addAll(list)
	}
	
	method asList() = elements
	
}
import wollok.game.*
import gameConfig.*
import dungeonRooms.*
import Position.*
import Sprite.Image
import Global.global

class DungeonStructureGenerator {
	
	const property rooms = []
	const maxQuantity
	const pendingRooms = new Queue()
	var roomsQuantity = 0
	const property startingRoom = new PlayerDungeonRoom(position = game.at(0, 0), player = gameConfig.player(), decoration = decorationFactory.getSpawnDecorations())
		
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
			newNeighbour.addDecoration(decorationFactory.getRandomDecoration())
			rooms.add(newNeighbour)
			roomsQuantity++
			return newNeighbour
		} else {
			neighbour
		}
	}
}

object decorationFactory{
	const decorationNumbers = (1..29)
	method getSpawnDecorations() = "instructions"
	method getBossDecorations() = "bossDecorations"
	method getRandomDecoration() = decorationNumbers.anyOne()
}

object decorationManager inherits Image(
	baseImageName = "invisible",
	position = new MutablePosition(x = gameConfig.doorXOffset(), y = gameConfig.doorYOffset())
){
	method toDecoration(type) {
		baseImageName = "decoracion-" + type
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
	const property door = new Door(facingDirection = self, baseImageName = self.doorAsset(), gravity = global.gravity(), initialX = self.positionInMiddle().x(), initialY = self.positionInMiddle().y())
	const middlePosition = self.positionInMiddle()
	
	method oposite() = bottom
	
	method onInput(movementController) {
		movementController.movableEntity().direction().direction(self)
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
	
	method advance(distance, position) {
		position.up(distance)
	}
	
	method canAdvanceTo(position, distance) {
		return gameConfig.canMoveVertically(position.y() + distance)
	}
	
	method getYFromPosition(position) {
		return position.y() + 1
	}
	
	method doorAsset() = "topDoor"
	
	method imageModifier() = "-up"
	
	method positionInMiddle() {
		return new MutablePosition(x = gameConfig.xMiddle(), y = gameConfig.height() - gameConfig.doorYOffset())
	}
	
	method positionNStepsInto(n) {
		const nextPosition = dummiePosition.withPosition(middlePosition.x(), middlePosition.y())
		nextPosition.down(n)
		return nextPosition
	}
	
}

object bottom {
	const property door = new Door(facingDirection = self, baseImageName = self.doorAsset(), gravity = global.gravity(), initialX = self.positionInMiddle().x(), initialY = self.positionInMiddle().y())
	const middlePosition = self.positionInMiddle()
	method oposite() = top
	
	method onInput(movementController) {
		movementController.movableEntity().direction().direction(self)
		movementController.movableEntity().goDown()
	}
	
	method collisionsFrom(x, y) {
		return game.getObjectsIn(dummiePosition.withPosition(x, y.truncate(0) - 1))
	}
	
	method getFromPosition(position) {
		return game.at(position.x(), position.y() - 1)
	}
	
	method advance(distance, position) {
		position.down(distance)
	}
	
	method canAdvanceTo(position, distance) {
		return gameConfig.canMoveVertically(position.y() - distance)
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
		return new MutablePosition(x = gameConfig.xMiddle(), y = gameConfig.doorYOffset())
	}
	
	method middlePosition() = middlePosition
	
	method positionNStepsInto(n) {
		const nextPosition = dummiePosition.withPosition(middlePosition.x(), middlePosition.y())
		nextPosition.up(n)
		return nextPosition
	}
	
}

object left {
	const property door = new Door(facingDirection = self, baseImageName = self.doorAsset(), gravity = global.gravity(), initialX = self.positionInMiddle().x(), initialY = self.positionInMiddle().y())
	const middlePosition = self.positionInMiddle()
	
	method oposite() = right
	
	method onInput(movementController) {
		movementController.movableEntity().direction().direction(self)
		movementController.movableEntity().goLeft()
	}
	
	method collisionsFrom(x, y) {
		return game.getObjectsIn(dummiePosition.withPosition(x.truncate(0) - 1, y))
	}
	
	method getFromPosition(position) {
		return game.at(position.x() - 1, position.y())
	}
	
	method advance(distance, position) {
		position.left(distance)
	}
	
	method canAdvanceTo(position, distance) {
		return gameConfig.canMoveHorizontally(position.x() - distance)
	}
	
	method getXFromPosition(position) {
		return position.x() - 1
	}
	
	method getYFromPosition(position) {
		return position.y()
	}
	
	method doorAsset() = "leftDoor"
	
	method positionInMiddle() {
		return new MutablePosition(x = gameConfig.doorXOffset(), y = gameConfig.yMiddle())
	}
	
	method imageModifier() = "-left"
	
	method positionNStepsInto(n) {
		const nextPosition = dummiePosition.withPosition(middlePosition.x(), middlePosition.y())
		nextPosition.right(n)
		return nextPosition
	}
	
}

object right {
	const property door = new Door(facingDirection = self, baseImageName = self.doorAsset(), gravity = global.gravity(), initialX = self.positionInMiddle().x(), initialY = self.positionInMiddle().y())
	const middlePosition = self.positionInMiddle()	
	
	method oposite() = left
	
	method onInput(movementController) {
		movementController.movableEntity().direction().direction(self)
		movementController.movableEntity().goRight()
	}
	
	method collisionsFrom(x, y) {
		return game.getObjectsIn(dummiePosition.withPosition(x.truncate(0) + 1, y))
	}
	
	method getFromPosition(position) {
		return game.at(position.x() + 1, position.y())
	}
	
	method advance(distance, position) {
		position.right(distance)
	}
	
	method canAdvanceTo(position, distance) {
		return gameConfig.canMoveHorizontally(position.x() + distance)
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
		return new MutablePosition(x = gameConfig.width() - gameConfig.doorXOffset(), y = gameConfig.yMiddle())
	}
	
	method positionNStepsInto(n) {
		const nextPosition = dummiePosition.withPosition(middlePosition.x(), middlePosition.y())
		nextPosition.left(n)
		return nextPosition
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
	
	method mix() {
		elements.sortedBy{
			a, b => randomizer.fiftyBool()
		}
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
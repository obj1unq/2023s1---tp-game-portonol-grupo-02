import wollok.game.*
import gameConfig.*

class Graph {
	
	const property nodes = []
	const maxQuantity
	const pendingNodes = new Queue()
	var nodesQuantity = 0
	const property startingNode = new Node(position = game.at(0, 0))
		
	method generate() {
		pendingNodes.enqueue(startingNode)
		nodes.add(startingNode)
		nodesQuantity++
		self.generateGraphsUntilFinish()
	}
	
	method nodesWithNNeighbours(n) {
		return nodes.filter { room => room.neighboursQuantity() == n}
	}
	
	method generateGraphsUntilFinish() {
		if(nodesQuantity < maxQuantity && not pendingNodes.isEmpty()) {
			self.generateNeighboursFor(pendingNodes.dequeue())
			self.generateGraphsUntilFinish()
		} else if(nodesQuantity < maxQuantity) {
			pendingNodes.enqueue(nodes.anyOne())
			self.generateGraphsUntilFinish()
		}
	}
	
	method generateNeighboursFor(node) {
		directionManager.directions().forEach { dir =>
				const newNeighbourDirection = node.getRandomNeighbourDirection()
				const newNeighbourPosition = newNeighbourDirection.getFromPosition(node.position())
				
				if(self.canVisitNeighbour(newNeighbourPosition)) {
					const neighbour = self.neighbourFor(node, newNeighbourDirection)
					node.addNeighbourInDirection(neighbour, newNeighbourDirection)
					neighbour.addNeighbourInDirection(node, newNeighbourDirection.oposite())
					pendingNodes.enqueue(neighbour)
				}
		}
	}
	
	method isNeighbourInPosition(position) {
		return nodes.any {
			node => node.position() == position
		}
	}
	
	method canVisitNeighbour(neighbourPosition) {
		return randomizer.fiftyBool() and not self.isNeighbourInPosition(neighbourPosition) and nodesQuantity < maxQuantity
	}
	
	method neighbourFor(dungeonRoom, direction) {
		
		const neighbourPosition = direction.getFromPosition(dungeonRoom.position())
		
		const neighbour = nodes.findOrDefault({
						room => room.position() == neighbourPosition and room.position().y() == neighbourPosition.y()
			   		}, null)
		
		return if(neighbour == null) {
			const newNeighbour = new Node(position = neighbourPosition)
			nodes.add(newNeighbour)
			nodesQuantity++
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
	
	method neighboursQuantity() = neighbours.size()
}

object directionManager {
	
	const property directions = [top, bottom, left, right]
	
	method getRandomDirection() = directions.anyOne()
}

object top {
	method oposite() = bottom
	
	method getFromPosition(position) {
		return game.at(position.x(), position.y() + 1)
	}
	
	method doorAsset() = "topDoor.png"
	
	method positionInMiddle() {
		return game.at(gameConfig.xMiddle(), gameConfig.height() - gameConfig.doorYOffset())
	}
	
	method positionNStepsInto(n) {
		return self.positionInMiddle().down(n)
	}
	
}

object bottom {
	method oposite() = top
	
	method getFromPosition(position) {
		return game.at(position.x(), position.y() - 1)
	}
	
	method doorAsset() = "bottomDoor.png"
	
	method positionInMiddle() {
		return game.at(gameConfig.xMiddle(), gameConfig.doorYOffset())
	}
	
	method positionNStepsInto(n) {
		return self.positionInMiddle().up(n)
	}
	
}

object left {
	method oposite() = right
	
	method getFromPosition(position) {
		return game.at(position.x() - 1, position.y())
	}
	
	method doorAsset() = "leftDoor.png"
	
	method positionInMiddle() {
		return game.at(gameConfig.doorXOffset(), gameConfig.yMiddle())
	}
	
	method positionNStepsInto(n) {
		return self.positionInMiddle().right(n)
	}
	
}

object right {
	method oposite() = left
	
	method getFromPosition(position) {
		return game.at(position.x() + 1, position.y())
	}
	
	method doorAsset() = "rightDoor.png"
	
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
	
	method enqueue(element) {
		elements.add(element)
	}
	
	method isEmpty(){
		return elements.size() == 0
	}
	
	method asList() = elements
	
}
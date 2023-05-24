import wollok.game.*

class Image {
	const property image
	var property position
}

class Level {
	
	const property dungeonRooms = []
	const maxRooms
	const pendingRooms = new Queue()
	var roomQuantity = 0
	const startRoom = new DungeonRoom(position = game.at(0, 0))
		
	method generate() {
		pendingRooms.enqueue(startRoom)
		dungeonRooms.add(startRoom)
		roomQuantity++
		self.generateRoomsUntilFinish()
		self.logRoomStructure()
		self.createBossRoom()
	}
	
	method roomsWithNNeighbours(n) {
		return dungeonRooms.filter { room => room.neighboursQuantity() == n}
	}
	
	method createBossRoom() {
		var roomsWithOneNeighbour = self.roomsWithNNeighbours(1)
		
		if(roomsWithOneNeighbour == []) {
			roomsWithOneNeighbour = self.roomsWithNNeighbours(2)
		}
		
		const bossRoom = roomsWithOneNeighbour.last()
		
		bossRoom.isBossRoom(true)
		
	}
	
	method logRoomStructure() {
		dungeonRooms.forEach {
			room =>
				console.println("ROOM =")
				console.println(room)
				console.println("NEIGHBOURS =")
				room.logNeighbours()
				console.println("============")
		}
	}
	
	method generateRoomsUntilFinish() {
		if(roomQuantity < maxRooms && not pendingRooms.isEmpty()) {
			self.generateNeighboursFor(pendingRooms.dequeue())
			self.generateRoomsUntilFinish()
		} else if(roomQuantity < maxRooms) {
			pendingRooms.enqueue(dungeonRooms.anyOne())
			self.generateRoomsUntilFinish()
		}
	}
	
	method generateNeighboursFor(dungeonRoom) {
		directionManager.directions().forEach { dir =>
				const newNeighbourDirection = dungeonRoom.getRandomNeighbourDirection()
				const newNeighbourPosition = newNeighbourDirection.getFromPosition(dungeonRoom.position())
				
				if(self.canVisitNeighbour(newNeighbourPosition)) {
					const neighbour = self.neighbourFor(dungeonRoom, newNeighbourDirection)
					dungeonRoom.addNeighbourInDirection(neighbour, newNeighbourDirection)
					neighbour.addNeighbourInDirection(dungeonRoom, newNeighbourDirection.oposite())
					pendingRooms.enqueue(neighbour)
				}
		}
	}
	
	method isNeighbourInPosition(position) {
		return dungeonRooms.any {
			room => room.position() == position
		}
	}
	
	method canVisitNeighbour(neighbourPosition) {
		return randomizer.fiftyBool() and not self.isNeighbourInPosition(neighbourPosition) and roomQuantity < maxRooms
	}
	
	method neighbourFor(dungeonRoom, direction) {
		
		const neighbourPosition = direction.getFromPosition(dungeonRoom.position())
		
		const neighbour = dungeonRooms.findOrDefault({
						room => room.position() == neighbourPosition and room.position().y() == neighbourPosition.y()
			   		}, null)
		
		return if(neighbour == null) {
			const newNeighbour = new DungeonRoom(position = neighbourPosition)
			dungeonRooms.add(newNeighbour)
			roomQuantity++
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


class DungeonRoom {
	const property position
	const neighbours = new Dictionary()
	var property isBossRoom = false
	
	method addNeighbourInDirection(neighbour, direction) {
		neighbours.put(direction, neighbour)
	}
	
	method getRandomNeighbourDirection() {
		return directionManager.getRandomDirection()
	}
	
	method logNeighbours() {
		neighbours.keys().forEach {
			key => 
				console.println(key)
				console.println(neighbours.get(key))
		}
	}
	
	method neighboursQuantity() = neighbours.size()
	
	method piso(){
		return if(isBossRoom) {
			console.println("cant vecinos =")
			console.println(self.neighboursQuantity())
			"rojo.png"
		} else if(position.x() == 0 and position.y() == 0){
			"celeste.png"
		} else { "muro.png" }
	}
	
	method doorAssets() {
		return neighbours.keys().map{ 
			neighbourDirection =>
				new Image(image = neighbourDirection.doorAsset(), position = position)
		}
	}
	
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
}

object bottom {
	method oposite() = top
	
	method getFromPosition(position) {
		return game.at(position.x(), position.y() - 1)
	}
	
	method doorAsset() = "bottomDoor.png"
	
}

object left {
	method oposite() = right
	
	method getFromPosition(position) {
		return game.at(position.x() - 1, position.y())
	}
	
	method doorAsset() = "leftDoor.png"
	
}

object right {
	method oposite() = left
	
	method getFromPosition(position) {
		return game.at(position.x() + 1, position.y())
	}
	
	method doorAsset() = "rightDoor.png"
	
}

class Stack {
	var elements = []
	
	method pop() {
		const element = elements.last()
		elements = elements.subList(0, elements.size() - 1)
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
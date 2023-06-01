import wollok.game.*
import Input.inputManager
import Position.*
import SoundEffect.*

class MovementController {

	var movableEntity

	method movableEntity(_movableEntity) {
		movableEntity = _movableEntity
	}

	method movableEntity() {
		return movableEntity
	}

	method init() {
		inputManager.suscribe(self)
	}

	method remove() {
		inputManager.unsuscribe(self)
	}

	method onDispatchInput(input)

	method goUp() {
		self.movableEntity().move(0, 1)
	}

	method goLeft() {
		self.movableEntity().move(-1, 0)
	}

	method goDown() {
		self.movableEntity().move(0, -1)
	}

	method goRight() {
		self.movableEntity().move(1, 0)
	}

	method goUp(n) {
		self.movableEntity().move(0, n)
	}

	method goLeft(n) {
		self.movableEntity().move(-n, 0)
	}

	method goDown(n) {
		self.movableEntity().move(0, -n)
	}

	method goRight(n) {
		self.movableEntity().move(n, 0)
	}

}

class StaticMovementManager inherits MovementController {

	override method movableEntity(_movableEntity) {
	}

	override method movableEntity() {
		return null
	}

	override method onDispatchInput(input) {
	}

	override method init() {
	}

	override method remove() {
	}

	override method goUp() {
	}

	override method goLeft() {
	}

	override method goDown() {
	}

	override method goRight() {
	}

	override method goUp(n) {
	}

	override method goLeft(n) {
	}

	override method goDown(n) {
	}

	override method goRight(n) {
	}

}

class GravityController {

	const property bodies = #{}
	var tickTime
	var name
	var gameInstance
	var continue = false

	method suscribe(body) {
		bodies.add(body)
	}

	method unsuscribe(body) {
		bodies.remove(body)
	}

	method init() {
		continue = true
		self.start()
	}

	method pause() {
		continue = false
		gameInstance.removeTick(name)
	}

	method start() {
		gameInstance.onTick(tickTime, name, { if (continue) self.applyGravity(tickTime)
		})
	}

	method applyGravity(time) {
		bodies.forEach{ element => 
			element.update(time)
		}
	}

}

class CollidableMovementController inherits MovementController {

	method moveRightIfCan(distance) {
		if (not self.movableEntity().isCollidingFrom(derecha)) {
			self.movableEntity().move(distance, 0)
		}
	}

	method moveLeftIfCan(distance) {
		if (not self.movableEntity().isCollidingFrom(izquierda)) {
			self.movableEntity().move(-distance, 0)
		}
	}
	
	method moveUpIfCan(distance) {
		if (not self.movableEntity().isCollidingFrom(arriba)) {
			self.movableEntity().move(0, distance)
		}
	}
	
	method moveDownIfCan(distance) {
		if (not self.movableEntity().isCollidingFrom(abajo)) {
			self.movableEntity().move(0, -distance)
		}
	}

	override method goUp() {
		self.moveUpIfCan(1)
	}
	
	override method goUp(n) {
		self.moveUpIfCan(n)
	}
	
	override method goDown() {
		self.moveDownIfCan(1)
	}
	
	override method goDown(n) {
		self.moveDownIfCan(n)
	}

	override method goLeft() {
		self.moveLeftIfCan(1)
	}

	override method goRight() {
		self.moveRightIfCan(1)
	}

	override method goLeft(n) {
		self.moveLeftIfCan(n)
	}

	override method goRight(n) {
		self.moveRightIfCan(n)
	}

}

class CharacterMovementController inherits CollidableMovementController {

	override method onDispatchInput(input) {
		if (input == "left") {
			self.goLeft()
		} else if (input == "right") {
			self.goRight()
		} else if(input == "up") {
			self.goUp()
		} else if(input == "down") {
			self.goDown()
		}
	}

}

class EnemyMovementController inherits CollidableMovementController {
	
	override method onDispatchInput(input) {}
	
}


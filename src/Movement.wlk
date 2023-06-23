import wollok.game.*
import Input.inputManager
import Position.*
import SoundEffect.*
import CooldownManager.*
import structureGenerator.*
import gameConfig.gameConfig

class MovementController {

	var movableEntity
	var property facingDirection = bottom

	method movableEntity(_movableEntity) {
		movableEntity = _movableEntity
	}

	method movableEntity() {
		return movableEntity
	}
	
	method canMoveTo(direction) {
		return gameConfig.isInMapLimits(
				direction.getXFromPosition(movableEntity.position()),
				direction.getYFromPosition(movableEntity.position())			
			)
	}

	method init() {}

	method remove() {}

	method goUp() {
		self.goUp(1)
	}

	method goLeft() {
		self.goLeft(1)
	}

	method goDown() {
		self.goDown(1)
	}

	method goRight() {
		self.goRight(1)
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

	override method canMoveTo(direction) {
		return super(direction) and not self.movableEntity().isCollidingFrom(direction)
	}

	method moveRightIfCan(distance) {
		if (self.canMoveTo(right)) {
			self.movableEntity().move(distance, 0)
		}
	}

	method moveLeftIfCan(distance) {
		if (self.canMoveTo(left)) {
			self.movableEntity().move(-distance, 0)
		}
	}
	
	method moveUpIfCan(distance) {
		if (self.canMoveTo(top)) {
			self.movableEntity().move(0, distance)
		}
	}
	
	method moveDownIfCan(distance) {
		if (self.canMoveTo(bottom)) {
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

	override method init() {
		inputManager.suscribe(self)
	}

	override method remove() {
		inputManager.unsuscribe(self)
	}

	method onDispatchInput(input) {
		input.onInput(self)
	}

}

class CooldownMovementController inherits CollidableMovementController {
	
	const property onMovementCooldown = new OnMovementCooldown(movementManager = self, totalCooldownTime = movableEntity.movementCooldownReload())
	const property notOnMovementCooldown = new NotOnMovementCooldown(movementManager = self, totalCooldownTime = movableEntity.movementCooldown())
	var property movementCooldown = notOnMovementCooldown
	
	method onTimePassed(time) {
		movementCooldown.onTimePassed(time)
	}
	
	override method canMoveTo(direction) = super(direction) && movementCooldown.canMove()
		
}

class DirectionSpriteModifier {
	
	method imageModifier()
	
	method direction(_direction)
	
}

class NullDirectionSpriteModifier inherits DirectionSpriteModifier {
	
	override method imageModifier() = ""
	
	override method direction(_direction) {}
	
}

class StateDirectionSpriteModifier inherits DirectionSpriteModifier {
	
	var direction = bottom
	
	override method imageModifier() = direction.imageModifier()
	
	override method direction(_direction){
		direction = _direction
	}
	
}



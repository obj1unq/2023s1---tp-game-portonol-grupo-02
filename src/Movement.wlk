import wollok.game.*
import Input.inputManager
import Position.*
import SoundEffect.*

class JumpManager {

	method entity()

	method entity(entity)

	method jump()

	method resetJump()

	method isJumping()

	method onJump(callback)

}

class StaticJumpManager inherits JumpManager {

	var entity

	override method entity() {
	}

	override method entity(_entity) {
		return entity
	}

	override method jump() {
	}

	override method resetJump() {
	}

	override method isJumping() {
		return false
	}

	override method onJump(callback) {
	}

}

class SimpleJumpManager inherits JumpManager {

	const jumpEffect = silenceJumpEffect
	var entity = null
	var isJumping = false
	var jumpCallback = {
	}

	override method jump() {
		if (not isJumping and self.entity().isCollidingFrom(abajo)) {
			isJumping = true
			jumpCallback.apply()
			jumpEffect.play()
		}
	}

	override method onJump(_jumpCallback) {
		jumpCallback = _jumpCallback
	}

	method jumpCallback() = jumpCallback

	override method resetJump() {
		isJumping = false
	}

	override method entity() = entity

	override method entity(_entity) {
		entity = _entity
	}

	method isJumping() = isJumping

}

class MovementController {

	var movableEntity
	var jumpCallback = {
	}
	var jumpManager = new StaticJumpManager(entity = movableEntity)

	method jumpManager(_jumpManager) {
		jumpManager = _jumpManager
		jumpManager.entity(self.movableEntity())
		jumpManager.onJump(jumpCallback)
	}

	method jumpManager() = jumpManager

	method onJump(cb) {
		jumpCallback = cb
		jumpManager.onJump(cb)
	}

	method movableEntity(_movableEntity) {
		movableEntity = _movableEntity
		jumpManager.entity(movableEntity)
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

	method isJumping() = jumpManager.isJumping()

	method onFloorTouched() {
		jumpManager.resetJump()
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

	method jump() {
		jumpManager.jump()
	}

}

class StaticMovementManager inherits MovementController {

	override method jumpManager(_jumpManager) {
	}

	override method onJump(cb) {
	}

	override method movableEntity(_movableEntity) {
	}

	override method movableEntity() {
		return null
	}

	override method isJumping() = false

	override method onFloorTouched() {
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

	override method jump() {
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
		console.println(bodies)
		console.println(body)
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
		bodies.forEach{ element => element.update(time)}
	}

}

class DoubleJumpManager inherits SimpleJumpManager {

	var hasDoubleJump = true

	override method jump() {
		if (isJumping and hasDoubleJump and not self.entity().isCollidingFrom(arriba)) {
			self.jumpCallback().apply()
			hasDoubleJump = false
		}
		super()
	}

	override method resetJump() {
		super()
		hasDoubleJump = true
	}

}

class CollidableMovementController inherits MovementController {

	method moveRightIfCan(distance) {
		if (not self.movableEntity().isCollidingFrom(derecha)) {
			self.movableEntity().move(distance, 0)
		} else {
			self.moveToFixPositionInX()
		}
	}

	method moveLeftIfCan(distance) {
		if (not self.movableEntity().isCollidingFrom(izquierda)) {
			self.movableEntity().move(-distance, 0)
		} else {
			self.moveToFixPositionInX()
		}
	}
	
	method moveToFixPositionInX() {
		const positionX = self.movableEntity().originPosition().x()
		const movementToFixPosition = positionX.truncate(0) - positionX
		self.movableEntity().move(movementToFixPosition, 0)
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
		} else if (input == "space") {
			self.jump()
		}
	}

}

class EnemyMovementController inherits CollidableMovementController {
	
	override method init() {}
	override method remove() {}
	override method onDispatchInput(input) {}
	
}


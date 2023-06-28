import wollok.game.*
import Input.inputManager
import Position.*
import SoundEffect.*
import CooldownManager.*
import structureGenerator.*
import gameConfig.gameConfig
import Input.south
import Global.global

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

object staticMovementManager inherits MovementController(movableEntity = null) {

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
		gameInstance.removeTickEvent(name)
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

object nullishGravityController inherits GravityController(gameInstance = null, name = null, tickTime = null) {
	
	override method suscribe(body) {}

	override method unsuscribe(body) {}
	
	override method init() {}

	override method pause() {}

	override method start() {}
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
	
	method direction() = direction
	
}

class MovementDirectionManager {
	var horizontalDirection = right
	var verticalDirection = top
	
	method move(entity, distance) {
		
		const canMoveHorizontally = gameConfig.canMoveHorizontally(horizontalDirection.getXFromPosition(entity.position()))
		const canMoveVertically = gameConfig.canMoveVertically(verticalDirection.getYFromPosition(entity.position()))
		
		if(not canMoveHorizontally) {
			horizontalDirection = horizontalDirection.oposite()
		}
		
		if(not canMoveVertically) {
			verticalDirection = verticalDirection.oposite()
		}
						
		verticalDirection.advance(distance, entity.position())
		horizontalDirection.advance(distance, entity.position())

	}
	
}

class ChargeToPlayerMovement {
	
	const entity
	const property verticalMovement = new VerticalChargeBehaviour(chargeToPlayerMovement = self)
	const property horizontalMovement = new HorizontalChargeBehaviour(chargeToPlayerMovement = self)
	var property movementBehaviour = verticalMovement

	method advance(time) {
		movementBehaviour.advance(time, entity)
	}
	
	method changeToVerticalMovement() {
		movementBehaviour = verticalMovement
	}
	
	method changeToHorizontalMovement() {
		horizontalMovement.chasePlayer(entity)
		movementBehaviour = horizontalMovement
	}
	
}

class VerticalChargeBehaviour {
	const chargeToPlayerMovement
	var direction = top
	
	method advance(time, entity) {
		if(global.player().position().y() == entity.position().y().truncate(0)) {
			chargeToPlayerMovement.changeToHorizontalMovement()
		} else if(direction.canAdvanceTo(entity.position(), entity.verticalMovementByTime(time))) {
			direction.advance(entity.verticalMovementByTime(time), entity.position())
		} else {
			direction = direction.oposite()
		}
	}
}

class HorizontalChargeBehaviour {
	const chargeToPlayerMovement
	var direction = right
	
	method advance(time, entity) {
		if(direction.canAdvanceTo(entity.position(), entity.horizontalMovementByTime(time))) {
			direction.advance(entity.horizontalMovementByTime(time), entity.position())
		} else {
			chargeToPlayerMovement.changeToVerticalMovement()
		}
	}
	
	method chasePlayer(entity) {
		const playerXPosition = global.player().position().x()
		if(entity.position().x() > playerXPosition) {
			direction = left
		} else {
			direction = right
		}
	}
}

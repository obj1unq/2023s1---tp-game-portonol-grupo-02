import Position.*
import Damage.DamageManager
import wollok.game.*
import Sprite.Renderable
import Movement.StaticMovementManager

class Entity inherits Renderable {

	var initialY = 0
	var initialX = 0

	method game() = game

	method initialPositions(x, y) {
		initialX = x
		initialY = y
	}

	method onAttach() {
		self.render(initialX, initialY)
	}

	method onRemove() {
		self.unrender()
	}

	method isCollidable() {
		return false
	}

}

class MovableEntity inherits CollapsableEntity {

	var movementController = new StaticMovementManager(movableEntity = null)

	method jump() {
		movementController.jump()
	}

	method onJump(cb) {
		movementController.onJump(cb)
	}

	method goUp() {
		movementController.goUp(1)
	}

	method goLeft() {
		movementController.goLeft(1)
	}

	method goDown() {
		movementController.goDown(1)
	}

	method goRight() {
		movementController.goRight(1)
	}

	method goUp(n) {
		movementController.goUp(n)
	}

	method goLeft(n) {
		movementController.goLeft(n)
	}

	method goDown(n) {
		movementController.goDown(n)
	}

	method goRight(n) {
		movementController.goRight(n)
	}

	method isJumping() = movementController.isJumping()

	method touchFloor() {
		movementController.onFloorTouched()
	}

	override method onAttach() {
		super()
		movementController.init()
	}

	override method onRemove() {
		super()
		movementController.remove()
	}

	method movementController() = movementController

	method setMovementController(_movementController) {
		movementController = _movementController
	}

	method changeMovementController(_movementController) {
		movementController.remove()
		movementController = _movementController
		movementController.init()
	}

}

class GravityEntity inherits MovableEntity {

	var property gravity
	var property maxJumpHeight = 3
	var velocityY = 0
	const gravityY = 1
	var lastLastY = null
	var lastY = null

	method isFalling() = lastLastY != null and lastLastY > lastY and lastY != null and lastY >= self.originPosition().y()

	method gravity() = gravity

	method gravity(_gravity) {
		gravity = _gravity
	}

	override method onAttach() {
		super()
		self.gravity().suscribe(self)
		self.onJump({ velocityY = -maxJumpHeight;})
		lastY = self.originPosition().y()
		lastLastY = lastY
	}

	override method onRemove() {
		self.gravity().unsuscribe(self)
	}

	override method onCollision(colliders) {
		if (colliders.any({ collider => collider.hadCollidedWithBlock() })) {
			if (lastY < self.originPosition().y()) {
				self.move(0, -1)
			} else if (lastY > self.originPosition().y()) {
				self.move(0, lastY - self.originPosition().y())
				self.touchFloor()
			}
		}
	}

	method update(time) {
		if (self.isFalling() and self.isCollidingFrom(abajo)) {
			velocityY = 0
			self.move(0, (lastY - self.originPosition().y()).truncate(0))
			self.touchFloor()
		} else if (not self.isFalling()) {
			velocityY += gravityY
			self.move(0, -velocityY.limitBetween(-1, 1))
			self.checkForCollision()
		}
	}

	method maxJumpHeight() = maxJumpHeight

	method maxJumpHeight(_maxJumpHeight) {
		maxJumpHeight = _maxJumpHeight
		self.onJump({ velocityY = -_maxJumpHeight;})
	}

}

class CollapsableEntity inherits Entity {

	method isCollapsing() {
		return self.collisions().size() > 0
	}

	method collisions() {
		const collisions = []
		self.forEach({ img , x , y => collisions.addAll(self.game().colliders(img).filter{ collider => collider.isCollidable()})})
		return collisions
	}

	method isCollidingFrom(direction) {
		console.println(self.originPosition())
		return self.any{ img , x , y => self.collisionsFrom(direction, x, y).any{ collider =>
			console.println(img.position())
			collider.isCollidable()
		} }
	}

	method collisionsFrom(direction, x, y) {
		return if (direction == arriba) {
			self.game().getObjectsIn(self.game().at(x, y + 1))
		} else if (direction == abajo) {
			self.game().getObjectsIn(self.game().at(x, y - 1))
		} else if (direction == izquierda) {
			self.game().getObjectsIn(self.game().at(x - 1, y))
		} else if (direction == derecha) {
			self.game().getObjectsIn(self.game().at(x + 1, y))
		}
	}

	method isCollidingFromTopOrBottom() {
		return self.isCollidingFrom(arriba) or self.isCollidingFrom(abajo)
	}

	method checkForCollision() {
		const colliders = self.collisions()
		if (colliders.size() > 0) {
			self.onCollision(colliders)
		}
	}

	method onCollision(colliders)

}

class DamageEntity inherits GravityEntity {

	var damage
	var hp
	var maxHp

	method damage() = damage

	method takeDmg(dmg) {
		hp -= dmg
	}

	method isDead() = hp <= 0

/* 
 *     override method update(time){
 *         super(time)
 *         
 *     }
 * 
 */
}

class EnemyDamageEntity inherits DamageEntity {

	var damageManager = new DamageManager()

	override method takeDmg(damage) {
		super(damage)
		if (self.isDead()) {
			self.onRemove()
		}
	}

}

class PlayerDamageEntity inherits DamageEntity {

	override method takeDmg(damage) {
		super(damage)
		if (self.isDead()) {
			// Game over logic. We probably need to implement a pause in the game with a button to return to main menu or something.
			self.game().stop()
		}
	}

}

class FightEntity inherits Entity {

	var isEnemy

}


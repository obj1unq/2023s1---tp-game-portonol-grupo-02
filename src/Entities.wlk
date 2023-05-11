import Position.*
import Damage.*
import wollok.game.*
import Sprite.*
import Movement.*

class Entity inherits Renderable {
	
	var initialY = 0
	var initialX = 0
		
	method game() = game
		
	method initialPositions(x, y){
		initialX = x
		initialY = y
	}
	
	method onAttach(){
		self.render(initialX, initialY)
	}
	
	method onRemove(){
		self.unrender()
	}
	
	method isCollidable(){
		return false
	}
	
	method isEnemy() {
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
	var velocityY = 10
	const gravityY = 0.5
	var lastY = null
	
	method gravity() = gravity

	method gravity(_gravity) {
		gravity = _gravity
	}

	override method onAttach() {
		super()
		self.gravity().suscribe(self)
		self.onJump({ velocityY = -maxJumpHeight; })
		lastY = self.originPosition().y()
	}

	override method onRemove() {
		super()
		self.gravity().unsuscribe(self)
	}

	override method onCollision(colliders) {
		// No hace nada
	}

	method validateMovement() {
		if(self.collisions().any({ collider => collider.hadCollidedWithBlock()})){
			
			if(lastY < self.originPosition().y()) {
				self.move(0, velocityY.limitBetween(-1, 1))
				velocityY = 0
			} else {
				self.move(0, velocityY.limitBetween(-1, 1))
				velocityY = 0
				self.touchFloor()
			}
		}
	}

	method update(time) {
					
		velocityY += gravityY
		self.move(0, -velocityY.limitBetween(-1, 1))
		
		self.validateMovement()
				
		self.checkForCollision()
			
		lastY = self.originPosition().y()
	
	}

	method maxJumpHeight() = maxJumpHeight

	method maxJumpHeight(_maxJumpHeight) {
		maxJumpHeight = _maxJumpHeight
		self.onJump({ velocityY = -_maxJumpHeight; })
	}

}

class CollapsableEntity inherits Entity {

	method isCollapsing() {
		return self.collisions().size() > 0
	}

	method collisions() {
		const collisions = []

		self.forEach({img, x, y => 
			collisions.addAll(
				self.game().colliders(img).filter{
					coll => not coll.isPartOfEntity(self)
				}
			)
		})
		
		return collisions
	}

	method isCollidingFrom(direction) {
		return self.any{ img , x , y => 
			self.collisionsFrom(direction, x, y).any{ 
				collider => 
				not self.isPartOfThisEntity(collider) and collider.isCollidable()
			}
		}
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
	var cooldown
	var property onCooldown = false

	method damage() = damage

	method hp() = hp * 100 / maxHp

	method cooldown() = cooldown

	method takeDmg(dmg) {
		hp -= dmg
	}

	method isDead() = hp <= 0

}

class EnemyDamageEntity inherits DamageEntity {

	var damageManager = new DamageManager()

	override method onCollision(colliders) {

		super(colliders)
		
		if (colliders.any({ collider => collider.hasEntity() and collider.entity().isPlayer() && not onCooldown })) {
			console.println("enemigo: collision entre player y enemigo")
			const aPlayer = colliders.find({ collider => collider.entity().isPlayer() }).entity()
			console.println(aPlayer)
			damageManager.dealDmg(self, aPlayer)
		}
	}
	
	override method onRemove() {
		super()
		console.println("murió")
	}

	override method isEnemy() = true

	override method takeDmg(damage) {
		super(damage)
		if (self.isDead()) {
			self.onRemove()
		}
	}

}

class PlayerDamageEntity inherits DamageEntity {

	var damageManager = new DamageManager()

//	override method onCollision(colliders) {
//		super(colliders)
//		if (colliders.any({ collider => collider.hasEntity() and collider.entity().isEnemy() }) && not onCooldown) {
//			const anEnemy = colliders.find({ collider => collider.entity().isEnemy() }).entity()
//			damageManager.dealDmg(self, anEnemy)
//			/*onCooldown = true
//			game.onTick(self.cooldown(), "Player Damage Cooldown", { onCooldown = false
//				game.removeTickEvent("Player Damage Cooldown")
//			})*/
//		}
//	}
	
	override method isPlayer() = true

	override method takeDmg(damage) {
		super(damage)
		console.println("sufrió daño")
		if (self.isDead()) {
			// Game over logic. We probably need to implement a pause in the game with a button to return to main menu or something.
//			self.game().stop()
			self.say("me morí")
		}
	}

}


import Position.*
import Damage.DamageManager
import wollok.game.*
import Sprite.Renderable
import Movement.StaticMovementManager
import gameConfig.*
import Global.global

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

}


class MovableEntity inherits CollapsableEntity {

	var property movementController = new StaticMovementManager(movableEntity = null)

	method moveDistance(x, y) {
		movementController.goUp(y)
		movementController.goRight(x)
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
	
	method gravity() = gravity

	method gravity(_gravity) {
		gravity = _gravity
	}

	override method onAttach() {
		super()
		self.gravity().suscribe(self)
	}
	
	override method onCollision(colliders) {
		
	}

	override method onRemove() {
		super()
		self.gravity().unsuscribe(self)
	}

	method update(time){
//		if(isRendered) {
//			self.checkForCollision()			
//		}
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


	// Aplicar polimorfismo
	method collisionsFrom(direction, x, y) {
		return if (direction == arriba) {
			self.game().getObjectsIn(dummiePosition.inPosition(x, y.truncate(0) + 1))
		} else if (direction == abajo) {
			self.game().getObjectsIn(dummiePosition.inPosition(x, y.truncate(0) - 1))
		} else if (direction == izquierda) {
			self.game().getObjectsIn(dummiePosition.inPosition(x.truncate(0) - 1, y))
		} else if (direction == derecha) {
			self.game().getObjectsIn(dummiePosition.inPosition(x.truncate(0) + 1, y))
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
	var maxHp
	var hp = maxHp
	var cooldown

	method damage() = damage

	method hp() = hp * 100 / maxHp

	method cooldown() = cooldown

	method takeDmg(dmg) {
		hp -= dmg
	}

	method isDead() = hp <= 0

}

class EnemyDamageEntity inherits DamageEntity {

	const damageManager = new DamageManager(entity = self)
	var deathCallback = {}

	method resetState() {
		hp = maxHp
	}

	override method onCollision(colliders) {

		super(colliders)
		
		const enemy = colliders.findOrDefault({ collider => collider.hasEntity() and global.isPlayer(collider.entity()) }, null)
		if (enemy != null){
			damageManager.dealDmg(enemy.entity())
		}
		
	}

	override method takeDmg(damage) {
		super(damage)
		if (self.isDead()) {
			self.onRemove()
		}
	}
	
	override method onRemove(){
		super()
		deathCallback.apply()
	}
	
	override method update(time){
		super(time)
		damageManager.onTimePassed(time)
	}
	
	method setDeathCallback(cb){
		deathCallback = cb
	}

}

class PlayerDamageEntity inherits DamageEntity {

	const damageManager = new DamageManager(entity = self)
	const damageSfx
	const deathSfx

	override method takeDmg(damage) {
		super(damage)
		if (self.isDead()) {
			// Game over logic. We probably need to implement a pause in the game with a button to return to main menu or something.
			// self.game().stop()
			deathSfx.play()
			self.say("me morí")
			self.onRemove()
			global.deathScreen()
		} else {
			damageSfx.play()
		}
	}
	
	override method onRemove() {
		super()
	}
	
	override method update(time) {}

}

class WalkToPlayerEnemy inherits EnemyDamageEntity {
	const player
	var property velocity = 1
	
	override method update(time){
		super(time)
		self.moveTowardsPlayer(time)
	}
	
	method moveTowardsPlayer(time) {
		self.moveDistance(
			self.horizontalMovementTowardsPlayer(time),
			self.verticalMovementTowardsPlayer(time)
		)
	}
		
	method movementTowardsPlayer(time, relativeDistance){
		return if(relativeDistance < 0) {
			- self.movementByTime(time)
		} else {
			self.movementByTime(time)
		}
	}
	
	method horizontalMovementTowardsPlayer(time) {
		return self.movementTowardsPlayer(time, player.originPosition().x() - self.originPosition().x())
	}
	
	method verticalMovementTowardsPlayer(time) {
		return self.movementTowardsPlayer(time, player.originPosition().y() - self.originPosition().y())
	}
	
	method movementByTime(time) {
		return (time * velocity) / 1000
	}
	
}

class Zombie inherits WalkToPlayerEnemy(velocity = 0.5) {}

class Slime inherits WalkToPlayerEnemy(velocity = 1) {}

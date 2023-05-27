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
	
	method gravity() = gravity

	method gravity(_gravity) {
		gravity = _gravity
	}

	override method onAttach() {
		super()
		self.gravity().suscribe(self)
	}

	override method onRemove() {
		super()
		self.gravity().unsuscribe(self)
	}

	override method onCollision(colliders) {
		// No hace nada
	}

	method update(time){
		if(isRendered) {
			self.checkForCollision()			
		}
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
	var hp
	var maxHp
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
	
	override method update(time){
		super(time)
		
		if (damageManager.onCooldown()){
			damageManager.cooldownLeft(damageManager.cooldownLeft() - 1)
		}
		
		if (damageManager.notCooldownLeft()){
			damageManager.resetCooldown()
		}
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
		console.println("Se removió el personaje")
	}
	
	override method update(time) {}

}

class WalkToPlayerEnemy inherits EnemyDamageEntity {
	const player
	var property velocityX = 1
	
	override method update(time){
		super(time)
		self.moveTowardsPlayer(time)
		self.jumpIfShould(time)
	}
	
	method moveTowardsPlayer(time) {
		const relativeDistanceFromPlayer = self.movementTowardsPlayer(time)
		if(not self.isByPlayerSide()) {
			if(relativeDistanceFromPlayer < 0) {
				self.goLeft(- relativeDistanceFromPlayer)
			} else if(relativeDistanceFromPlayer > 0) {
				self.goRight(relativeDistanceFromPlayer)
			}
		}
	}
	
	method jumpIfShould(time) {
		if(self.shouldJump()) {
			self.jump()
		}
	}
	
	method isByPlayerSide() {
		return player.originPosition().x().truncate(0) == self.originPosition().x().truncate(0)
	}
	
	method shouldJump()
	
	method movementTowardsPlayer(time){
		const relativePositionPlayer = player.originPosition().x() - self.originPosition().x()
		return if(relativePositionPlayer < 0) {
			- self.movementByTime(time)
		} else {
			self.movementByTime(time)
		}
	}
	
	method movementByTime(time) {
		return (time * velocityX) / 1000
	}
	
}

class Zombie inherits WalkToPlayerEnemy {
	
	override method shouldJump() = self.isPlayerAbove() and self.isByPlayerSide() 
	
	method isPlayerAbove() {
		return false}
//		return player.originPosition().y() - player.height() > self.originPosition().y()
//	}
	
}

class Slime inherits WalkToPlayerEnemy {
	
	override method moveTowardsPlayer(time) {
		if(self.isJumping()) {
			super(time)
		}
	}
	
	override method shouldJump() = true
	
}

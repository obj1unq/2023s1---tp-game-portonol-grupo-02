import Position.*
import Damage.DamageManager
import wollok.game.*
import Sprite.Renderable
import gameConfig.*
import Global.global
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
	
	override method onCollision(colliders) {}

	override method onRemove() {
		super()
		self.gravity().unsuscribe(self)
	}

	method update(time){}

}

class CollapsableEntity inherits Entity {

	// TODO: Se puede mejorar si se pregunta a los bordes y no a todas las entidades
	method isCollidingFrom(direction) {
		return self.any{ img , x , y => 
			self.collisionsFrom(direction, x, y).any{ 
				collider => 
				not self.isPartOfThisEntity(collider) and collider.isCollidable()
			}
		}
	}

	// TODO: Aplicar polimorfismo
	method collisionsFrom(direction, x, y) {
		return if (direction == arriba) {
			self.game().getObjectsIn(dummiePosition.withPosition(x, y.truncate(0) + 1))
		} else if (direction == abajo) {
			self.game().getObjectsIn(dummiePosition.withPosition(x, y.truncate(0) - 1))
		} else if (direction == izquierda) {
			self.game().getObjectsIn(dummiePosition.withPosition(x.truncate(0) - 1, y))
		} else if (direction == derecha) {
			self.game().getObjectsIn(dummiePosition.withPosition(x.truncate(0) + 1, y))
		}
	}

	method onCollision(collider)

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
	
	method isPlayer(collider) {
		return collider.hasEntity() and global.isPlayer(collider.entity())
	}
	
	method die()

}

class EnemyDamageEntity inherits DamageEntity {

	const damageManager = new DamageManager(entity = self)
	var deathCallback = {}

	method resetState() {
		hp = maxHp
	}

	method playerOrNullishEnemy(collider) {
		return if(self.isPlayer(collider)) {
			collider.entity()
		} else {
			return nullishDamagableEntity
		}
	}

	override method onCollision(collider) {

		super(collider)
		
		damageManager.dealDmg(self.playerOrNullishEnemy(collider))
		
	}

	override method takeDmg(damage) {
		super(damage)
		if (self.isDead()) {
			self.die()
		}
	}
	
	override method die() {
		self.onRemove()
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

object nullishDamagableEntity inherits DamageEntity(cooldown = 0, damage = 0, gravity = null, maxHp = 0) {
	override method takeDmg(dmg) {}
	override method die() {}
}

class PlayerDamageEntity inherits DamageEntity {

	const damageManager = new DamageManager(entity = self)
	const damageSfx
	const deathSfx

	override method takeDmg(damage) {
		super(damage)
		if (self.isDead()) {
			self.die()
		} else {
			self.playDamageSound()
		}
	}
	
	override method die() {
		deathSfx.play()
		self.onRemove()
		global.deathScreen()
	}
	
	method playDamageSound() {
		damageSfx.play()
	}
	
}

class WalkToPlayerEnemy inherits EnemyDamageEntity {
	const player
	var property velocity = 1
	
	method playerPosition() = player.originPosition()
	
	override method update(time){
		super(time)
		self.moveTowardsPlayer(time)
	}
	
	method moveTowardsPlayer(time) {
		if(not self.isInPlayerPosition()) {
			self.moveDistance(
				self.horizontalMovementTowardsPlayer(time).limitBetween(-1, 1),
				self.verticalMovementTowardsPlayer(time).limitBetween(-1, 1)
			)
		}
	}
	
	method isInPlayerPosition() {
		dummiePosition.inPosition(player.xMiddle(), player.yMiddle())
		return self.isInPosition(dummiePosition)
	}
		
	method movementTowardsPlayer(time, relativeDistance){
		return if(relativeDistance < 0) {
			- self.movementByTime(time)
		} else if (relativeDistance > 0) {
			self.movementByTime(time)
		} else { 0 }
	}
	
	method horizontalMovementTowardsPlayer(time) {
		return self.movementTowardsPlayer(time, self.playerPosition().x() - self.originPosition().x().truncate(0))
	}
	
	method verticalMovementTowardsPlayer(time) {
		return self.movementTowardsPlayer(time, self.playerPosition().y() - self.originPosition().y().truncate(0))
	}
	
	method movementByTime(time) {
		return (time * velocity) / 1000
	}
	
}

class DelayedWalkToPlayerEnemy inherits WalkToPlayerEnemy {
	var property movementCooldown
	var property movementCooldownReload
	
	method onStartWalking()
	
}

class Zombie inherits WalkToPlayerEnemy(velocity = 1) {}

class Fly inherits WalkToPlayerEnemy(velocity = 2) {}

class Slime inherits DelayedWalkToPlayerEnemy(velocity = 15, movementCooldown = 400, movementCooldownReload = 400) {
	const lastPlayerPosition = new MutablePosition(x = player.originPosition().x(), y = player.originPosition().y())
	
	override method update(time){
		super(time)
		movementController.onTimePassed(time)
	}
	
	override method playerPosition() = lastPlayerPosition
	
	override method onStartWalking() {
		lastPlayerPosition.inPosition(player.originPosition().x(), player.originPosition().y())
	}
	
}

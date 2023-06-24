import Position.*
import Damage.DamageManager
import wollok.game.*
import Sprite.Image
import gameConfig.*
import Global.global
import Movement.*
import weapons.*
import structureGenerator.*
import pools.poolRemoveBehaviour

class Entity inherits Image {
	
	var initialY = 0
	var initialX = 0
				
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
	
	override method isCollidable(){
		return false
	}

}


class MovableEntity inherits CollapsableEntity {

	var property movementController = staticMovementManager

	var direction = new NullDirectionSpriteModifier()

	override method state() = super() + direction.imageModifier()
	
	method moveDistance(x, y) {
		self.goUp(y)
		self.goRight(x)
	}

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
		direction.direction(top)
		movementController.goUp(n)
	}

	method goLeft(n) {
		direction.direction(left)
		movementController.goLeft(n)
	}

	method goDown(n) {
		direction.direction(bottom)
		movementController.goDown(n)
	}

	method goRight(n) {
		direction.direction(right)
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

	method update(time){}

}

class CollapsableEntity inherits Entity {

	method isCollidingFrom(direction) {
		return direction.collisionsFrom(self.position().x(), self.position().y()).any{ 
				collider => collider.isCollidable()
			}
	}
	
}


class DamageEntity inherits GravityEntity {

	var damage
	var maxHp
	var hp = maxHp
	var cooldown

	method damage() = damage

	method hp() = hp

	method cooldown() = cooldown

	method takeDmg(dmg) {
		hp -= dmg
	}
	
	method addDamage(quantity) {
		damage += quantity
	}
	
	method heal(quantity) {
		hp = maxHp.min(hp + quantity)
	}

	method isDead() = hp <= 0
	
	method attack() {}
	
	method die()

}


class EnemyDamageEntity inherits DamageEntity {
	const removeBehaviour = poolRemoveBehaviour
	const damageManager = new DamageManager(entity = self)
	var deathCallback = {}

	method resetState() {
		hp = maxHp
	}

	override method onAttach() {
		super()
		global.addEnemy(self)
	}

	method playerOrNullishEnemy(collider) {
		return if(global.isPlayer(collider)) {
			collider
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
		console.println("recibio daño, nueva vida = " + hp)
		if (self.isDead()) {
			console.println("ripeé")
			self.die()
		}
	}
	
	override method die() {
		self.onRemove()
	}
	
	override method onRemove(){
		super()
		deathCallback.apply()
		global.removeEnemy(self)
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

class PlayerDamageEntity inherits DamageEntity(direction = new StateDirectionSpriteModifier()) {
	const weapon = new MeleeWeapon()
	const property damageManager = new DamageManager(entity = self)
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
	
	override method update(time){
		super(time)
		damageManager.onTimePassed(time)
	}
	
	override method attack() {
		weapon.attack(self)
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
	
	method playerPosition() = player.position()
	
	override method update(time){
		super(time)
		self.moveTowardsPlayer(time)
	}
	
	method moveTowardsPlayer(time) {
		if(not self.isInPlayerPosition()) {
			const movementX = self.horizontalMovementTowardsPlayer(time).limitBetween(-1, 1)
			const movementY = self.verticalMovementTowardsPlayer(time).limitBetween(-1, 1)
			
			if(movementX < 0) {
				self.goLeft(-movementX)
			} else if(movementX > 0) {
				self.goRight(movementX)
			}

			if(movementY < 0) {
				self.goDown(-movementY)
			} else if(movementY > 0) {
				self.goUp(movementY)
			}
			
		}
	}
	
	method isInPlayerPosition() {
		return player.position().x() == self.position().x().truncate(0)
					and player.position().y() == self.position().y().truncate(0)
	}
		
	method movementTowardsPlayer(time, relativeDistance){
		const sign = relativeDistance / relativeDistance.abs().max(1)
		return self.movementByTime(time) * sign
	}
	
	method horizontalMovementTowardsPlayer(time) {
		return self.movementTowardsPlayer(time, self.playerPosition().x() - self.position().x().truncate(0))
	}
	
	method verticalMovementTowardsPlayer(time) {
		return self.movementTowardsPlayer(time, self.playerPosition().y() - self.position().y().truncate(0))
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

class Zombie inherits WalkToPlayerEnemy(velocity = 1, direction = new StateDirectionSpriteModifier()) {}

class Fly inherits WalkToPlayerEnemy(velocity = 2) {}

class Slime inherits DelayedWalkToPlayerEnemy(velocity = 15, movementCooldown = 400, movementCooldownReload = 400) {
	const lastPlayerPosition = new MutablePosition(x = player.position().x(), y = player.position().y())
	
	override method update(time){
		super(time)
		movementController.onTimePassed(time)
	}
	
	override method playerPosition() = lastPlayerPosition
	
	override method onStartWalking() {
		lastPlayerPosition.inPosition(player.position().x(), player.position().y())
	}
	
}

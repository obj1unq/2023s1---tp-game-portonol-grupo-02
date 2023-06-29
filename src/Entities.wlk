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
import LifeUI.PlayerLifeUI
import SoundEffect.*

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
	var lastMovementController = null

	var property direction = new NullDirectionSpriteModifier()

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

	override method onAttach() {
		super()
		movementController.init()
	}

	override method onRemove() {
		super()
		movementController.remove()
	}

	method cancelMovement() {
		lastMovementController = movementController
		self.changeMovementController(staticMovementManager)
	}
	
	method recoverMovement() {
		self.changeMovementController(lastMovementController)
		lastMovementController = staticMovementManager
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

	method maxHp() = maxHp

	method hp() = hp

	method increaseDamage(amount) {
		damage += amount
	}
	
	method decreaseDamage(amount) {
		damage = (damage - amount).max(0)
	}

	method cooldown() = cooldown

	method takeDmg(dmg) {
		hp -= dmg
		self.onDamageTaken(hp)
		self.playDamageSound()
		if (self.isDead()) {
			self.die()
		}
	}
	
	method onDamageTaken(newLife) {}
	
	method addDamage(quantity) {
		damage += quantity
	}
	
	method heal(quantity) {
		hp = maxHp.min(hp + quantity)
	}

	method isDead() = hp <= 0
	
	method attack() {}
	
	method die()
	
	method dealDamage(receiver)

	method hitSound()

	method playDamageSound() {
		self.hitSound().play()
	}

}


class EnemyDamageEntity inherits DamageEntity {
	var property removeBehaviour = poolRemoveBehaviour
	const damageManager = new DamageManager(entity = self)
	var deathCallback = {}

	method resetState() {
		hp = maxHp
	}
		
	override method dealDamage(receiver) {
		damageManager.dealDamage(receiver)
	}

	override method onAttach() {
		super()
		removeBehaviour.onAdd(self)
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
	
	override method die() {
		self.onRemove()
	}
	
	override method onRemove(){
		super()
		deathCallback.apply()
		removeBehaviour.onRemove(self)
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
	override method dealDamage(receiver) {}
	override method hitSound() = null
}

class PlayerDamageEntity inherits DamageEntity(direction = new StateDirectionSpriteModifier()) {
	const weaponManager = new WeaponManager(weapons = [
		new Knife(),
		new Slingshot()
	])
	const lifeBarUI = new PlayerLifeUI(startingPosition = 0)
	const damageSfx
	const deathSfx

	override method state() {
		return super() + weaponManager.weaponName() + weaponManager.attackState()
	}
	
	override method dealDamage(receiver) {
		receiver.takeDmg(self.damage())
	}
	
	override method onAttach() {
		super()
		lifeBarUI.render()
		weaponManager.onAttach(self)
	}
	
	override method onRemove() {
		super() 
		lifeBarUI.unrender()
		weaponManager.onRemove(self)
	}
	
	override method onDamageTaken(newHP) {
		lifeBarUI.onDamageTaken(self)
	}
	
	method changeWeapon() {
		weaponManager.changeWeapon(self)
	}
	
	override method heal(quantity) {
		super(quantity)
		lifeBarUI.onHeal(self)
	}
	
	override method update(time){
		super(time)
		weaponManager.onTimePassed(time)
	}
	
	override method attack() {
		weaponManager.attack(self)
	}
	
	method addWeapon(weapon) {
		weaponManager.addWeapon(weapon)
	}
	
	override method die() {
		deathSfx.play()
		self.onRemove()
		global.deathScreen()
	}
	
	override method hitSound() = damageSfx
	
}

class ChargeToPlayerEnemy inherits EnemyDamageEntity {
	const player
	const velocityY = 2
	const velocityX = 4
	const chargeToPlayerBehaviour = new ChargeToPlayerMovement(entity = self)
	
	override method update(time){
		super(time)
		chargeToPlayerBehaviour.advance(time)
	}
	
	method verticalMovementByTime(time) = self.movementByTime(time, velocityY)
	method horizontalMovementByTime(time) = self.movementByTime(time, velocityX)
	
	method movementByTime(time, axisVelocity) {
		return (time * axisVelocity) / 1000
	}
	
	override method hitSound() = chargeHitEffect
	
}

class PingPongEnemyEntity inherits EnemyDamageEntity {
	var property velocity = 1
	const movementDirection = new MovementDirectionManager()
	
	override method update(time){
		super(time)
		self.movePingPong(time)
	}
	
	method movePingPong(time) {
		movementDirection.move(self, self.movementByTime(time))
	}
	
	method movementByTime(time) {
		return (time * velocity) / 1000
	}
	
	override method hitSound() = pingPongHitEffect
	
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

// Por limitaciones de usar celdas, la velocidad arruina el movimiento diagonal
class PingPongEnemy inherits PingPongEnemyEntity(velocity = 2) {}

class Zombie inherits WalkToPlayerEnemy(velocity = 1, direction = new StateDirectionSpriteModifier()) {
	override method hitSound() = zombieHitEffect
}

class Fly inherits WalkToPlayerEnemy(velocity = 2) {
	override method hitSound() = flyHitEffect
}

class Slime inherits DelayedWalkToPlayerEnemy(velocity = 15, movementCooldown = 400, movementCooldownReload = 400) {
	const lastPlayerPosition = new MutablePosition(x = player.position().x(), y = player.position().y())
	
	override method resetState() {
		lastPlayerPosition.inPosition(player.position().x(), player.position().y())
	}
	
	override method hitSound() = slimeHitEffect
	
	override method update(time){
		super(time)
		movementController.onTimePassed(time)
	}
	
	override method playerPosition() = lastPlayerPosition
	
	override method onStartWalking() {
		lastPlayerPosition.inPosition(player.position().x(), player.position().y())
	}
	
}
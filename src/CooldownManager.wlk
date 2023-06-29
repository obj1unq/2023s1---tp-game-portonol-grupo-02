import Global.global
import Sprite.Image
import SoundEffect.healEffect

class CooldownManager {

	var property totalCooldownTime
	var property relativeCooldownTime = totalCooldownTime // in MS

	method onTimePassed(time) {
		relativeCooldownTime -= time
		self.checkIfCooldownFinished()
	}

	method resetCooldown() {
		relativeCooldownTime = totalCooldownTime
	}

	method onCooldownFinish()

	method checkIfCooldownFinished() {
		if (self.cooldownFinished()) {
			self.onCooldownFinish()
		}
	}

	method cooldownFinished() {
		return relativeCooldownTime <= 0
	}

}

class PlayerHealCooldown inherits CooldownManager {
	const healQuantity
	
	override method onCooldownFinish() {
		global.player().heal(healQuantity)
		healEffect.play()
		self.resetCooldown()
	}
}

class FlySpawnerCooldown inherits CooldownManager(totalCooldownTime = 3000) {
	const entityFlySpawner
	
	override method onCooldownFinish() {
		self.resetCooldown()
		entityFlySpawner.spawnFly()
	}
}

class BinaryCooldownManager inherits CooldownManager {
	
	method toggleAndResetCooldown() {
		self.toggleCooldown()
		self.resetCooldown()
	}
	
	override method onCooldownFinish() {
		self.toggleCooldown()
		self.resetCooldown()
	}
	
	method opositeCooldown()
	
	method toggleCooldown()
	
}

class MovementCooldown inherits BinaryCooldownManager {

	const movementManager

	override method toggleCooldown() {
		movementManager.movementCooldown(self.opositeCooldown())
	}

	method canMove()
	
}

class NotOnMovementCooldown inherits MovementCooldown {

	override method opositeCooldown() {
		return movementManager.onMovementCooldown()
	}
	
	override method toggleCooldown() {
		movementManager.movableEntity().onStartWalking()
		super()
	}

	override method canMove() = true

}

class IndeterminateNotOnMovementCooldown inherits NotOnMovementCooldown {
	override method onTimePassed(time){}
}

class OnMovementCooldown inherits MovementCooldown {

	override method opositeCooldown() {
		return movementManager.notOnMovementCooldown()
	}

	override method canMove() = false

}

class DamageCooldown inherits BinaryCooldownManager {

	const damageManager

	method dealDamage(receiver)

	override method toggleCooldown() {
		damageManager.cooldownManager(self.opositeCooldown())
	}

}

class OnDamageCooldown inherits DamageCooldown {

	override method dealDamage(receiver) {
	}

	override method onCooldownFinish() {
		self.toggleAndResetCooldown()
	}

	override method opositeCooldown() {
		return damageManager.notOnCooldown()
	}

}

class NotOnDamageCooldown inherits DamageCooldown {

	override method dealDamage(receiver) {
		receiver.takeDmg(damageManager.entity().damage())
		self.toggleCooldown()
	}

	override method opositeCooldown() {
		return damageManager.onCooldown()
	}

	override method onTimePassed(time) {
	}

	override method onCooldownFinish() {
	}

}

class AttackCooldownManager inherits BinaryCooldownManager {
	const weapon

	method attack(dealer)

	override method toggleCooldown() {
		weapon.cooldownManager(self.opositeCooldown())
	}

}

class AttackableCooldownManager inherits AttackCooldownManager {

	override method attack(dealer) {
		weapon.culminateAttack(dealer)
		weapon.makeSound()
		self.toggleCooldown()
	}
	
	override method onTimePassed(time) {}

	override method opositeCooldown() {
		return weapon.rechargingAttackCM()
	}

}

class MovementAttackableCooldownManager inherits AttackableCooldownManager {
	const attackAnimation
	
	override method attack(dealer) {
		super(dealer)
		dealer.cancelMovement()
		self.opositeCooldown().dealerEntity(dealer)
		self.makeAnimation(dealer)
	}

	method makeAnimation(dealer) {
		const x = dealer.position().x() - 1
		const y = dealer.position().y() - 1
		attackAnimation.render(x, y)
	}

	method attackState() = ""

}

class MovementRechargingAttackCooldownManager inherits RechargingAttackCooldownManager {
	const attackAnimation
	
	var property dealerEntity = null
	
	override method onCooldownFinish() {
		super()
		attackAnimation.unrender()
		dealerEntity.recoverMovement()
	}
	
	method attackState() = "-attacking"
	
}

class RechargingAttackCooldownManager inherits AttackCooldownManager {
	
	override method attack(dealer) {}
	
	override method opositeCooldown() {
		return weapon.attackableCM()
	}
	
}

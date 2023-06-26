import Global.global

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

	override method attack(dealer) {
		super(dealer)
		dealer.cancelMovement()
		self.opositeCooldown().dealerEntity(dealer)
	}

}

class MovementRechargingAttackCooldownManager inherits RechargingAttackCooldownManager {
	
	var property dealerEntity = null
	
	override method onCooldownFinish() {
		super()
		dealerEntity.recoverMovement()
	}
	
}

class RechargingAttackCooldownManager inherits AttackCooldownManager {
	
	override method attack(dealer) {}
	
	override method opositeCooldown() {
		return weapon.attackableCM()
	}
	
}

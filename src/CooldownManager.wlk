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

class MovementCooldown inherits CooldownManager {

	const movementManager

	method toggleCooldown() {
		movementManager.movementCooldown(self.opositeCooldown())
	}

	method canMove()

	method opositeCooldown()
	
	override method onCooldownFinish() {
		self.toggleCooldown()
		self.resetCooldown()
	}
	
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

class DamageCooldown inherits CooldownManager {

	const damageManager

	method dealDamage(receiver)

	method opositeCooldown()

	method toggleCooldown() {
		damageManager.cooldownManager(self.opositeCooldown())
	}

	method toggleAndResetCooldown() {
		self.toggleCooldown()
		self.resetCooldown()
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


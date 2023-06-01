class DamageManager {

	const property entity
	const property notOnCooldown = new NotOnCooldown(damageManager = self)
	const property onCooldown = new OnCooldown(damageManager = self)
	var property cooldownManager = notOnCooldown

	method dealDmg(receiver) {
		if (cooldownManager.canDealDamage()) {
			receiver.takeDmg(entity.damage())
		}
	}

	method onTimePassed(time) {
		cooldownManager.onTimePassed(time)
	}

}

class CooldownManager {

	const damageManager
	var property cooldownTime = damageManager.entity().cooldown() // In MS

	method dealDamage(receiver)

	method onTimePassed(time) {
	}

	method resetCooldown() {
	}

	method checkIfCooldownFinished() {
	}

}

class OnCooldown inherits CooldownManager {

	override method dealDamage(receiver) {
	}

	override method onTimePassed(time) {
		cooldownTime -= time
		self.checkIfCooldownFinished()
	}

	override method resetCooldown() {
		cooldownTime = damageManager.entity().cooldown()
	}

	override method checkIfCooldownFinished() {
		if (cooldownTime <= 0) {
			damageManager.cooldown(damageManager.notOnCooldown())
			self.resetCooldown()
		}
	}

}

class NotOnCooldown inherits CooldownManager {

	override method dealDamage(receiver) {
		receiver.takeDmg(damageManager.entity().damage())
		self.toggleCooldown()
	}

	method toggleCooldown() {
		damageManager.cooldown(damageManager.onCooldown())
	}

	override method onTimePassed(time) {
	}

	override method resetCooldown() {
	}

	override method checkIfCooldownFinished() {
	}

}


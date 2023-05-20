class DamageManager {
	
	const entity
	var property cooldownState = notOnCooldown
	var property cooldownLeft = entity.cooldown()
	
	method dealDmg(receiver) {
		if (not self.onCooldown()){
			receiver.takeDmg(entity.damage())
			self.toogleCooldown()
		}
	}
	
	method toogleCooldown(){
		cooldownState = cooldownState.nextState()
	}
	
	method onCooldown() = cooldownState == onCooldown
	
	method notCooldownLeft() = cooldownLeft == 0

	method resetCooldown(){
		cooldownLeft = entity.cooldown()
		self.toogleCooldown()
	}
}

object onCooldown {
	const property nextState = notOnCooldown
}

object notOnCooldown {
	const property nextState = onCooldown
}
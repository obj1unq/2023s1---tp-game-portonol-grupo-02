import CooldownManager.*
import Global.*

class DamageManager {

	const property entity
	const property notOnCooldown = new NotOnDamageCooldown(damageManager = self, totalCooldownTime = entity.cooldown())
	const property onCooldown = new OnDamageCooldown(damageManager = self, totalCooldownTime = entity.cooldown())
	var property cooldownManager = notOnCooldown

	method dealDmg(receiver) {
		cooldownManager.dealDamage(receiver)
	}

	method onTimePassed(time) {
		cooldownManager.onTimePassed(time)
	}
	
//	method imageModifier() = cooldownManager.imageModifier()

}


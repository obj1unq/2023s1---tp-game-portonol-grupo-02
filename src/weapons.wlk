import Global.*
import Entities.GravityEntity
import structureGenerator.*
import gameConfig.*
import SoundEffect.stabKnifeEffect
import SoundEffect.slingshotEffect
import CooldownManager.AttackableCooldownManager
import CooldownManager.RechargingAttackCooldownManager
import CooldownManager.MovementAttackableCooldownManager
import CooldownManager.MovementRechargingAttackCooldownManager
import weaponUI.WeaponUI

class Weapon {
	method attack(dealer) {
		self.makeSound()	
	}
	
	method imageName()
	
	method makeSound()
}

object nullWeapon inherits Weapon {
	override method imageName() = "invisible"
	override method makeSound() {}
	override method attack(dealer) {}
}

class CooldownWeapon inherits Weapon {
	const property rechargeCooldown
	
	override method attack(dealer) {
		self.attackCooldown().attack(dealer)
	}
	
	method attackCooldown()
	
	method rechargingAttackCM()
	
	method attackableCM()
	
	method culminateAttack(dealer)
	
	method onTimePassed(time) {
		self.attackCooldown().onTimePassed(time)
	} 
	
	method cooldownManager(cooldownManager)
	
}

class MovementCooldownWeapon inherits CooldownWeapon {
	const property rechargingAttackCM = new MovementRechargingAttackCooldownManager(weapon = self, totalCooldownTime = rechargeCooldown)
	const property attackableCM = new MovementAttackableCooldownManager(weapon = self, totalCooldownTime = rechargeCooldown)
	var attackCooldown = attackableCM
	
	override method cooldownManager(cooldownManager) {
		attackCooldown = cooldownManager
	}
	
	override method rechargingAttackCM() = rechargingAttackCM
	
	override method attackableCM() = attackableCM
	
	override method attackCooldown() = attackCooldown
}

class OnlyCooldownWeapon inherits CooldownWeapon {
	const property rechargingAttackCM = new RechargingAttackCooldownManager(weapon = self, totalCooldownTime = rechargeCooldown)
	const property attackableCM = new AttackableCooldownManager(weapon = self, totalCooldownTime = rechargeCooldown)
	var attackCooldown = attackableCM
	
	override method cooldownManager(cooldownManager) {
		attackCooldown = cooldownManager
	}
	
	override method rechargingAttackCM() = rechargingAttackCM
	
	override method attackableCM() = attackableCM
	
	override method attackCooldown() = attackCooldown
}

class MeleeWeapon inherits MovementCooldownWeapon {
	override method culminateAttack(dealer) {
		const facingDirection = dealer.movementController().facingDirection()
		const colliders = facingDirection.collisionsFrom(dealer.position().x(), dealer.position().y())
		colliders.forEach {
			collider => 
				if(global.isEnemy(collider)) { dealer.damageManager().dealDmg(collider) }
		}
	}
	
}

class Knife inherits MeleeWeapon(rechargeCooldown = 200) {
	override method makeSound() {
		stabKnifeEffect.play()
	}
	override method imageName() = "knife-image"
}

class DistanceWeapon inherits OnlyCooldownWeapon {
	const projectileFactory

	override method culminateAttack(dealer) {
		const startingPosition = dealer.direction().direction().getFromPosition(dealer.position())
		const projectile = projectileFactory.createProjectileFrom(dealer, dealer.direction().direction())
		projectile.initialPositions(startingPosition.x(), startingPosition.y())
		projectile.onAttach()
	}
	
	override method makeSound() {
		slingshotEffect.play()
	}
}

class Slingshot inherits DistanceWeapon(projectileFactory = rockProjectileFactory, rechargeCooldown = 3000) {
	override method imageName() = "slingshot-image"
}

class Projectile inherits GravityEntity {
	var property to = bottom
	const fromEntity
	const velocity
	
	override method update(time){
		if(not gameConfig.isInMapLimits(self.position().x(), self.position().y())){
			self.onRemove()
		} else {
			self.checkForCollision()
			to.advance(velocity, self.position())
		}
	}
	
	method canDamage(entity)
	
	method checkForCollision() {
		self.colliders().forEach {
			collider => self.onCollision(collider)
		}
	}
	
	override method onCollision(collider) {
		super(collider)
		if(self.canDamage(collider) and isRendered) {			
			self.onRemove()
			collider.takeDmg(fromEntity.damage())
		}
	}
}

class EnemyProjectile inherits Projectile {
	override method canDamage(entity) {
		return global.isPlayer(entity)
	}
}

class PlayerProjectile inherits Projectile {
	override method canDamage(entity) {
		return global.isEnemy(entity)
	}
}

class RockProjectile inherits PlayerProjectile(baseImageName = "rock-projectile", velocity = 1) {}

class ProjectileFactory {
	method createProjectileFrom(dealer, direction)
}

object rockProjectileFactory inherits ProjectileFactory {
	override method createProjectileFrom(dealer, direction) {
		return new RockProjectile(fromEntity = dealer, gravity = global.gravity(), to = direction)
	}
}

class WeaponManager {
	var actualWeapon = 0
	const weaponUI = new WeaponUI()
	const weapons = []
	
	method changeWeapon() {
		if(weapons.size() != 0) {
			actualWeapon++
			self.changeNextWeapon()
		}
	}
	
	method onTimePassed(time) {
		weapons.forEach {
			weapon => weapon.onTimePassed(time)
		}
	}
	
	method changeNextWeapon() {
		if(actualWeapon >= weapons.size()) {
			actualWeapon = 0
		}
		weaponUI.onWeaponChanged(weapons.get(actualWeapon))
	}
	
	method onAttach() {
		weaponUI.onAttach()
	}
	
	method onRemove() {
		weaponUI.onRemove()
	}
	
	method attack(dealer) {
		weapons.get(actualWeapon).attack(dealer)
	}
	
	method addWeapon(weapon) {
		weapons.add(weapon)
	}
	
	method removeWeapon(weapon) {
		weapons.remove(weapon)
	}
	
}
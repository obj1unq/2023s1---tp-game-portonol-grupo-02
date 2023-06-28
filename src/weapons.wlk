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
import wollok.game.game
import Position.dummiePosition
import SoundEffect.clangEffect

class Weapon {
	
	const damage
	
	method attack(dealer) {
		self.makeSound()	
	}
	
	method equip(dealer) {
		dealer.increaseDamage(damage)
	}
	
	method unequip(dealer) {
		dealer.decreaseDamage(damage)
	}
	
	method imageName()
	
	method makeSound()
}

object nullWeapon inherits Weapon(damage = 0) {
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
				if(global.isEnemy(collider)) { dealer.dealDamage(collider) }
		}
	}
}

class MeeleAreaWeapon inherits MovementCooldownWeapon {
	override method culminateAttack(dealer) {
		const center = dealer.position()
		(center.x() - 1 .. center.x() + 1).forEach {
			x =>
				(center.y() + 1 .. center.y() - 1).forEach {
					y => self.attackIn(x, y, dealer)
				}
		}
	}
	
	method attackIn(x, y, dealer) {
		const colliders = game.getObjectsIn(dummiePosition.withPosition(x, y))
		colliders.forEach {
			collider => 
				if(global.isEnemy(collider)) { dealer.dealDamage(collider) }
		}
	}
	
}

class DragonSlayer inherits MeeleAreaWeapon(rechargeCooldown = 1000, damage = 100) {
	override method makeSound() {
		clangEffect.play()
	}
	override method imageName() = "dragonslayer-weapon"
} 

class Knife inherits MeleeWeapon(rechargeCooldown = 200, damage = 30) {
	override method makeSound() {
		stabKnifeEffect.play()
	}
	override method imageName() = "knife-image"
}

class DistanceWeapon inherits OnlyCooldownWeapon {
	const projectileFactory

	override method culminateAttack(dealer) {
		const xPosition = dealer.direction().direction().getXFromPosition(dealer.position())
		const yPosition = dealer.direction().direction().getYFromPosition(dealer.position())
		const projectile = projectileFactory.createProjectileFrom(dealer, dealer.direction().direction())
		projectile.initialPositions(xPosition, yPosition)
		projectile.onAttach()
	}
	
	override method makeSound() {
		slingshotEffect.play()
	}
}

class Slingshot inherits DistanceWeapon(projectileFactory = rockProjectileFactory, rechargeCooldown = 3000, damage = 30) {
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
	
	method changeWeapon(dealer) {
		if(weapons.size() != 0) {
			weapons.get(actualWeapon).unequip(dealer)
			actualWeapon++
			self.changeNextWeapon(dealer)
		}
	}
	
	method onTimePassed(time) {
		weapons.forEach {
			weapon => weapon.onTimePassed(time)
		}
	}
	
	method changeNextWeapon(dealer) {
		if(actualWeapon >= weapons.size()) {
			actualWeapon = 0
		}
		weapons.get(actualWeapon).equip(dealer)
		weaponUI.onWeaponChanged(weapons.get(actualWeapon))
	}
	
	// Must be initialized with a one or more weapons
	method onAttach() {
		weaponUI.onAttach()
		weaponUI.onWeaponChanged(weapons.get(actualWeapon))
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
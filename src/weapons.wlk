import Global.*
import Entities.GravityEntity
import structureGenerator.*
import gameConfig.*
import SoundEffect.stabKnifeEffect
import SoundEffect.slingshotEffect

class Weapon {
	method attack(dealer) {
		self.makeSound()	
	}
	
	method makeSound()
}

object nullWeapon inherits Weapon {
	override method makeSound() {}
	override method attack(dealer) {}
}

class MeleeWeapon inherits Weapon {
	override method attack(dealer) {
		super(dealer)
		const facingDirection = dealer.movementController().facingDirection()
		const colliders = facingDirection.collisionsFrom(dealer.position().x(), dealer.position().y())
		colliders.forEach {
			collider => 
				if(global.isEnemy(collider)) { dealer.damageManager().dealDmg(collider) }
		}
	}
	
	override method makeSound() {
		stabKnifeEffect.play()
	}
	
}

class DistanceWeapon inherits Weapon {
	const projectileFactory

	override method attack(dealer) {
		super(dealer)
		const startingPosition = dealer.direction().direction().getFromPosition(dealer.position())
		const projectile = projectileFactory.createProjectileFrom(dealer, dealer.direction().direction())
		projectile.initialPositions(startingPosition.x(), startingPosition.y())
		projectile.onAttach()
	}
	
	override method makeSound() {
		slingshotEffect.play()
	}
}

class Slingshot inherits DistanceWeapon(projectileFactory = rockProjectileFactory) {}

class Projectile inherits GravityEntity {
	var property to = bottom
	const fromEntity
	const velocity
	
	override method onRemove() {
		super()
		console.println("bala eliminada")
	}
	
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
	const weapons = []
	
	method changeWeapon() {
		if(weapons.size() != 0) {
			actualWeapon++
			self.changeNextWeapon()
		}
	}
	
	method changeNextWeapon() {
		if(actualWeapon >= weapons.size()) {
			actualWeapon = 0
		}
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
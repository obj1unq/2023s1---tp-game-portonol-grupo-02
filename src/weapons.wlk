import Global.*
import Entities.GravityEntity
import structureGenerator.*
import gameConfig.*

class Weapon {
	method attack(dealer)	
}

object nullWeapon inherits Weapon {
	override method attack(dealer) {}
}

class MeleeWeapon inherits Weapon {
	override method attack(dealer) {
		const facingDirection = dealer.movementController().facingDirection()
		const colliders = facingDirection.collisionsFrom(dealer.position().x(), dealer.position().y())
		colliders.forEach {
			collider => 
				if(global.isEnemy(collider)) { dealer.damageManager().dealDmg(collider) }
		}
	}
}

class DistanceWeapon inherits Weapon {
	const projectileFactory

	override method attack(dealer) {
		const projectile = projectileFactory.createProjectileFrom(dealer, dealer.direction())
		projectile.onAttach()
	}
}

class Slingshot inherits DistanceWeapon(projectileFactory = rockProjectileFactory) {}

class Projectile inherits GravityEntity {
	var property to = bottom
	const fromEntity
	const velocity
	
	override method update(time){
		if(gameConfig.isInMapLimits(self.position().x(), self.position().y())){
			self.onRemove()
		} else {
			to.advance(self.position())
		}
	}
	
	method canDamage(entity)
	
	override method onCollision(collider) {
		super(collider)
		if(self.canDamage(collider)) {			
			fromEntity.dealDamage(collider)
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

class RockProjectile inherits PlayerProjectile(baseImageName = "rock-projectile", velocity = 5) {}

class ProjectileFactory {
	method createProjectileFrom(dealer, direction)
}

object rockProjectileFactory inherits ProjectileFactory {
	override method createProjectileFrom(dealer, direction) {
		const startingPosition = direction.getFromPosition(dealer.position())
		const rock = new RockProjectile(fromEntity = dealer, gravity = global.gravity(), to = direction)
		rock.initialPositions(startingPosition.x(), startingPosition.y())
	}
}
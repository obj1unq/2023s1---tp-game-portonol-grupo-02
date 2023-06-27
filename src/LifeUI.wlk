import Sprite.Image
import gameConfig.gameConfig

class BarPart inherits Image(baseImageName = "life-bar-", shouldCheckCollision = false) {
	const part
	var state = part + "-full"
		
	method empty() {
		state = part + "-empty"
	} 
	
	method full() {
		state = part + "-full"
	}
	
	override method state() = state
	
}

class LifeUI {
	const life = []
	const startingPosition
	
	method emptyBarPart(barPart) {
		barPart.empty()
	}
	
	method lifeProportion(damagedEntity) = damagedEntity.hp() / damagedEntity.maxHp()
	
	method render() {				
		(0 .. 3).forEach {
			i =>
				const lifeBarPart = life.get(i)
				lifeBarPart.render(startingPosition + i, gameConfig.height())
		}
	}
	
	method unrender() {
		life.forEach {
			lifePart => lifePart.unrender()
		}
	}
	
	method onZeroHP() {}
	
	method onDamageTaken(damagedEntity) {
		if(damagedEntity.hp() <= 0) {
			self.onZeroHP()
		} else {
			const index = ((life.size() - 1) * self.lifeProportion(damagedEntity)).roundUp()
			(index .. life.size() - 1).forEach {
				i => self.emptyBarPart(life.get(i))
			}
		}	
	}
	
}

class PlayerLifeUI inherits LifeUI(
		life = [
			new BarPart(part = "player-left-top"),
			new BarPart(part = "player-left-bottom"),
			new BarPart(part = "player-right-bottom"),
			new BarPart(part = "player-right-top")
		]
) {
	
	override method render() {				
		(0 .. 3).forEach {
			i =>
				const lifeBarPart = life.get(i)
				lifeBarPart.render(startingPosition, gameConfig.height())
		}
	}
	
}

class BossBarUI inherits LifeUI(
		life = [
			new BarPart(part = "start"),
			new BarPart(part = "middle"),
			new BarPart(part = "middle"),
			new BarPart(part = "end")
		]
	){
	const bossIcon = new Image(baseImageName = "boss_craneo_icon", shouldCheckCollision = false)
	
	override method render() {
		super()
		bossIcon.render(startingPosition - 1, gameConfig.height())
	}
	
	override method onZeroHP() {
		self.unrender()
	}
	
	override method unrender() {
		super()
		bossIcon.unrender()
	}
}

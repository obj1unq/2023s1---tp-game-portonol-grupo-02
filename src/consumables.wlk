import Entities.GravityEntity
import Global.*
import gameConfig.*
import transitionManager.Transition
import transitionManager.transitionManager
import wollok.game.*
import weapons.DragonSlayer
import CooldownManager.PlayerHealCooldown

class Consumable inherits GravityEntity(initialY = gameConfig.yMiddle() + 2, initialX = gameConfig.xMiddle()) {
	const forRoom
	
	method consumedBy(player) {
		forRoom.removeConsumable(self)
		self.playPickupAnimation()
	}
	
	method playPickupAnimation() {}
		
	override method onCollision(collider) {
		if(collider == global.player()) {
			self.consumedBy(collider)
			self.onRemove()
		}
	}
	
}

object nullishConsumable inherits Consumable(gravity = null, forRoom = null) {
	override method consumedBy(player){}
	override method onAttach() {}
	override method onRemove() {}
}

class DragonSlayerConsumable inherits Consumable(baseImageName = "dragonslayer-consumable") {
	override method consumedBy(player) {
		super(player)
		const weapon = new DragonSlayer()
		player.addWeapon(weapon)
	}
	
	override method playPickupAnimation() {
		const transition = 
			new Transition(
					frames = [
						"mate-pickup-anim-1",
						"mate-pickup-anim-2",
						"mate-pickup-anim-3",
						"mate-pickup-anim-4",
						"mate-pickup-anim-5",
						"mate-pickup-anim-6",
						"mate-pickup-anim-7",
						"mate-pickup-anim-8",
						"mate-pickup-anim-9",
						"mate-pickup-anim-10",
						"mate-pickup-anim-11",
						"mate-pickup-anim-12",
						"mate-pickup-anim-13",
						"mate-pickup-anim-14",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16"
					],
				duration = 2000,
				sfx = game.sound("item-pickup-sound.mp3"),
				delay = 800
			)
		transitionManager.play(transition)
		
	}
}

object dragonSlayerFactory {
	method getConsumable(forRoom) {
		return new DragonSlayerConsumable(forRoom = forRoom, gravity = global.gravity())
	}
}

class DamageModifierConsumable inherits Consumable {
	const damage
	
	override method consumedBy(player) {
		super(player)
		player.addDamage(damage)
	}
	
}

class LifeModifier inherits Consumable {
	const healing
	
	override method consumedBy(player) {
		super(player)
		player.heal(healing)
	}
	
	
}

class Locro inherits Consumable(baseImageName = "consumible-locro") {
	
	const healQuantity
	
	override method consumedBy(player) {
		super(player)
		const healUnit = new HealUnit(healQuantity = healQuantity, gravity = global.gravity())
		healUnit.onAttach()
	}
	
	override method playPickupAnimation() {
		const transition = 
			new Transition(
					frames = [
						"mate-pickup-anim-1",
						"mate-pickup-anim-2",
						"mate-pickup-anim-3",
						"mate-pickup-anim-4",
						"mate-pickup-anim-5",
						"mate-pickup-anim-6",
						"mate-pickup-anim-7",
						"mate-pickup-anim-8",
						"mate-pickup-anim-9",
						"mate-pickup-anim-10",
						"mate-pickup-anim-11",
						"mate-pickup-anim-12",
						"mate-pickup-anim-13",
						"mate-pickup-anim-14",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16"
					],
				duration = 2000,
				sfx = game.sound("item-pickup-sound.mp3"),
				delay = 800
			)
		transitionManager.play(transition)
		
	}
	
}

object locroFactory {
	method getConsumable(forRoom) {
		return new Locro(forRoom = forRoom, gravity = global.gravity(), healQuantity = 10)
	}
}

class HealUnit inherits GravityEntity {
	const healQuantity
	const healCooldown = new PlayerHealCooldown(totalCooldownTime = 15000, healQuantity = healQuantity)
	
	override method update(time) {
		healCooldown.onTimePassed(time)
	}
	
	override method onAttach() {
		self.gravity().suscribe(self)
	}
	
	override method onRemove() {
		self.gravity().unsuscribe(self)
	}
	
}

class CapitanDelEspacio inherits LifeModifier(healing = 100, baseImageName = "consumible-capitandelespacio") {
	
	override method playPickupAnimation() {
		const transition = 
			new Transition(
					frames = [
						"mate-pickup-anim-1",
						"mate-pickup-anim-2",
						"mate-pickup-anim-3",
						"mate-pickup-anim-4",
						"mate-pickup-anim-5",
						"mate-pickup-anim-6",
						"mate-pickup-anim-7",
						"mate-pickup-anim-8",
						"mate-pickup-anim-9",
						"mate-pickup-anim-10",
						"mate-pickup-anim-11",
						"mate-pickup-anim-12",
						"mate-pickup-anim-13",
						"mate-pickup-anim-14",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16"
					],
				duration = 2000,
				sfx = game.sound("item-pickup-sound.mp3"),
				delay = 800
			)
		transitionManager.play(transition)
		
	}
	
}

object capitanDelEspacioFactory {
	method getConsumable(forRoom) {
		return new CapitanDelEspacio(forRoom = forRoom, gravity = global.gravity())
	}
}

class Mate inherits DamageModifierConsumable(damage = 10, baseImageName = "consumible-mate"){
	
	override method playPickupAnimation() {
		const transition = 
			new Transition(
					frames = [
						"mate-pickup-anim-1",
						"mate-pickup-anim-2",
						"mate-pickup-anim-3",
						"mate-pickup-anim-4",
						"mate-pickup-anim-5",
						"mate-pickup-anim-6",
						"mate-pickup-anim-7",
						"mate-pickup-anim-8",
						"mate-pickup-anim-9",
						"mate-pickup-anim-10",
						"mate-pickup-anim-11",
						"mate-pickup-anim-12",
						"mate-pickup-anim-13",
						"mate-pickup-anim-14",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16"
					],
				duration = 2000,
				sfx = game.sound("item-pickup-sound.mp3"),
				delay = 800
			)
		transitionManager.play(transition)
		
	}
	
}

object mateFactory {
	method getConsumable(forRoom) {
		return new Mate(forRoom = forRoom, gravity = global.gravity())
	}
}

class Termidor inherits DamageModifierConsumable(damage = 40, baseImageName = "consumible-termidor"){
	
	override method playPickupAnimation() {
		const transition = 
			new Transition(
					frames = [
						"mate-pickup-anim-1",
						"mate-pickup-anim-2",
						"mate-pickup-anim-3",
						"mate-pickup-anim-4",
						"mate-pickup-anim-5",
						"mate-pickup-anim-6",
						"mate-pickup-anim-7",
						"mate-pickup-anim-8",
						"mate-pickup-anim-9",
						"mate-pickup-anim-10",
						"mate-pickup-anim-11",
						"mate-pickup-anim-12",
						"mate-pickup-anim-13",
						"mate-pickup-anim-14",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16",
						"mate-pickup-anim-15",
						"mate-pickup-anim-16"
					],
				duration = 2000,
				sfx = game.sound("item-pickup-sound.mp3"),
				delay = 800
			)
		transitionManager.play(transition)
		
	}
	
}

object termidorFactory {
	method getConsumable(forRoom) {
		return new Termidor(forRoom = forRoom, gravity = global.gravity())
	}
}

class CanioncitoDDL inherits LifeModifier(healing = 20, baseImageName = "consumible-cañoncito"){
	override method playPickupAnimation() {
		const transition = 
			new Transition(
					frames = [
						"canon-pickup-anim-1",
						"canon-pickup-anim-2",
						"canon-pickup-anim-3",
						"canon-pickup-anim-4",
						"canon-pickup-anim-5",
						"canon-pickup-anim-6",
						"canon-pickup-anim-7",
						"canon-pickup-anim-8",
						"canon-pickup-anim-9",
						"canon-pickup-anim-10",
						"canon-pickup-anim-11",
						"canon-pickup-anim-12",
						"canon-pickup-anim-13",
						"canon-pickup-anim-14",
						"canon-pickup-anim-15",
						"canon-pickup-anim-16",
						"canon-pickup-anim-15",
						"canon-pickup-anim-16",
						"canon-pickup-anim-15",
						"canon-pickup-anim-16",
						"canon-pickup-anim-15",
						"canon-pickup-anim-16"
					],
				duration = 2000,
				sfx = game.sound("item-pickup-sound.mp3"),
				delay = 800
			)
		transitionManager.play(transition)
	}
}

object canioncitoDDLFactory {
	method getConsumable(forRoom) {
		return new CanioncitoDDL(forRoom = forRoom, gravity = global.gravity())
	}
}

class consumableFactory {
	method getConsumable(forRoom)
}
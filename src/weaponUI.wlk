import Sprite.Image
import gameConfig.gameConfig

class WeaponUI {
	const border = new Image(baseImageName = "weapon-border")
	var weapon = new Image(baseImageName = "invisible")
	
	method onWeaponChanged(_weapon) {
		weapon.baseImageName(_weapon.weaponName())
	}
	
	method onAttach() {
		border.render(1, gameConfig.height())
		weapon.render(1, gameConfig.height())
	}
	
	method onRemove() {
		border.unrender()
		weapon.unrender()
	}
	
}

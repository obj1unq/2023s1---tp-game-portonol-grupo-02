import wollok.game.*
import Sprite.*
import Position.*
import Movement.staticMovementManager

object global {
	const property enemies = []
	var property gravity
	var player
	var playerMovementManager = staticMovementManager
	
	method pauseGame() {
		playerMovementManager = player.movementController()
		player.changeMovementController(staticMovementManager)
		gravity.pause()
	}
	
	method resumeGame() {
		player.changeMovementController(playerMovementManager)
		gravity.init()
	}
	
	method addEnemy(enemy){
		enemies.add(enemy)
	}
	
	method player(_player){
		player = _player
	}
	
	method removeEnemy(enemy) {
		enemies.remove(enemy)
	}
	
	method player() = player
	
	method deathScreen(){
		const deathModal = new Image(baseImageName = "deathscreen")
		deathModal.render(0,0)
		// TODO: Hacer que vuelva al main menu después del tiempo del sonido
	}
	
	method isEnemy(entity) = enemies.contains(entity)
	
	method isPlayer(entity) = entity == player
	
}
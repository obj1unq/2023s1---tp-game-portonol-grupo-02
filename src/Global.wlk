import wollok.game.*
import Sprite.*
import Position.*

object global {
	const enemies = []
	var property gravity
	var player
	
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
	}
	
	method isEnemy(entity) = enemies.contains(entity)
	
	method isPlayer(entity) = entity == player
	
}
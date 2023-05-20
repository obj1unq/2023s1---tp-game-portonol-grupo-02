import wollok.game.*
import Sprite.*
import Position.*

object global {
	const enemies = #{}
	var player
	
	method addEnemy(enemy){
		enemies.add(enemy)
	}
	
	method player(_player){
		player = _player
	}
	
	method deathScreen(){
		const deathModal = new Image(imageName = "deathscreen.png")
		deathModal.renderAt(new MutablePosition(x = 0, y = 0))
	}
	
	method isEnemy(entity) = enemies.any{enemy => enemy == entity}
	
	method isPlayer(entity) = entity == player
	
}
import wollok.game.*
import Sprite.*
import Position.*

object global {
	const enemies = #{}
	var property gravity
	var player
	
	method addEnemy(enemy){
		enemies.add(enemy)
	}
	
	method player(_player){
		player = _player
	}
	
	method player() = player
	
	method deathScreen(){
		const deathModal = new Image(baseImageName = "deathscreen")
		deathModal.render(0,0)
	}
	
	method isEnemy(entity) = enemies.any{enemy => enemy == entity}
	
	method isPlayer(entity) = entity == player
	
}
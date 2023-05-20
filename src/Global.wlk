import wollok.game.*
import Sprite.*
import Position.*
import Scene.*

object global {
	const enemies = #{}
	var property player
	var property gravity
	var property sceneManager = new SceneManager()
	
	method addEnemy(enemy){
		enemies.add(enemy)
	}
	
	method removeEnemy(enemy){
		enemies.remove(enemy)
	}
	
	method clearEnemies(){
		enemies.clear()
	}
	
	method deathScreen(){
		const deathModal = new Image(imageName = "deathscreen.png")
		deathModal.renderAt(new MutablePosition(x = 0, y = 0))
		game.schedule(4000,{sceneManager.backToMainMenu()})
	}
	
	method isEnemy(entity) = enemies.any{enemy => enemy == entity}
	
	method isPlayer(entity) = entity == player
	
}
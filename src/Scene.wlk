import wollok.game.*
import Entities.*
import Movement.*
import Sprite.*
import SoundEffect.*
import Blocks.*
import Position.*
import Input.*
import Global.global

class SceneManager {
	/* Lo implementé con queue, pero puede ser con lista para no perder las escenas */
	var levels = []
	var property mainMenu = mainMenuScene
	
	method enqueueLevel(scene){
		levels.add(scene)
	}
	
	method enqueueLevels(scenes){
		scenes.forEach{scene => self.enqueueLevel(scene)}
	}
	
	method goToScene(scene){
		game.clear()
		global.clearEnemies()
		scene.init()
	}
	
	method goToNextLevel(){
		const nextLevel = levels.head()
		levels = levels.remove(nextLevel)
		self.goToScene(nextLevel)
		
	}
	
	method backToMainMenu(){
		self.goToScene(mainMenu)
	}
	
	method init(){
		self.backToMainMenu()
	}
}

class Scene {
	method init()
}

object mainMenuScene inherits Scene {
	override method init(){
		keyboard.any().onPressDo{global.sceneManager().goToNextLevel()}
		const titleScreen = new Image(imageName = "titlescreen.png")
		titleScreen.renderAt(new MutablePosition(x = 0, y = 0))
		game.start()
		//titleScreenBGM.play()
	}
}

object level1Scene inherits Scene {
	override method init(){
		inputManager.init()
		var controlManager = new CharacterMovementController(movableEntity = global.player())
		controlManager.jumpManager(new DoubleJumpManager(jumpEffect = characterJumpEffect))
		global.player().setMovementController(controlManager)
		global.player().maxJumpHeight(4)
		global.player().imageMap([ [new Image(imageName = "row-1-column-1.png"), new Image(imageName = "row-2-column-1.png")], [new Image(imageName = "row-1-column-2.png"), new Image(imageName = "row-2-column-2.png")] ])
		global.player().initialPositions(3, 2)
		global.player().onAttach()
		var enemy = new Slime(gravity = global.gravity(), hp = 50, maxHp = 50, damage = 25, cooldown = 10, player = global.player())
		global.addEnemy(enemy)
		var collidableMovementManager = new EnemyMovementController(movableEntity = enemy)
		enemy.initialPositions(5, 10)
		enemy.changeMovementController(collidableMovementManager)
		enemy.movementController().jumpManager(new SimpleJumpManager(jumpEffect = slimeJumpEffect))
		enemy.imageMap([ 
			[new Image(imageName = "slime-row-1-column-1.png"), new Image(imageName = "slime-row-2-column-1.png")],
			[new Image(imageName = "slime-row-1-column-2.png"), new Image(imageName = "slime-row-2-column-2.png")]
		])
		enemy.velocityX(10)
		enemy.onAttach()
		enemy.maxJumpHeight(3)
		
		var enemy2 = new Slime(gravity = global.gravity(), hp = 50, maxHp = 50, damage = 25, cooldown = 10, player = global.player())
		global.addEnemy(enemy2)
		var collidableMovementManager2 = new EnemyMovementController(movableEntity = enemy2)
		enemy2.initialPositions(10, 10)
		enemy2.changeMovementController(collidableMovementManager2)
		enemy2.movementController().jumpManager(new SimpleJumpManager(jumpEffect = slimeJumpEffect))
		enemy2.imageMap([ 
			[new Image(imageName = "slime.png")]
		])
		enemy2.velocityX(10)
		enemy2.onAttach()
		enemy2.maxJumpHeight(3)
		
	//	var zombie = new Zombie(gravity = gravity, hp = 50, maxHp = 50, damage = 25, cooldown = 2000, player = player)
	//	global.addEnemy(zombie)
	//	var collidableMovementManagerForZombie = new EnemyMovementController(movableEntity = zombie)
	//	zombie.initialPositions(5, 10)
	//	zombie.changeMovementController(collidableMovementManagerForZombie)
	//	zombie.movementController().jumpManager(new SimpleJumpManager())
	//	zombie.imageMap([ 
	//		[new Image(imageName = "zombie-row-1-column-1.png"), new Image(imageName = "zombie-row-2-column-1.png")],
	//		[new Image(imageName = "zombie-row-1-column-2.png"), new Image(imageName = "zombie-row-2-column-2.png")]
	//	])
	//	zombie.velocityX(10)
	//	zombie.maxJumpHeight(3)
	//	zombie.gravityY(1)
	//	zombie.onAttach()

		var jumpBlock2 = new Block(imageName = "suelo.png")
		jumpBlock2.renderAt(game.at(6, 6))
		var jumpBlock5 = new Block(imageName = "suelo.png")
		jumpBlock5.renderAt(game.at(2, 2))
		(0 .. game.width()).forEach{ i =>
			var block2 = new Block(imageName = "suelo.png")
			block2.renderAt(game.at(i, 0))
		}
		global.gravity().init()
	}
}
import wollok.game.*
import structureGenerator.*

object inputManager {

	const dispatchers = []

	method suscribe(dispatcher) {
		dispatchers.add(dispatcher)
	}

	method unsuscribe(dispatcher) {
		dispatchers.remove(dispatcher)
	}

	method dispatchInput(input) {
		dispatchers.forEach{ dispatcher => dispatcher.onDispatchInput(input)}
	}

	method init() {
		keyboard.a().onPressDo({ self.dispatchInput(left)})
		keyboard.d().onPressDo({ self.dispatchInput(right)})
		keyboard.s().onPressDo({ self.dispatchInput(bottom)})
		keyboard.w().onPressDo({ self.dispatchInput(top)})
		keyboard.c().onPressDo({ self.dispatchInput(c)})
		keyboard.up().onPressDo({ self.dispatchInput(north) })
		keyboard.down().onPressDo({ self.dispatchInput(south) })
		keyboard.left().onPressDo({ self.dispatchInput(west) })
		keyboard.right().onPressDo({ self.dispatchInput(east) })
	}

}

class Orientation {
	method onInput(movementController) {
		movementController.facingDirection(self.direction())
		movementController.movableEntity().direction().direction(self.direction())
		movementController.movableEntity().attack()
	}
		
	method direction()
	
}

object c {
	method onInput(movementController) {
		movementController.movableEntity().changeWeapon()
	}
}

object north inherits Orientation {
	
	override method direction() = top
	
}

object south inherits Orientation {
	
	override method direction() = bottom
	
}

object east inherits Orientation {

	override method direction() = right
	
}

object west inherits Orientation {

	override method direction() = left
	
}

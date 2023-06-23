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
		keyboard.space().onPressDo({ self.dispatchInput(space)})
//		keyboard.c().onPressDo({ self.dispatchInput("c")})
		keyboard.up().onPressDo({ self.dispatchInput(north) })
		keyboard.down().onPressDo({ self.dispatchInput(south) })
		keyboard.left().onPressDo({ self.dispatchInput(west) })
		keyboard.right().onPressDo({ self.dispatchInput(east) })
	}

}

class Orientation {
	method onInput(movementController) {
		movementController.facingDirection(self)
	}
}

object space {
	method onInput(movementController) {
		movementController.movableEntity().attack()
	}
}

object north inherits Orientation {
	method collisionsFrom(x, y) {
		return top.collisionsFrom(x, y)
	}
}

object south inherits Orientation {
	method collisionsFrom(x, y) {
		return bottom.collisionsFrom(x, y)
	}
}

object east inherits Orientation {
	method collisionsFrom(x, y) {
		return right.collisionsFrom(x, y)
	}
}

object west inherits Orientation {
	method collisionsFrom(x, y) {
		return left.collisionsFrom(x, y)
	}
}

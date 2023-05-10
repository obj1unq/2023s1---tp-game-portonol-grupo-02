import wollok.game.*

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
		keyboard.left().onPressDo({ self.dispatchInput("left")})
		keyboard.right().onPressDo({ self.dispatchInput("right")})
		keyboard.down().onPressDo({ self.dispatchInput("down")})
		keyboard.up().onPressDo({ self.dispatchInput("up")})
		keyboard.space().onPressDo({ self.dispatchInput("space")})
		keyboard.c().onPressDo({ self.dispatchInput("c")})
	}

}


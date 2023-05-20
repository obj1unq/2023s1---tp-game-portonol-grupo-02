import wollok.game.*

object dummiePosition {
	var property x = 0
	var property y = 0

	method inPosition(_x, _y) {
		x = _x
		y = _y
		return self
	}
}

class MutablePosition {

	var property x
	var property y

	method inPosition(_x, _y) {
		x = _x
		y = _y
		return self
	}

	method right(n) {
		x += n
	}

	method left(n) {
		x -= n
	}

	method up(n) {
		y += n
	}

	method down(n) {
		y -= n
	}

	method drawElement(element) {
		game.addVisualIn(element, self)
	} // TODO: Implement native

	/**
	 * Adds an object to the board for drawing it in self. It can be moved with arrow keys.
	 */
	method drawCharacter(element) {
		game.addVisualCharacterIn(element, self)
	} // TODO: Implement native

	/**
	 * Draw a dialog balloon with given message in given visual object position.
	 */
	method say(element, message) {
		game.say(element, message)
	} // TODO: Implement native

	/**
	 * Returns all objects in self.
	 */
	method allElements() = game.getObjectsIn(self) // TODO: Implement native

	/**
	 * Returns a new position with same coordinates.
	 */
	method clone() = new MutablePosition(x = x, y = y)

	/**
	 * Returns the distance between given position and self.
	 */
	method distance(position) {
		self.checkNotNull(position, "distance")
		const deltaX = x - position.x()
		const deltaY = y - position.y()
		return (deltaX.square() + deltaY.square()).squareRoot()
	}

	/**
	 * Removes all objects in self from the board for stop drawing it.
	 */
	method clear() {
		self.allElements().forEach{ it => game.removeVisual(it)}
	}

	/**
	 * Two positions are equals if they have same coordinates.
	 */
	override method ==(other) = x == other.x() && y == other.y()

	/**
	 * String representation of a position
	 */
	override method toString() = x.toString() + "@" + y.toString()

}

object arriba {

}

object abajo {

}

object izquierda {

}

object derecha {

}


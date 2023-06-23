import wollok.game.*

object gameConfig {
	
	var property player = null
	var property gravity = null
	const property doorXOffset = 1
	const property doorYOffset = 1
	const property xMiddle = (game.width() / 2).truncate(0)
	const property yMiddle = (game.height() / 2).truncate(0)
	const property width = game.width() - 1
	const property height = game.height() - 1

	method canMoveVertically(y) {
		return (y <= height - doorYOffset) and (y >= doorYOffset)
	}
	
	method canMoveHorizontally(x) {
		return (x <= width - doorXOffset) and (x >= doorXOffset)
	}
	
	method isInMapLimits(x, y) {
		return self.canMoveVertically(y) and self.canMoveHorizontally(x)
	}

}

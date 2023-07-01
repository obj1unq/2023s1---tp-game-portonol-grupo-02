import wollok.game.*
import Position.MutablePosition

class Image {
	var isRendered = false
	var property baseImageName = "invisible"
	var property position = new MutablePosition(x = 0, y = 0)
	const shouldCheckCollision = true

	method state() = ""

	method image() = baseImageName + self.state() + ".png"

	method isRendered() = isRendered

	method render(initialX, initialY) {
		isRendered = true
		position.inPosition(initialX, initialY)
		game.addVisual(self)
		self.initCollision()
	}
	
	method render() {
		isRendered = true
		game.addVisual(self)
	}
	
	method inPosition(x, y) {
		position.inPosition(x, y)
	}
	
	// Evitar uso. Empeora el performance
	method colliders() = game.colliders(self)
	
	method initCollision() {
		if(shouldCheckCollision) {
			game.onCollideDo(self, { collider => self.onCollision(collider) })			
		}
	}
	
	method onCollision(collider){}
	
	method move(x, y) {
		position.right(x)
		position.up(y)
	}

	method unrender() {
		isRendered = false
		game.removeVisual(self)
	}

	method isCollidable() = false

}

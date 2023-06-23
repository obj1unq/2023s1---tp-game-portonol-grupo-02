import wollok.game.*
import Position.MutablePosition

class Image {

	var property baseImageName = "invisible"
	var property position = new MutablePosition(x = 0, y = 0)
	const shouldCheckCollision = true

	method state() = ""

	method image() = baseImageName + self.state() + ".png"

	method render(initialX, initialY) {
		position.inPosition(initialX, initialY)
		game.addVisual(self)
		self.initCollision()
	}
	
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
		game.removeVisual(self)
	}

	method isCollidable() = false

}

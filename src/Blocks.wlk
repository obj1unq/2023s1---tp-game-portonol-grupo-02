import Sprite.Image

class Block inherits Image {

	override method isCollidable() = true

}

class CollisionableBlock inherits Block {

	var direction

	override method isCollidable() = true

	override method position() = position

	method from(_direction) = _direction == direction

}


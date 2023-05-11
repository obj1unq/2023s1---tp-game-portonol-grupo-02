import Sprite.Image

class Block inherits Image {

	override method hadCollidedWithBlock() = true

	override method isCollidable() = true

	method isEnemy() = false

	method isPlayer() = false
}

class CollisionableBlock inherits Block {

	var direction

	override method isCollidable() = true

	method position() = position

	method from(_direction) = _direction == direction

}


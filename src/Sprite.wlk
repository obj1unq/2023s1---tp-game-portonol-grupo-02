import wollok.game.*
import Position.MutablePosition

class ImageStrategy {
	method getImage(image)
}

object getFromParent inherits ImageStrategy {
	override method getImage(image) {
		return image.entity().imageName()
	}
}

object getFromSelf inherits ImageStrategy {
	override method getImage(image) {
		return image.imageName()
	}
}

class Image {

	var property imageName = "invisible.png"
	var entity = null
	var property position = new MutablePosition(x = 0, y = 0)
	var withCollisions = false
	var property imageStrategy = getFromSelf

	method withCollisions(state){
		withCollisions = state
	}

	method image() = imageStrategy.getImage(self)

	method entity(_entity) {
		entity = _entity
	}
	
	method isPartOfEntity(_entity){
		return entity != null and entity == _entity
	}
	
	method entity() = entity

	method hasEntity() {
		return entity != null
	} 

	method renderAt(_position) {
		position = _position
		game.addVisual(self)
		self.initCollisionChecker()
	}
	
	method initCollisionChecker() {
		if(self.hasEntity() and withCollisions) {
			game.onCollideDo(self, { collider => self.dispatchCollider(collider) })
		}
	}

	method dispatchCollider(collider) {
		if(collider.hasEntity() and not self.isPartOfEntity(collider.entity())) {
			self.entity().onCollision(collider)
		}
	}

	method move(x, y) {
		position.right(x)
		position.up(y)
	}

	method unrender() {
		game.removeVisual(self)
	}

	method hadCollidedWithBlock() = false

	method isCollidable() = false

}

class Renderable {
	var imageName = "pepita.png"
	var withCollisions = true
	var imageMap = []
	var imageHeight = 50
	var imageLength = 50
	var isRendered = false
	
	method isRendered() = isRendered

	method setImageMap() {
		const sprayHeight = (imageHeight / 50) - 1
		const sprayLength = (imageLength / 50) - 1
		(0..sprayLength).forEach{ i =>
			const column = []
			(0..sprayHeight).forEach{ j =>
				const img = new Image() 
				column.add(img)
				img.entity(self)
				img.withCollisions(withCollisions)
			 	if (j == sprayHeight and i == 0){	 		
				 	img.imageStrategy(getFromParent)
				 	img.imageName(imageName)
			 	}
			}
			imageMap.add(column)	
		}
	}

	method say(message) {
		const firstImage = imageMap.get(0).get(0)
		game.say(firstImage, message)
	}

	method onCollision(colliders){}

	method render(initialX, initialY) {
		isRendered = true
		self.forEach({ image, _x, _y =>			
			image.renderAt(new MutablePosition(x = initialX + _x, y = initialY - _y))
		})
	}

	method move(_x, _y) {
		self.forEach({ image, x1, x2 =>
			image.move(_x, _y)
		})
	}
	
	method imageName() = imageName

	method unrender() {
		isRendered = false
		self.forEach({ image, x, y => image.unrender()})
	}
	
	method isPartOfThisEntity(img) {
		return imageMap.any{
						column => column.any {
							image => image == img
						}
					}
	}

	method forEach(callback) {
		const width = (0..imageMap.size() - 1)
		const height = (0..imageMap.get(0).size() - 1)
		width.forEach({ x => height.forEach({ y => callback.apply(imageMap.get(x).get(y), x, y)})})
	}
	
	method any(callback) {
		const length = if(imageMap.size() < 1) (0 .. imageMap.size()) else (0 .. imageMap.size() - 1)
		const height = if(imageMap.get(0).size() < 1) (0 .. imageMap.get(0).size()) else (0 .. imageMap.get(0).size() - 1)
		return length.any(
			{ x => height.any(
				{ y => 
					const img = imageMap.get(x).get(y)
					callback.apply(img, img.position().x(), img.position().y()) 
				}
			)}
		)
	}
	
	method xMiddle() {
		return self.originPosition().x().truncate(0) + (self.length() / 2)		
	} 
	
	method yMiddle() {
		return self.originPosition().y().truncate(0) - (self.height() / 2)		
	}
	
	method middleLength() = self.length() / 2
	method middleHeight() = self.height() / 2
	
	method isInPosition(position) {
		return position.distanceWithX(self.xMiddle()) <= self.middleLength()
			and position.distanceWithY(self.yMiddle()) <= self.middleHeight()
	}
	
	method originPosition(){
		return imageMap.get(0).get(0).position()
	}
	
	method length() = imageMap.size()
	
	method height() = imageMap.get(0).size()

}


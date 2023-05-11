import wollok.game.*
import Position.*

class Image {

	var imageName
	var entity = null
	var property position = new MutablePosition(x = 0, y = 0)

	method image() = imageName

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

	var imageMap = [[new Image(imageName = "default.png")]]

	method imageMap(_imageMap) {
		imageMap = _imageMap
		imageMap.forEach {
			column => 
				column.forEach { img => img.entity(self)}
		}
	}

	method say(message) {
		const firstImage = imageMap.get(0).get(0)
		game.say(firstImage, message)
	}

	method render(initialX, initialY) {
		self.forEach({ image, _x, _y =>			
			image.renderAt(new MutablePosition(x = initialX + _x, y = initialY - _y))
		})
	}

	method move(_x, _y) {
		self.forEach({ image, x1, x2 =>
			image.move(_x, _y)
		})
	}
	

	method unrender() {
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
		const length = if(imageMap.size() < 1) (0 .. imageMap.size()) else (0 .. imageMap.size() - 1)
		const height = if(imageMap.get(0).size() < 1) (0 .. imageMap.get(0).size()) else (0 .. imageMap.get(0).size() - 1)
		length.forEach({ x => height.forEach({ y => callback.apply(imageMap.get(x).get(y), x, y)})})
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
	
	method filter(callback) {
		
		const elements = []
		const length = if(imageMap.size() < 1) (0 .. imageMap.size()) else (0 .. imageMap.size() - 1)
		const height = if(imageMap.get(0).size() < 1) (0 .. imageMap.get(0).size()) else (0 .. imageMap.get(0).size() - 1)
		length.forEach({
			x => height.forEach(
				{ y => 
					if(callback.apply(imageMap.get(x).get(y), x, y)){
						elements.add(imageMap.get(x).get(y))
					}
				}
			)
		})
		return elements
	}

	method originPosition(){
		return imageMap.get(0).get(0).position()
	}
	
	method length() = imageMap.size()
	
	method height() = imageMap.get(0).size()
	
	method isEnemy() = false
	
	method isPlayer() = false

}


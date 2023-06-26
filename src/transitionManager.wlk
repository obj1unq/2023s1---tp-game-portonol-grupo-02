import wollok.game.*
import Sprite.Image
import Global.global

object transitionManager {
	
	var currentTime = 0
	const minTick = 100
	var transition = null
	const transitionName = "transition"
	const currentImage = new Image()
	
	method currentTransition() = transition
	
	method play(_transition) {
		global.pauseGame()
		transition = _transition
		currentImage.baseImageName(transition.frame(0))
		currentImage.render(0, 0)
		game.onTick(100, transitionName, { self.makeTick() })
	}
	
	method makeTick() {
		currentTime += minTick
		if(transition.delay() >= 0) transition.decreaseDelay()
		if(currentTime >= transition.duration()) {
			self.finishAnimation()
		} else {
			self.displayCurrentImage()
		}
	}
	
	method displayCurrentImage() {
		currentImage.baseImageName(self.currentFrame())
	}
	
	method currentFrame() {
		const currentFrame = (currentTime / transition.timeBetweenFrames()).truncate(0)
		console.println(transition.frame(currentFrame))
		return transition.frame(currentFrame)
	}
	
	method finishAnimation() {
		game.removeTickEvent(transitionName)
		currentImage.unrender()
		transition = null
		global.resumeGame()
		currentTime = 0
	}
	
}

class Transition {
	const frames   = []
	const property duration = 0 // in MS
	const property sfx = null
	var property delay = 0
	
	method framesSize() = frames.size()
	
	method frame(n) = frames.get(n)
	
	method timeBetweenFrames() {
		return duration / self.framesSize() 
	}
	
	method decreaseDelay(){
		delay--
		if(sfx != null and delay <= 0){
			sfx.play()
		}
	}
}
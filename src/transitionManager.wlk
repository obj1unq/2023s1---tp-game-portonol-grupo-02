import wollok.game.*
import Sprite.Image
import Global.global

object transitionManager {
	
	var currentTime = 0
	const minTick = 100
	var transition = null
	const transitionName = "transition"
	const currentImage = new Image()
	var onFinishTransition = {}
	
	method currentTransition() = transition
	
	method play(_transition) {
		global.pauseGame()
		transition = _transition
		onFinishTransition = transition.onFinish()
		currentImage.baseImageName(transition.frame(0))
		currentImage.render(0, 0)
		game.onTick(100, transitionName, { self.makeTick() })
	}
	
	method makeTick() {
		currentTime += minTick
		if(transition.delay() >= 0){
			transition.decreaseDelay(minTick)
		}
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
		transition.stopSfx()
		game.removeTickEvent(transitionName)
		currentImage.unrender()
		global.resumeGame()
		currentTime = 0
		transition = null
		onFinishTransition.apply()
	}
	
}

class Transition {
	const frames   = []
	const property duration = 0 // in MS
	var property sfx = null
	var property delay = 0
	const property onFinish = {}
	
	method framesSize() = frames.size()
	
	method frame(n) = frames.get(n)
	
	method timeBetweenFrames() {
		return duration / self.framesSize() 
	}
	
	method stopSfx(){
		if (delay > 0){
			sfx.play()
		}
		sfx.stop()
	}
	
	method decreaseDelay(minTick){
		delay -= minTick
		if(sfx != null and delay <= 0 and not sfx.played()){
			sfx.play()
		}
	}

}
import wollok.game.*

class SoundEffect {
	
	method play()
	
}

object silenceJumpEffect inherits SoundEffect {
	
	method play() {}
	
}

object slimeJumpEffect inherits SoundEffect {
	
	override method play() {
		game.sound("slimejump.mp3").play()
	}
	
}

object characterJumpEffect inherits SoundEffect {
	
	override method play() {
		game.sound("mariojump.mp3").play()	}
	
}
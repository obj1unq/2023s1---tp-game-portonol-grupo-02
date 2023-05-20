import wollok.game.*

class SoundEffect {

	method play()

}

object silenceJumpEffect inherits SoundEffect {

	method play() {
	}

}

object slimeJumpEffect inherits SoundEffect {

	override method play() {
		game.sound("slimejump.mp3").play()
	}

}

object characterJumpEffect inherits SoundEffect {

	override method play() {
		game.sound("mariojump.mp3").play()
	}

}

object damagePlayerEffect inherits SoundEffect {

	override method play() {
		game.sound("dmgplayer.mp3").play()
	}

}

object deathPlayerEffect inherits SoundEffect {

	override method play() {
		game.sound("deadplayer.mp3").play()
	}

}

//object titleScreenBGM inherits SoundEffect {
//	
//	override method play() {
//		game.sound("titlescreenBGM.mp3").play()
//	}
//	
//}
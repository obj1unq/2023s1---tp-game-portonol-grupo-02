import wollok.game.*

class SoundEffect {

	method play()

}

object silenceJumpEffect inherits SoundEffect {

	override method play() {
		return null
	}

}

object slimeJumpEffect inherits SoundEffect {

	override method play() {
		return game.sound("slimejump.mp3").play()
	}

}

object damagePlayerEffect inherits SoundEffect {

	override method play() {
		return game.sound("dmgplayer.mp3").play()
	}

}

object stabKnifeEffect inherits SoundEffect {
	override method play() {
		return game.sound("knife-impact-sound.mp3").play()
	}
}

object slingshotEffect inherits SoundEffect {
	override method play() {
		return game.sound("slingshot-sound.mp3").play()
	}
}

object deathPlayerEffect inherits SoundEffect {

	override method play() {
		return game.sound("deadplayer.mp3").play()
	}

}
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
		game.sound("slimejump.mp3").play()
	}

}

object mainTheme inherits SoundEffect {
	
	override method play() {
		const sound = game.sound("mainmusic.mp3")
		sound.shouldLoop(true)
		sound.volume(0.25)
		sound.play()
	}
	
}

object damagePlayerEffect inherits SoundEffect {

	override method play() {
		game.sound("dmgplayer.mp3").play()
	}

}

object stabKnifeEffect inherits SoundEffect {
	override method play() {
		game.sound("knife-impact-sound.mp3").play()
	}
}

object clangEffect inherits SoundEffect {
	override method play() {
		game.sound("clangberserk.mp3").play()
	}
}

object slingshotEffect inherits SoundEffect {
	override method play() {
		game.sound("slingshot-sound.mp3").play()
	}
}

object deathPlayerEffect inherits SoundEffect {

	override method play() {
		return game.sound("deadplayer.mp3").play()
	}

}
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
	
	var sound = null
	
	override method play() {
		sound = game.sound("mainmusic.mp3")
		sound.shouldLoop(true)
		sound.volume(0.25)
		sound.play()
	}
	
	method stop() {
		sound.stop()
	}
	
}

object bossTheme inherits SoundEffect {
	
	var sound = null
	
	override method play() {
		sound = game.sound("boss-theme.mp3")
		sound.shouldLoop(true)
		sound.volume(0.25)
		sound.play()
	}
	
	method stop() {
		sound.stop()
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

object zombieHitEffect inherits SoundEffect {
	override method play() {
		game.sound("clangberserk.mp3").play()
	}
}

object slimeHitEffect inherits SoundEffect {
	override method play() {
		game.sound("clangberserk.mp3").play()
	}
}

object flyHitEffect inherits SoundEffect {
	override method play() {
		game.sound("clangberserk.mp3").play()
	}
}

object chargeHitEffect inherits SoundEffect {
	override method play() {
		game.sound("clangberserk.mp3").play()
	}
}

object pingPongHitEffect inherits SoundEffect {
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
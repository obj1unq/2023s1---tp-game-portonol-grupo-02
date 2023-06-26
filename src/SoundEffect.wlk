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

object itemPickedUpEffect inherits SoundEffect {
	override method play() {
		game.sound("item-pickup-sound.mp3").play()
	}
}

object enterBossRoomEffect inherits SoundEffect {
	override method play() {
		game.sound("enter-boss.mp3").play()
	}
}

object levelTransitionEffect inherits SoundEffect {
	override method play() {
		game.sound("leveltransition.mp3").play()
	}
}

object slingshotEffect inherits SoundEffect {
	override method play() {
		game.sound("slingshot-sound.mp3").play()
	}
}

object deathPlayerEffect inherits SoundEffect {

	override method play() {
		game.sound("deadplayer.mp3").play()
	}

}
class DamageManager {

	method dealDmg(giver, receiver) {
		receiver.takeDmg(giver.damage())
	}

}


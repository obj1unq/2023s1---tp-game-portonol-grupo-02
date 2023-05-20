object global {
	const enemies = #{}
	var player
	
	method addEnemy(enemy){
		enemies.add(enemy)
	}
	
	method player(_player){
		player = _player
	}
	
	method isEnemy(entity) = enemies.any{enemy => enemy == entity}
	
	method isPlayer(entity) = entity == player
	
}
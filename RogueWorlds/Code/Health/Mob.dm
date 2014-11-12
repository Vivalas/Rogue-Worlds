mob
	var/can_fight = 1
	proc
		HealthUpdate()

		StunChanged()

		HealthChanged()

		GetHealth()
			return 100

		//#################

		Damage(dtype,amt)

		Healing(dtype,amt)

		//#################

		GetStamina()
			return 100

		Stamina(n)
			HealthChanged()

		Stun()
		UnStun()

		Down()
		Up()

		IsDown()
			return 0
		IsStunned()
			return 0

		GetStunState()
			return ""

		//################

		CanClick()
			return 1
		CanMove()
			return 1

		//################

		CombatDaze()

		CombatIsDazed()
			return 0

		damage()

		Die()
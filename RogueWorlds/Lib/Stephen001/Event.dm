/**
 * An event is some action that can trigger at some time in the future. This base-object
 * can be extended to carry whatever code you want to execute.
 */
Event
	proc
		/**
		 * Called when the event fires.
		 */
		fire()

/**
 * A common recurring timer.
 */
Event/Timer
	/**
	 * Constructs the timer, to repeatedly schedule on a specific
	 * scheduler, with a given frequency.
	 *
	 * @param scheduler The scheduler to repeatedly schedule on.
	 * @param frequency The frequency to re-schedule.
	 */
	New(var/EventScheduler/scheduler, var/frequency as num)
		src.__scheduler = scheduler
		src.__frequency = frequency

	/**
	 * Re-schedules, then performs an action.
	 */
	fire()
		src.__scheduler.schedule(src, src.__frequency, rand(10))
		..()

	var
		__frequency
		EventScheduler/__scheduler
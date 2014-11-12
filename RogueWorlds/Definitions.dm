#define true 1
#define false 0

#define PI 3.1415926

#define MINUTES(X) ((X)*600)
#define SECONDS(X) ((X)*10)
#define HOURS(X) ((X)*36000)

#define BORDER SetLight(5,outside_light-1)

#define MAT_ADD 0
#define MAT_MUL 1
#define MAT_XOR 2

//Skills
#define NOSKILLS 0
#define LEADERSHIP 1
#define MECHANICS 2
#define MEDICINE 4
#define SCIENCE 8
#define LABOUR 16
#define COMBAT 32

//Fighting
#define NONE 0
#define SEARCHING 1
#define INCLUDE_SHIELD 1
#define PI 3.1416
#define PI_OVER_2 1.5708
#define PI_OVER_4 0.7854

//Construction Times
#define SUPPORT_CON 50
#define SUPPORT_DEC 50

#define WOODFLOOR_CON 20
#define WOODFLOOR_DEC 30
#define METALFLOOR_CON 40
#define METALFLOOR_DEC 50

#define WOODFRAME_CON 30
#define WOODFRAME_DEC 20
#define METALFRAME_CON 50
#define METALFRAME_DEC 40

#define WOODWALL_CON 40
#define WOODWALL_DEC 50
#define METALWALL_CON 60
#define METALWALL_DEC 80

#define WINDOW_CON 40
#define WINDOW_DEC 60

#define WOODDOOR_CON 40
#define WOODDOOR_DEC 40
#define METALDOOR_CON 60
#define METALDOOR_DEC 60

#define RAILING_CON 20
#define RAILING_DEC 10

//Single Sounds
#define WRENCH_SND 'Sounds/Tools/Wrench.ogg'
#define HAMMER_SND 'Sounds/Tools/Hammer.ogg'
#define CROWBAR_SND 'Sounds/Tools/Crowbar.ogg'
#define SCREWDRIVER_SND 'Sounds/Tools/Screwdriver.ogg'
#define UNSCREW_SND 'Sounds/Tools/Screwdriver.ogg'
#define BAR_SND 'Sounds/Combat/BlockMetal1.ogg'
#define LOCKPICK_SND 'Sounds/Tools/LockpickSuccess.ogg'

//Sound Collections
#define BLUNT_SOUNDS list('Sounds/Combat/Blunt1.ogg','Sounds/Combat/Blunt2.ogg','Sounds/Combat/Blunt3.ogg','Sounds/Combat/Blunt4.ogg')
#define STAB_SOUNDS list('Sounds/Combat/Stab1.ogg','Sounds/Combat/Stab2.ogg','Sounds/Combat/Stab3.ogg')

#define SWORD_SOUNDS list('Sounds/Combat/Stab1.ogg','Sounds/Combat/Stab2.ogg','Sounds/Combat/Stab3.ogg',\
						'Sounds/Combat/Sword1.ogg','Sounds/Combat/Sword2.ogg','Sounds/Combat/Sword3.ogg')

#define BLOCK_SOUNDS list('Sounds/Combat/BlockMetal1.ogg','Sounds/Combat/BlockMetal2.ogg','Sounds/Combat/BlockMetal3.ogg',\
	'Sounds/Combat/BlockMetal4.ogg','Sounds/Combat/BlockSword1.ogg','Sounds/Combat/BlockSword2.ogg')

#define WOOD_BLOCK_SOUNDS list('Sounds/Combat/BlockWood1.ogg','Sounds/Combat/BlockWood2.ogg',\
								'Sounds/Combat/BlockWood3.ogg','Sounds/Combat/BlockWood4.ogg')

/*
Access:

Bridge
Security
Chemistry
Engine
Locksmith
Secure Storage

*/

#define C_BRIDGE     "520250"
#define C_SECURITY   "330330"
#define C_CHEMISTRY  "259571"
#define C_ENGINE     "357200"
#define C_LOCKSMITH  "001258"
#define C_SECSTORAGE "582914"
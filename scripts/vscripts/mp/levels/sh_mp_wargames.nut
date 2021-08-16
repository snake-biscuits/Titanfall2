
global const asset FX_POD_SCREEN_IN	= $"P_pod_screen_lasers_IN"
global const float WARGAMES_INTRO_NOT_STARTED = -1.0 //Needs to be here instead of sh_mp_wargames because of timing of script compilation issues

global function ShouldDoTrainingPodIntro


bool function ShouldDoTrainingPodIntro()
{
	string gameMode = GameRules_GetGameMode()

	switch ( gameMode )
	{
		case LAST_TITAN_STANDING:
		case WINGMAN_LAST_TITAN_STANDING:
		case TITAN_BRAWL:
		case SPEEDBALL:
		case FFA:
			return false
		case FD:
			return false
		default:
			return true
	}

	unreachable
}

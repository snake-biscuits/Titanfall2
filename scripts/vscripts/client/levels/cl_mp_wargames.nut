
global function ClientCodeCallback_MapInit

global function ServerCallback_StopWargamesPodAmbienceSound
global function ServerCallback_SpawnIMCFactionLeaderForIntro
global function ServerCallback_SpawnMilitiaFactionLeaderForIntro
global function ServerCallback_ClearFactionLeaderIntro
global function ServerCallback_PlayPodTransitionScreenFX



struct
{
	array<entity> factionLeaderIntroEnts
	bool factionLeaderSpawned = false
} file


void function ClientCodeCallback_MapInit()
{
	ClCarrier_Init() //Not actually sure if we want skyshows in wargames, but they were in the first game. Easy to remove at any rate.

	if ( !IsMultiplayerPlaylist() )
		return

	if ( !ShouldDoTrainingPodIntro() )
		return

	RegisterSignal( "StopWargamesPodAmbienceSound" )

	ClassicMP_Client_SetGameStateEnterFunc_WaitingForPlayers( WarGames_GameStateEnterFunc_WaitingForPlayers )
	ClassicMP_Client_SetGameStateEnterFunc_PickLoadOut( WarGames_GameStateEnterFunc_PickLoadout )
}

void function WarGames_GameStateEnterFunc_WaitingForPlayers( entity player ) //Copy of ClassicMP_JumpingToLocation_GameStateEnterFunc_WaitingForPlayers
{
	ClassicMP_DefaultCreateJumpInRui( player )
	ClassicMP_SetJumpInRuiText( "#WARGAMES_INTRO_BOOTING_POD" )
}

void function WarGames_GameStateEnterFunc_PickLoadout( entity player ) //Almost a direct copy of ClassicMP_Dropship_GameStateEnterFunc_PickLoadOut, minus the dropship sounds
{
	ClassicMP_DefaultCreateJumpInRui( player )
	ClassicMP_SetJumpInRuiText( "#WARGAMES_INTRO_BOOTING_POD" )
	HidePermanentCockpitRui()

	SetShouldShowFriendIcon( false )

	thread TrainingPodAmbienceSounds( player )
}

void function TrainingPodAmbienceSounds( entity player ) //Somewhat awkward, structured this way just to make sure sound is played and killed in one function.
{
	if ( GetGameState() >= eGameState.Playing )
		return

	EmitSoundOnEntity( player, "Amb_Wargames_Pod_Ambience" )

	player.EndSignal( "StopWargamesPodAmbienceSound" )

	OnThreadEnd(
	function() : ( player )
		{
			if ( !IsValid( player ) )
				return

			//printt( "Stopping ambience sound" )

			FadeOutSoundOnEntityByName( player, "Amb_Wargames_Pod_Ambience", 0.13 )
		}
	)

	WaitForever()
}

void function ServerCallback_StopWargamesPodAmbienceSound()
{
	entity player = GetLocalClientPlayer()
	player.Signal( "StopWargamesPodAmbienceSound" )
}

void function ServerCallback_SpawnIMCFactionLeaderForIntro( float animStartTime, int podEHandle ) //podEHandle not used, just added for parity with the milita side function that does use it.
{
	if ( file.factionLeaderSpawned ) //Run this once, create faction leader at the appropriate time in the sequence
		return

	if ( animStartTime == WARGAMES_INTRO_NOT_STARTED )
		return

	file.factionLeaderSpawned = true

	entity localViewPlayer = GetLocalViewPlayer()
	string faction = GetFactionChoice( localViewPlayer )

	string animName = "pt_bored_interface_leanback"

	if ( faction == "faction_vinson" )
	{
		printt( "Specific Ash anim: pt_bored_interface_leanback_ash" )
		animName = "pt_bored_interface_leanback_ash" //Separate anim for ash so audio can do specific sounds events for her
	}

	entity factionLeader = CreatePropDynamic( GetFactionModel( faction ), < -2710, 2938, -1786 >, < 0, -147, 0 > )
	thread PlayAnim( factionLeader, animName, null, null, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, 0 )
	factionLeader.Anim_SetStartTime( animStartTime - 4.5 )

	file.factionLeaderIntroEnts.append( factionLeader )
}

void function ServerCallback_SpawnMilitiaFactionLeaderForIntro( float animStartTime, int militiaPodEHandle )
{
	if ( file.factionLeaderSpawned ) //Run this once, create faction leader at the appropriate time in the sequence
		return

	if ( animStartTime == WARGAMES_INTRO_NOT_STARTED )
		return

	file.factionLeaderSpawned = true

	entity localViewPlayer = GetLocalViewPlayer()
	string faction = GetFactionChoice( localViewPlayer )

	entity animRef
	string animName
	float skipTime = 0.0

	if ( faction == "faction_marvin" ) //Hack: Marvin's anim doesn't work for this
	{
		animRef = GetEntityFromEncodedEHandle( militiaPodEHandle )
		animName = "mv_wargames_intro"
	}
	else
	{
		vector refOrg = Vector( -1809.98, 2790.39, -1412 )
		vector refAng = Vector( 0, 80, 0 )
		animRef = CreateScriptRef( refOrg, refAng )
		animName = "pt_titan_activation_crew"
		skipTime = 4.0
		file.factionLeaderIntroEnts.append( animRef )
	}


	entity factionLeader = CreatePropDynamic( GetFactionModel( faction ) )
	factionLeader.SetSkin( GetFactionModelSkin( faction ) ) //Really this is marvin specific
	thread PlayAnim( factionLeader, animName, animRef, null, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, 0 )
	factionLeader.Anim_SetStartTime( animStartTime - skipTime )

	file.factionLeaderIntroEnts.append( factionLeader )
}

void function ServerCallback_ClearFactionLeaderIntro()
{
	//PrintFunc()

	SetShouldShowFriendIcon( true )

	foreach( ent in file.factionLeaderIntroEnts )
	{
		if ( IsValid( ent ) )
			ent.Destroy()
	}

	file.factionLeaderIntroEnts.clear()

	file.factionLeaderSpawned = false
}

void function ServerCallback_PlayPodTransitionScreenFX()
{
	entity viewPlayer = GetLocalViewPlayer()

	int fxID = GetParticleSystemIndex( FX_POD_SCREEN_IN )

	//StartParticleEffectOnEntity( viewPlayer, fxID )

	StartParticleEffectInWorld( fxID, <0,0,0>, <0,0,0> )
}
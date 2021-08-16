global function ClientCodeCallback_MapInit
//global function WeatherUpdate

const asset FX_WEATHER_POLLEN = $"P_weather_pollen"

struct
{
	int weatherFxHandle = -1
} file


void function ClientCodeCallback_MapInit()
{

	AddCallback_OnClientScriptInit( WeatherUpdate )

	PrecacheParticleSystem( FX_WEATHER_POLLEN )
	ClCarrier_Init() //Included for skyshow dogfights
}


void function WeatherUpdate( entity player )
{
	thread WeatherUpdateThread( player )
}


void function WeatherUpdateThread( entity player )
{
	while ( true )
	{
		thread WeatherSnow( GetLocalClientPlayer() )
		wait 0.5
	}
}


void function WeatherSnow( entity player )
{
	if ( EffectDoesExist( file.weatherFxHandle ) )
		return

	int weatherID = GetParticleSystemIndex( FX_WEATHER_POLLEN )

	vector offset = < 0, 0, 100 >
	vector angles = < 0, 0, 0 >

	if ( player == GetLocalViewPlayer() || !IsWatchingReplay() )
	{
		int fxHandle = StartParticleEffectOnEntityWithPos( player, weatherID, FX_PATTACH_ABSORIGIN_FOLLOW, -1, offset, angles )
		file.weatherFxHandle = fxHandle
	}
	else
	{
		file.weatherFxHandle = -1
	}
}
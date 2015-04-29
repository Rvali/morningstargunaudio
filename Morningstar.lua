--
-- Unreal Kills
--   by: thiconZ
--

require "unicode"
require "math"
require "string";
require "lib/lib_InterfaceOptions"

-- COMPONENTS

local WEBFRAME = Component.GetFrame("Web");

-- CONSTANTS

local settings =
{
	enabled = true,
	volume = 0.3,
	pve = false,
	pvp = true
};

-- OPTIONS

InterfaceOptions.StartGroup({id="enabled", label="Enabled", checkbox=true, default=settings.enabled})	
InterfaceOptions.AddSlider({id="volume", label="Volume", default=settings.volume, min=0.0, max=1, inc=.01, format="%.01f", suffix="%"})
InterfaceOptions.AddCheckBox({id="pve", label="Track In PvE", default=settings.pve})
InterfaceOptions.AddCheckBox({id="pvp", label="Track In PvP", default=settings.pvp})
InterfaceOptions.StopGroup()

-- VARIABLES

local KillCount = 0
local FastCount = 0
local FastTime = 0
local FastBreak = 0

-- FUNCTIONS

function OnComponentLoad()
	InterfaceOptions.SetCallbackFunc(OnSetting, "Morningstar")
end

function OnPlayerReady(args)
    WEBFRAME:SetUrlFilters("*");
    WEBFRAME:LoadUrl("")
end

function OnCombatEvent(args)
	--args = SourceFaction, SourceName, Method, TargetName, Event, TargetFaction, event, TargetId, SourceId
	if (settings.pve == true and settings.pvp == true) then
		TrackKill(args)
	elseif (settings.pvp == true) then
		if (Game.GetZoneId() == 1021) then
			TrackKill(args)
		end
	elseif (settings.pvp == false and settings.pve == true) then
		if (Game.GetZoneId() ~= 1021) then
			TrackKill(args)
		end
	end
end

function TrackKill(args)
	if (args.SourceId == Game.GetTargetIdByName(Player.GetInfo()) and args.Event == "Downed") then
		KillCount = KillCount + 1
		Play((KillCount/5)-1)
		FastBreak = System.GetElapsedTime(FastTime)
		FastTime = System.GetClientTime()
		log(tostring(FastBreak))
		if (FastBreak < 4) then
			FastCount = FastCount + 1
			PlayTime(FastCount-1)
		else
			FastCount = 0
		end
	end
end

function OnDeath()
	KillCount = 0
	FastCount = 0
end

function OnSetting(id, val)
	if (id == "enabled") then
		settings.enabled = val
	elseif (id == "volume") then
		settings.volume = val
		SetVolume(val)
	elseif (id == "pve") then
		settings.pve = val
	elseif (id == "pvp") then
		settings.pvp = val
	end
end

function Play(kill)
	log(tostring("Kill Count: "..KillCount.." Kill: "..kill))
	log(tostring(kill%1))
	if (kill%1 == 0) then
    	WEBFRAME:CallWebFunc('PlayKill', kill);
	end
end

function PlayTime(kills)
	log(tostring("Fast Count: "..FastCount.." Fast Kills: "..kills))
    WEBFRAME:CallWebFunc('PlayTime', kills);
end

function SetVolume(vol)
    WEBFRAME:CallWebFunc('SetVolume', vol)
end
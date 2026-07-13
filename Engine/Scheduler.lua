local ADDON, FrostFarmer = ...

FrostFarmer.Scheduler = FrostFarmer.Scheduler or {}

function FrostFarmer.Scheduler:After(delay, callback)
    C_Timer.After(delay, callback)
end

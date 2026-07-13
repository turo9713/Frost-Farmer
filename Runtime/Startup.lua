local FrostFarmer = FrostFarmer or {}
FrostFarmer.Runtime = FrostFarmer.Runtime or {}

function FrostFarmer.Runtime.Startup()
    if FrostFarmer.Runtime.Bootstrap then
        FrostFarmer.Runtime.Bootstrap()
    end

    if FrostFarmer.Runtime.LoadModules then
        FrostFarmer.Runtime.LoadModules()
    end

    return true
end

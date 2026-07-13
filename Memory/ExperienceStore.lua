local ExperienceStore = {}

ExperienceStore.records = {}

function ExperienceStore.add(experience)
    table.insert(ExperienceStore.records, experience)
end

function ExperienceStore.count()
    return #ExperienceStore.records
end

return ExperienceStore

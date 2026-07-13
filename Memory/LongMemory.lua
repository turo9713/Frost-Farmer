local LongMemory = {}

LongMemory.history = {}

function LongMemory.save(record)
    table.insert(LongMemory.history, record)
end

function LongMemory.all()
    return LongMemory.history
end

return LongMemory

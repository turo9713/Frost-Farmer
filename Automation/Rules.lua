local Rules = {}

Rules.conditions = {}

function Rules:Add(rule)
    table.insert(self.conditions, rule)
end

return Rules

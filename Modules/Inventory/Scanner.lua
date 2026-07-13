local Scanner = {}

function Scanner:Update()
    self.lastScan = time and time() or 0
end

return Scanner
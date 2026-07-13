local MemoryManager = {}
function MemoryManager:Cleanup()
 collectgarbage('collect')
end
return MemoryManager

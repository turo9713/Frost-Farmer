local Queue = {}
Queue.items = {}
function Queue:Add(task) table.insert(self.items, task) end
return Queue

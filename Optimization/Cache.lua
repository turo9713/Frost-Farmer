local Cache = {}
Cache.data = {}
function Cache:Set(key,value) self.data[key]=value end
function Cache:Get(key) return self.data[key] end
return Cache

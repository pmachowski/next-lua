--====================================================================--
--
-- Code by Piotr Machowski <piotr@machowski.co>
--
-- inspired by DMC Lua Library: Promises
--====================================================================--

local VERSION = "0.1.0"

--====================================================================--
-- Setup, Constants
local tinsert = table.insert

local Promise, Deferred -- forward declaration



--====================================================================--
-- Promise Class
--====================================================================--

Promise = {}
Promise.__index = Promise
Promise.NAME = "Promise Instance"
setmetatable(Promise, { __call = function(_, ...) return Promise.new(...) end })

--== State Constants
Promise.STATE_PENDING  = 'pending'
Promise.STATE_RESOLVED = 'resolved'
Promise.STATE_REJECTED = 'rejected'


--====================================================================--
-- constructor function
function Promise:new(  )
	local o = setmetatable( {}, Promise )
	o._state = Promise.STATE_PENDING
	o._done_cbs = {}
	o._fail_cbs = {}

	o._result = nil
	o._reason = nil
	return o
end

--====================================================================--


--====================================================================--
--== Public Methods

function Promise:state()
	return self._state
end

function Promise:resolve( ... )
	-- print("Promise:resolve")
	self._state = Promise.STATE_RESOLVED
	self._result = {...}
	self:_execute( self._done_cbs, ... )
end

function Promise:reject( ... )
	-- print("Promise:reject")
	self._state = Promise.STATE_REJECTED
	self._reason = {...}
	self:_execute( self._fail_cbs, ... )
end


function Promise:done( callback )
	-- print("Promise:done")
	if self._state == Promise.STATE_RESOLVED then
		callback( unpack( self._result ) )
	else
		self:_addCallback( self._done_cbs, callback )
	end
end

function Promise:fail( errback )
	-- print("Promise:fail")
	if self._state == Promise.STATE_REJECTED then
		errback( unpack( self._reason ) )
	else
		self:_addCallback( self._fail_cbs, errback )
	end
end

function Promise:andThen( callback, errback )
	if callback then self:done( callback ) end
	if errback then self:fail( errback ) end
	return self
end

function Promise:next( ... )
	return self:andThen(...)
end


--====================================================================--
--== Private Methods

function Promise:_addCallback( list, func )
	tinsert( list, #list+1, func )
end

function Promise:_execute( list, ... )
	-- print("Promise:_execute")
	for i=1,#list do
		list[i]( ... )
	end
end





--====================================================================--
-- Deferred Class
--====================================================================--

Deferred = {}
Deferred.__index = Deferred
Deferred.NAME = "Deferred Instance"
setmetatable(Deferred, { __call = function(_, ...) return Deferred.new(...) end })

--====================================================================--
-- constructor function
function Deferred:new( )
	local o = setmetatable( {}, Deferred )
	o.promise = Promise:new()
	return o
end
--====================================================================--


--====================================================================--
--== Public Methods

function Deferred:resolve( ... )
	self.promise:resolve( ... )
end
function Deferred:reject( ... )
	self.promise:reject( ... )
end

function Deferred:addCallbacks( callback, errback )
	local promise = self.promise
	if callback then promise:done( callback ) end
	if errback then promise:fail( errback ) end
end


--====================================================================--
-- Promise Module Facade
--====================================================================--
return {
	Promise  = Promise,
	Deferred = Deferred,
}

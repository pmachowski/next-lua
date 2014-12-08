##Usage

	local Next = require 'next'

	function retrieveServerUrl( )
		print( 'requesting socket info from:', c.config.apiUrl )
		local deferred = Q.Deferred()
		local req = network.request( c.config.apiUrl, 'GET', function ( event )
				if event.isError then
					print( 'network error' )
					deferred:reject({error='network error'})
				else
					if event.status == 200 then
						print( 'socket info:', event.response )
						deferred:resolve({response=json.decode( event.response )})
					else
						deferred:reject({error='server error', response=event.response})
					end
				end
			end, {timeout=5} )
		return deferred.promise
	end


	retrieveServerUrl():next(
		function ( event )--success callback
			print( 'server credentials received:', event.response.ip, event.response.port)
			connectToServer(event.response.ip, event.response.port)
		end,
		function ( event )--error callback
			print (inspect(event))
			if event.error=='server' then
				_log({name='erorr', message='server error'})
			end
			if event.error=='connection' then
				_log({name='erorr', message='connection error'})
			end
		end
	)


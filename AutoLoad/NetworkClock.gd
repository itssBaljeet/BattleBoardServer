extends Node


## The current physics frame of the server, since the server was stared. Has no
## relevance to gameplay, except in relation to other measurements in ticks.
var serverTick: int = 0

## Track the ticks as they pass, to keep time consistent.
func _physics_process(_delta: float) -> void:
	serverTick += 1

###############################################################################
#region RPCS

## Calculates client tick differential, and returns the clients millisecond send
## value, in order to calculate ping.
@rpc("any_peer", "reliable")
func s_ping(echoClientClockMs: int, echoClientTick: int) -> void:
	var requestingClientId: int = multiplayer.get_remote_sender_id()
	
	# Record tick diferential, so client can be sure of deltas.
	c_pong.rpc_id(
		requestingClientId, # Only update ping for the specific client
		serverTick,
		echoClientTick,
		echoClientClockMs,
	)

#endregion
###############################################################################



###############################################################################
#region RPC PARITY

@rpc("reliable")
func c_pong(_echoClientTick: int, _echoClientClockMs: int) -> void: pass

#endregion RPC FUNCTIONS
###############################################################################

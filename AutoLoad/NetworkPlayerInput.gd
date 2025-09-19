extends Node

#region Types

enum PlayerIntent {
	MOVE,
	ATTACK,
	SPECIAL_ATTACK,
	PLACE_UNIT,
	WAIT,
	END_TURN,
	UNDO,
}

#endregion

#region Signals

signal playerIntentReceived(peerId: int, intentType: PlayerIntent, intent: Dictionary)
signal undoCommandRequest

#endregion


###############################################################################
#region RPCS

@rpc("any_peer", "reliable")
func s_submitPlayerIntent(intentType: PlayerIntent, intent: Dictionary) -> void:
	var peerId := multiplayer.get_remote_sender_id()
	playerIntentReceived.emit(peerId, intentType, intent)

@rpc("any_peer", "reliable")
func s_undoLastCommand() -> void:
	undoCommandRequest.emit()

#endregion
###############################################################################



###############################################################################
#region RPC PARITY

@rpc("reliable")
func c_commandExecuted(_playerId: int, _commandType: PlayerIntent, _results: Dictionary) -> void:
	pass

@rpc("reliable")
func c_commandUndone(_playerId: int, _commandType: PlayerIntent, _results: Dictionary) -> void: pass

#endregion RPC FUNCTIONS
###############################################################################

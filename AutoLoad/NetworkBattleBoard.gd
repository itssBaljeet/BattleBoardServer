extends Node

#region Types

enum GamePhase {
	PLACEMENT = 0,
	COINFLIP = 1,
	BATTLE = 2,
}



#endregion


###############################################################################
#region RPCS



#endregion
###############################################################################



###############################################################################
#region RPC PARITY

@rpc("reliable")
func c_emitPhaseChanged(_newPhase: GamePhase) -> void: pass

@rpc("reliable")
func c_updateCurrentTeam(_newTeam: FactionComponent.Factions) -> void: pass

@rpc("reliable")
func c_emitUnitState(_data: Dictionary) -> void: pass

#endregion RPC FUNCTIONS
###############################################################################

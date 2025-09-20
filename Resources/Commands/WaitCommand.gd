## Wait Command - marks unit as done without action
@tool
class_name WaitCommand
extends BattleBoardCommand

var unit: BattleBoardUnitServerEntity

func _init() -> void:
	commandName = "Wait"
	requiresAnimation = false

func canExecute(_context: BattleBoardContext) -> bool:
	print("UNIT WE'RE TRYING TO WAIT")
	print(unit.boardPositionComponent.currentCellCoordinates)
	print(unit.stateComponent.currentState, not unit.stateComponent.isExhausted())
	return not unit.stateComponent.isExhausted()

func execute(context: BattleBoardContext) -> void:
	commandStarted.emit()
	
	var state := unit.components.get(&"UnitTurnStateComponent") as UnitTurnStateComponent
	if state:
		print("WAIT COMMAND ACTUALLY EXECUTED")
		state.markExhausted()
		if context.rules.isTeamExhausted(unit.factionComponent.factions):
			context.factory.intentEndTurn(TurnBasedCoordinator.currentTeam)
	else:
		commandFailed.emit("No state component on unit")
		return
	
	var intent := {
		"cell": unit.boardPositionComponent.currentCellCoordinates
	}
	
	NetworkPlayerInput.c_commandExecuted.rpc_id(0, playerId, NetworkPlayerInput.PlayerIntent.WAIT, intent)
	
	#context.emitSignal(&"UnitWaited", {"unit": unit})
	commandCompleted.emit()

func canUndo() -> bool:
	return false

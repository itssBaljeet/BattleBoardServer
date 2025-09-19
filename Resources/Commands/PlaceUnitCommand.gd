## Command to place a unit on the board during pre-game setup
@tool
class_name PlaceUnitCommand
extends BattleBoardCommand

var unit: Meteormyte

var cell: Vector3i
var faction: FactionComponent.Factions
var _placed: bool = false

func _init() -> void:
	commandName = "PlaceUnit"
	requiresAnimation = false

func canExecute(context: BattleBoardContext) -> bool:
	if not unit:
		print("No unit provided")
		commandFailed.emit("No unit provided")
		return false
	if not context.rules.isValidPlacement(cell, faction):
		print("invalid placement option")
		commandFailed.emit("Invalid placement")
		return false
	return true

func execute(context: BattleBoardContext) -> void:
	commandStarted.emit()
	
	print("Creating new server unit entity")
	var boardUnit: BattleBoardUnitServerEntity = BattleBoardUnitServerEntity.new(unit, context.boardState, faction)
	context.boardState.parentEntity.add_child(boardUnit)

	print(boardUnit)

	if boardUnit.boardPositionComponent:
		boardUnit.boardPositionComponent.setCurrentCell(cell)
	context.boardState.setCellOccupancy(cell, true, boardUnit)
	_placed = true
	
	
	match faction:
		FactionComponent.Factions.player1:
			TurnBasedCoordinator.playerOnePlacementParty.remove_meteormyte(unit)
		FactionComponent.Factions.player2:
			TurnBasedCoordinator.playerTwoPlacementParty.remove_meteormyte(unit)
	
	TurnBasedCoordinator.checkPlacementComplete()
	
	var results := {
		"unit": unit.toDict(),
		"cell": cell,
		"team": faction,
	}
	
	NetworkPlayerInput.c_commandExecuted.rpc_id(0, NetworkPlayerInput.PlayerIntent.PLACE_UNIT, results)
	
	context.emitSignal(&"UnitPlaced", {
		"unit": unit,
		"cell": cell,
		"team": faction,
	})
	commandCompleted.emit()

func canUndo() -> bool:
	return _placed

func undo(context: BattleBoardContext) -> void:
	context.boardState.setCellOccupancy(cell, false, null)
	_placed = false
	context.emitSignal(&"UnitUnplaced", {
		"unit": unit,
		"cell": cell
	})

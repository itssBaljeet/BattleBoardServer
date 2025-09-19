extends Node

# The port for the client to connect on. (pick something between 10k and 40k)
@export var port := 11909

## Maximum number of players allowed to connect to thiis server
## before join requests are denied, and the number of players required to 
## begin a game
@export var maxPlayers: int = 2

var runningHeadless: bool = false # Set in ready()

var network := ENetMultiplayerPeer.new()

## Returns a bool representing whether the client is currently connected to the 
## server
var isConnected: bool:
	get:
		var value: int = multiplayer.multiplayer_peer.get_connection_status()
		var ok: int = MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED
		return value == ok

var connectedClients: PackedInt32Array:
	get: return multiplayer.get_peers()

var connectedClientCount: int:
	get: return connectedClients.size()

## Tracks number of players that have clicked "ready up" in lobby.
var clientReadyCount: int = 0

## First player to connect
var playerOne: int = -1

## Second player to connect
var playerTwo: int = -1


################################################################################
#region LOGIC

func _ready() -> void:
	startServer()

func startServer() -> void:
	print(
		"Server: Starting server on ",
		IP.get_local_addresses()[0],
		" : ",
		port
	)
	print(
		"Server: Players required for game: ",
		maxPlayers
	)
	
	# Initialize the network
	network.create_server(port, maxPlayers)
	
	print(network.get_connection_status())
	
	# Set the multiplayer peer. Now, the scene tree's default "multiplayer"
	# (and by proxy, the multiplayer variable for all nodes in the scene tree)
	# will refer to the one that we have created
	multiplayer.multiplayer_peer = network
	
	network.connect("peer_connected", self._peerConnected)
	network.connect("peer_disconnected", self._peerDisconnected)

func _peerConnected(connectedClientId: int) -> void:
	print(
		"Server: User ",
		str(connectedClientId),
		" connected to lobby (",
		len(connectedClients),
		" online)."
	)
	
	# Bad sentinel check but whatever
	if playerOne == -1:
		playerOne = connectedClientId
	else:
		playerTwo = connectedClientId
	
	# If server finally full
	if len(connectedClients) == maxPlayers:
		print("Server: Game full, switching to lobby screen.")
		print("Server: Starting placement phase")
		var playerTeam: Party = preload("res://Game/Resources/TestParties/PlayerParty.tres")
		var enemyTeam: Party = preload("res://Game/Resources/TestParties/EnemyParty.tres")
		
		TurnBasedCoordinator.startPlacementPhase(playerTeam, false, enemyTeam)

func _peerDisconnected(disconnectedClientId: int) -> void:
	print(
		"Server: User ",
		str(disconnectedClientId),
		" disconnected (",
		len(connectedClients),
		" online)"
	)
	
	# Despawn the player on all clients
#endregion
################################################################################



###############################################################################
#region RPCS

@rpc("any_peer", "reliable")
func s_requestPlayerNumber() -> void:
	var peer: int = multiplayer.get_remote_sender_id()
	print("PRINTING PEER")
	print(peer)
	print(
		"Player one: ",
		playerOne,
		"Player two: ",
		playerTwo
	)
	match peer:
		playerOne:
			print("Updating player one number...")
			c_updatePlayerNumber.rpc_id(peer, 1)
		playerTwo:
			print("Updating player two number...")
			c_updatePlayerNumber.rpc_id(peer, 2)

#endregion
###############################################################################



###############################################################################
#region RPC PARITY

@rpc("reliable")
func c_updatePlayerNumber(_number: int) -> void: pass

#endregion RPC FUNCTIONS
###############################################################################

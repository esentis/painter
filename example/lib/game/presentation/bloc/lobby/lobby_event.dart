sealed class LobbyEvent {
  const LobbyEvent();
}

class LobbyNameSubmitted extends LobbyEvent {
  final String name;
  const LobbyNameSubmitted(this.name);
}

class LobbyCreateRoom extends LobbyEvent {
  const LobbyCreateRoom();
}

class LobbyJoinRoom extends LobbyEvent {
  final String code;
  const LobbyJoinRoom(this.code);
}

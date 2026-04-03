class Room {
  final String roomCode;
  final String roomName;
  final String roomType;
  final String status;

  Room({
    required this.roomCode,
    required this.roomName,
    required this.roomType,
    required this.status,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomCode: json['Room_Code'] ?? "",
      roomName: json['Room_Name'] ?? "",
      roomType: json['Room_Type'] ?? "",
      status: json['Status'] ?? "",
    );
  }
}
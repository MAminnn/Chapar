class AcceptFriendRequestDTO {
  int friendRequestId;

  AcceptFriendRequestDTO(this.friendRequestId);

  Map<String, dynamic> toJson() {
    return {'friendRequestId': friendRequestId};
  }
}

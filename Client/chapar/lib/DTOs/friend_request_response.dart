import 'received_friend_request.dart';

class FriendRequestResponse {
  List<ReceivedFriendRequest>? receivedFriendRequest;

  FriendRequestResponse(this.receivedFriendRequest);
  factory FriendRequestResponse.fromJson(Map<String, dynamic> json) {
    List<ReceivedFriendRequest> receivedFRs =
        (json['receivedFriendRequests'] as List<dynamic>)
            .map<ReceivedFriendRequest>((element) {
      var test = element;
      return ReceivedFriendRequest.fromJson(test);
    }).toList();
    return FriendRequestResponse(receivedFRs);
  }
}

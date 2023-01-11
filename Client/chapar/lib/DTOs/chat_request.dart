class ChatRequest {
  int chatId;
  int skipCount;
  ChatRequest(this.chatId, this.skipCount);

  Map<String, dynamic> toJson() {
    return {'ChatId': chatId, 'SkipCount': skipCount};
  }
}

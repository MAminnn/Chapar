class AddGroup {
  List<int> contactsIds;
  String title;

  AddGroup(this.contactsIds, this.title);

  Map<String, dynamic> toJson() {
    return {'Title': title, 'ContactsIds': contactsIds};
  }
}

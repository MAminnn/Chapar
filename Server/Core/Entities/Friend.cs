namespace Core.Entities
{
    public class Friend
    {
        public Contact Contact { get; set; }
        public int? ContactId { get; set; }

        public string FriendUsername { get; set; }
        public int FriendContactId { get; set; }
    }
}

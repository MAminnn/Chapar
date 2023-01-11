using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Core.Entities
{
    public class Contact
    {
        [Key]
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Username { get; set; }
        public List<Chat> Chats { get; set; }
        public List<FriendRequest> ReceivedFriendRequests { get; set; }
        public List<FriendRequest> SentFriendRequests { get; set; }
        public List<Friend> Friends { get; set; }


        public Contact()
        {
            Chats = new List<Chat>();
            ReceivedFriendRequests = new List<FriendRequest>();
            SentFriendRequests = new List<FriendRequest>();
            Friends = new List<Friend>();
        }
    }
}

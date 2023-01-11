using System.Collections.Generic;

namespace Core.DTOs
{
    public class ChatsResponse
    {
        public int ChatId { get; set; }
        public string Title { get; set; } 
        public SimpleMessage? LastMessage { get; set; }
        public bool Seen { get; set; }
        public List<string> ChatMembers { get; set; }
    }
}

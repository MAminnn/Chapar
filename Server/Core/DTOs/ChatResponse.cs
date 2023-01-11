using System.Collections.Generic;

namespace Core.DTOs
{
    public class ChatResponse
    {
        public List<SimpleContact> Contacts{ get; set; }
        public List<SimpleMessage> Messages { get; set; }

        public int AllMessagesCount { get; set; }
    }
}

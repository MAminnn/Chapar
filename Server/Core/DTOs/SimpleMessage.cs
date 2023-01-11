using System;

namespace Core.DTOs
{
    public class SimpleMessage
    {
        public int Id { get; set; }
        public string Text { get; set; }
        public DateTime SentDate { get; set; }
        public int ChatId { get; set; }
        public int SenderId { get; set; }
        public bool IsDelivered { get; set; }
    }
}

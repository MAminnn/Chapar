using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace Core.Entities
{
    public class ChatContact
    {
        public int ContactId { get; set; }
        public Contact Contact { get; set; }



        public int ChatId { get; set; }
        public Chat Chat { get; set; }

        [MaxLength(30)]
        public string ChatTitle { get; set; }
        public bool Seen { get; set; }

        public Message? LastMessage { get => Chat.Messages.LastOrDefault(); }
    }
}

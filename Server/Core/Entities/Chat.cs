using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Core.Entities
{
    public class Chat
    {
        [Key]
        public int Id { get; set; }
        public List<Contact> Contacts { get; set; }
        public List<Message> Messages { get; set; }
        public Chat()
        {
            Messages = new List<Message>();
            Contacts = new List<Contact>();
        }

    }
}

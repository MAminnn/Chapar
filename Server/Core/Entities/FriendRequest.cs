using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Core.Entities
{
    public class FriendRequest
    {
        [Key]
        public int Id { get; set; }
        public Contact? ToContact { get; set; }
        [ForeignKey("ToContact")]
        public int? ToContactId { get; set; }

        public Contact? FromContact { get; set; }
        [ForeignKey("FromContact")]
        public int FromContactId { get; set; }
        [MaxLength(100)]
        public string Text { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;

namespace Core.ViewModels
{
    internal class MessageViewModel
    {
        public int ChatId { get; set; }
        [MaxLength(750)]
        public string Text { get; set; }
    }
}

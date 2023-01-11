using System.ComponentModel.DataAnnotations;

namespace Core.ViewModels
{
    public class FriendRequestViewModel
    {
        [MaxLength(30)]
        public string RequestMessage { get; set; }
        public string FriendUsername { get; set; }
    }
}

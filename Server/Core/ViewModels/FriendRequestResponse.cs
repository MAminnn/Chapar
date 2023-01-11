using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Core.ViewModels
{
    public class FriendRequestResponse
    {
        public List<ReceivedFriendRequestViewModel> ReceivedFriendRequests { get; set; }
    }
}

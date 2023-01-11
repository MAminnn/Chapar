using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Core.Interfaces;
using System.Security.Claims;
using System.Threading.Tasks;
using Core.ViewModels;
using Core.DTOs;

namespace MessengerAPI.Controllers
{
    [Route("/api/{controllername}/{actionname}")]
    public class ContactController : Controller
    {
        private IContactManager _contactManager;

        public ContactController(IContactManager contactManager)
        {
            _contactManager = contactManager;
        }
        [Authorize]
        [HttpGet]
        [Route("/api/contact/GetFriendRequests")]
        public async Task<IActionResult> GetFriendRequests()
        {
            int Id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier).Value);
            return Json(await _contactManager.GetFriendRequestsAsync(Id));
        }
        [Authorize]
        [HttpPost]
        [Route("/api/contact/SendFriendRequest")]
        public async Task<IActionResult> SendFriendRequest([FromBody] FriendRequestViewModel Frvm)
        {
            int Id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier).Value);
            return Json(await _contactManager.SendFriendRequestAsync(Frvm, Id));
        }
        [Authorize]
        [HttpPost]
        [Route("/api/contact/AcceptFriendRequest")]
        public async Task<IActionResult> AcceptFriendRequest([FromBody] AcceptOrDenideFriendRequest friendRequestId)
        {
            int Id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier).Value);
            return Json(await _contactManager.AcceptFriendRequestAsync(friendRequestId.FriendRequestId, Id));
        }

        [Authorize]
        [HttpPost]
        [Route("/api/contact/DenideFriendRequest")]
        public async Task<IActionResult> DenideFriendRequest([FromBody] AcceptOrDenideFriendRequest friendRequestId)
        {
            int Id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier).Value);
            return Json(await _contactManager.DenideFriendRequestAsync(friendRequestId.FriendRequestId, Id));
        }

        [Authorize]
        [HttpGet]
        [Route("/api/Contact/GetContactbyUser")]
        public async Task<IActionResult> GetContactbyUser()
        {
            int Id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier).Value);
            return Json(await _contactManager.GetContactByUserAsync(Id));
        }

        [Authorize]
        [HttpGet]
        [Route("/api/contact/getfriends")]
        public async Task<IActionResult> GetFriends()
        {
            int id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier).Value);
            return Json(await _contactManager.GetFriendsAsync(id));
        }

        [Authorize]
        [HttpGet]
        [Route("/api/contact/getchats")]
        public async Task<IActionResult> GetChats()
        {
            int Id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            return Json(_contactManager.GetChats(Id));
        }

        [Authorize]
        [HttpPost]
        [Route("/api/contact/getchat")]
        public async Task<IActionResult> GetChat([FromBody] GetChatRequest chatReq)
        {
            int id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            return Json(await _contactManager.GetChat(id, chatReq.ChatId, chatReq.SkipCount));
        }


        [Authorize]
        [HttpPost]
        [Route("/api/contact/creategroup")]
        public async Task<IActionResult> CreateGroup([FromBody] CreateGroupCommand createGroupCmd)
        {
            return Json(await _contactManager.InsertGroupAsync(createGroupCmd.ContactsIds, createGroupCmd.Title));
        }
    }
}

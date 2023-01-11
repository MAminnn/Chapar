using Core.Entities;
using Core.ViewModels;
using System.Collections.Generic;
using System.Threading.Tasks;
using Core.DTOs;

namespace Core.Interfaces
{
    public interface IContactManager
    {
        Task<bool> InsertContactAsync(Contact contact);
        Task<bool> SendFriendRequestAsync(FriendRequestViewModel friendRequest, int requestSenderId);
        Task<FriendRequestResponse> GetFriendRequestsAsync(int userId);
        Task<bool> AcceptFriendRequestAsync(int friendRequestId, int accepterId);
        Task<bool> DenideFriendRequestAsync(int friendRequestId, int accepterId);
        Task<Contact> GetContactByUserAsync(int UserId);
        Task<List<FriendDTO>> GetFriendsAsync(int userId);
        List<ChatsResponse> GetChats(int userId);
        Task<ChatResponse> GetChat(int userId, int chatId,int skipCount);
        Task<Chat> GetChatById(int chatId);
        Task<ChatsResponse> InsertGroupAsync(List<int> contactsIds, string title);
    }
}

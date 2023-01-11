using Core.Interfaces;
using System;
using Infrastructure.Persistence.Context;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Core.Entities;
using Core.ViewModels;
using Microsoft.EntityFrameworkCore;
using AutoMapper;
using Core.DTOs;

namespace Infrastructure.Services.ContactManagement
{
    internal class ContactManager : IContactManager
    {
        private AppDbContext _context;
        private IMapper _mapper;
        public ContactManager(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }
        public async Task<bool> InsertContactAsync(Contact contact)
        {
            try
            {
                if (!_context.Contacts.Any(c => c.Username == contact.Username))
                {
                    await _context.Contacts.AddAsync(contact);
                    await _context.SaveChangesAsync();
                }
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
        public async Task<bool> SendFriendRequestAsync(FriendRequestViewModel friendRequestViewModel, int requesterId)
        {
            try
            {
                var senderContact = (await _context.Contacts.Include(c => c.ReceivedFriendRequests).SingleOrDefaultAsync(c => c.UserId == requesterId));
                var receiverContact = await _context.Contacts.Include(c => c.ReceivedFriendRequests).SingleOrDefaultAsync(c => c.Username == friendRequestViewModel.FriendUsername);
                if (senderContact == null || receiverContact == null) return false;
                if (senderContact == receiverContact)
                {
                    return false;
                }
                if (senderContact.Friends.Contains(new Friend() { Contact = senderContact, ContactId = senderContact.Id, FriendContactId = receiverContact.Id, FriendUsername = receiverContact.Username }))
                {
                    return false;
                }
                if (senderContact.ReceivedFriendRequests.Exists(fr => fr.FromContact == receiverContact))
                {
                    FriendRequest fr = senderContact.ReceivedFriendRequests.SingleOrDefault(fr => fr.FromContact == receiverContact);
                    fr.FromContact.Friends.Add(new Friend()
                    {
                        Contact = fr.FromContact,
                        FriendUsername = fr.ToContact!.Username,
                        FriendContactId = fr.ToContact.Id
                    });
                    fr.ToContact.Friends.Add(new Friend()
                    {
                        Contact = fr.ToContact,
                        FriendUsername = fr.FromContact.Username,
                        FriendContactId = fr.FromContact.Id

                    });
                    _context.Update(fr.ToContact);
                    _context.Update(fr.FromContact);
                    _context.Remove(fr);
                    await _context.SaveChangesAsync();
                    return true;
                };
                FriendRequest existsFriendRequest = receiverContact.ReceivedFriendRequests.SingleOrDefault(r => r.FromContact == senderContact);
                if (existsFriendRequest != null)
                {
                    _context.Remove(existsFriendRequest);
                }
                FriendRequest friendRequest = new FriendRequest()
                {
                    FromContact = senderContact,
                    FromContactId = senderContact.Id,
                    ToContactId = receiverContact.Id,
                    ToContact = receiverContact,
                    Text = friendRequestViewModel.RequestMessage
                };
                await _context.AddAsync(friendRequest);
                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception)
            {
                return false;
            }

        }
        public async Task<FriendRequestResponse> GetFriendRequestsAsync(int userId)
        {
            try
            {
                var contact = await _context.Set<Contact>().Include(c => c.SentFriendRequests).ThenInclude(fr => fr.ToContact).Include(c => c.ReceivedFriendRequests).ThenInclude(fr => fr.FromContact).SingleOrDefaultAsync(c => c.UserId == userId);
                FriendRequestResponse res = new FriendRequestResponse()
                {
                    ReceivedFriendRequests = new List<ReceivedFriendRequestViewModel>(),
                };
                foreach (var fr in contact.ReceivedFriendRequests)
                {
                    res.ReceivedFriendRequests.Add(_mapper.Map<ReceivedFriendRequestViewModel>(fr));
                }
                return res;
            }
            catch (Exception e)
            {
                return null;
            }
        }
        public async Task<bool> AcceptFriendRequestAsync(int friendRequestId, int accepterId)
        {
            try
            {
                var friendRequest = await _context.FriendRequests.Include(fr => fr.FromContact).Include(fr => fr.ToContact).SingleOrDefaultAsync(fr => fr.Id == friendRequestId);
                if (accepterId != friendRequest.ToContact.UserId)
                {
                    return false;
                }
                friendRequest.FromContact.Friends.Add(new Friend()
                {
                    Contact = friendRequest.FromContact,
                    FriendUsername = friendRequest.ToContact.Username,
                    FriendContactId = friendRequest.ToContact.Id
                });
                friendRequest.ToContact.Friends.Add(new Friend()
                {
                    Contact = friendRequest.ToContact,
                    FriendUsername = friendRequest.FromContact.Username,
                    FriendContactId = friendRequest.FromContact.Id

                });
                _context.UpdateRange(friendRequest.ToContact, friendRequest.FromContact);
                await _context.SaveChangesAsync();
                Chat chat = new Chat()
                {
                    Contacts = new List<Contact>()
                    {

                    },
                };

                await _context.AddAsync(new ChatContact() { Seen = false, ContactId = friendRequest.FromContactId, ChatTitle = friendRequest.ToContact.Username, Chat = chat });
                await _context.AddAsync(new ChatContact() { Seen = false, ContactId = friendRequest.ToContactId.Value, ChatTitle = friendRequest.FromContact.Username, Chat = chat });
                _context.Remove(friendRequest);
                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
        public async Task<bool> DenideFriendRequestAsync(int friendRequestId, int accepterId)
        {
            try
            {
                var friendRequest = await _context.FriendRequests.Include(fr => fr.FromContact).Include(fr => fr.ToContact).SingleOrDefaultAsync(fr => fr.Id == friendRequestId);
                if (friendRequest.ToContact.UserId == accepterId)
                {
                    _context.Remove(friendRequest);
                    await _context.SaveChangesAsync();
                    return true;
                }
                return false;
            }
            catch (Exception)
            {
                return false;
            }
        }
        public async Task<Contact> GetContactByUserAsync(int UserId)
        {
            try
            {
                return await _context.Contacts.SingleOrDefaultAsync(c => c.UserId == UserId);
            }
            catch (Exception e)
            {
                return null;
            }
        }

        public async Task<List<FriendDTO>> GetFriendsAsync(int userId)
        {
            try
            {
                Contact contact = await _context.Contacts.Include(c=>c.Friends).SingleOrDefaultAsync(c => c.UserId == userId);
                return _mapper.Map<List<FriendDTO>>(contact.Friends);
            }
            catch
            {
                return null;
            }
        }
        public List<ChatsResponse> GetChats(int userId)
        {
            try
            {
                var contactsChat = _context.ChatContacts.Include(c => c.Chat).ThenInclude(c => c.Messages).Include(c=>c.Chat).ThenInclude(c=>c.Contacts).Where(c => c.Contact.UserId == userId).ToList();
                var res = _mapper.Map<List<ChatsResponse>>(contactsChat);
                return res;
            }
            catch
            {
                return null;
            }
        }

        public async Task<ChatResponse> GetChat(int userId, int chatId, int skipCount)
        {
            try
            {
                Chat chat = await GetChatById(chatId);
                Contact contact = await GetContactByUserAsync(userId);
                if (!chat.Contacts.Exists(c => c == contact))
                {
                    return null;
                }
                var res = new ChatResponse()
                {
                    Messages = _mapper.Map<List<SimpleMessage>>(chat.Messages.OrderBy(c => c.SentDate).SkipLast(skipCount).TakeLast(20).ToList()),
                    Contacts = _mapper.Map<List<SimpleContact>>(chat.Contacts),
                    AllMessagesCount = chat.Messages.Count
                };
                return res;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public async Task<Chat> GetChatById(int chatId)
        {
            return await _context.Chats.Include(c => c.Contacts).Include(c=>c.Messages).SingleOrDefaultAsync(c => c.Id == chatId);
        }

        public async Task<ChatsResponse> InsertGroupAsync(List<int> contactsIds, string title)
        {
            try
            {
                Chat chat = new Chat();
                var contacts = contactsIds.ConvertAll<Contact>(c => _context.Contacts.Find(c));
                foreach (var contact in contacts)
                {
                    await _context.AddAsync(new ChatContact() { ContactId = contact.Id, ChatTitle = title, Chat = chat, Seen = false });
                }
                await _context.SaveChangesAsync();
                return new ChatsResponse()
                {
                    Seen = false,
                    ChatMembers = contacts.ConvertAll<string>(c=>c.Username),
                    ChatId = chat.Id,
                    Title = title
                };
            }
            catch (Exception)
            {

                return null;
            }
        }
    }
}

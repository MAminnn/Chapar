using System;
using Core.Entities;
using Core.Interfaces;
using Infrastructure.Persistence.Context;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Core.DTOs;

namespace Infrastructure.Services.ChatManagement
{
    public class ChatManager : IChatManager
    {
        private AppDbContext _context;

        public ChatManager(AppDbContext context)
        {
            _context = context;
        }

        public async Task<Message> InsertMessage(Message message)
        {
            try
            {
                await _context.AddAsync<Message>(message);
                await _context.SaveChangesAsync();
                return await _context.Messages.Include(m => m.Sender).Include(m => m.Chat).ThenInclude(c => c.Contacts).SingleOrDefaultAsync(m => m.Id == message.Id);
            }
            catch (Exception e)
            {
                return null;
            }
        }

        public async Task SeenChat(SeenCommand seenCommand)
        {
            try
            {
                var contactsChat = await _context.ChatContacts.SingleOrDefaultAsync(c => c.ContactId == seenCommand.ContactId && c.ChatId == seenCommand.ChatId);
                contactsChat.Seen = seenCommand.Seen;
                await _context.SaveChangesAsync();
            }
            catch (Exception e)
            {
                
            }
        }
    }
}

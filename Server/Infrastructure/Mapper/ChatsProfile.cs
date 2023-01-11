using AutoMapper;
using Core.DTOs;
using Core.Entities;
using System.Linq;

namespace Infrastructure.Mapper
{
    public class ChatsProfile : Profile
    {
        public ChatsProfile()
        {
            CreateMap<ChatContact, ChatsResponse>().ForMember(c => c.Title, cc => cc.MapFrom(c => c.ChatTitle)).ForMember(c => c.ChatId, c => c.MapFrom(ch => ch.ChatId)).ForMember(c => c.LastMessage, c => c.MapFrom(prop => new SimpleMessage()
            {
                ChatId = prop.LastMessage.ChatId,
                Id = prop.LastMessage.Id,
                IsDelivered = true,
                SenderId = prop.LastMessage.SenderId,
                SentDate = prop.LastMessage.SentDate,
                Text = prop.LastMessage.Text,
            })).ForMember(c => c.Seen, c => c.MapFrom(prop => prop.Seen)).ForMember(c => c.ChatMembers, c => c.MapFrom(prop => prop.Chat.Contacts.Select(c => c.Username)));

        }
    }
}

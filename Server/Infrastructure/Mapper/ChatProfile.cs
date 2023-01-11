using AutoMapper;
using Core.DTOs;
using Core.Entities;
using System.Linq;

namespace Infrastructure.Mapper
{
    public class ChatProfile : Profile
    {
        public ChatProfile()
        {
            CreateMap<Chat, ChatResponse>().ForMember(c => c.Messages, c => c.MapFrom(cr => cr.Messages.OrderBy(c => c.SentDate).TakeLast(20).Select(m => new SimpleMessage()
            {
                ChatId = m.ChatId,
                Id = m.Id,
                SenderId = m.SenderId,
                SentDate = m.SentDate,
                Text = m.Text,
                IsDelivered = true
            })));
        }
    }
}

using AutoMapper;
using Core.DTOs;
using Core.Entities;

namespace Infrastructure.Mapper
{
    public class SimpleMessageProfile : Profile
    {
        public SimpleMessageProfile()
        {
            CreateMap<Message, SimpleMessage>().ForMember(m => m.Id, sm => sm.MapFrom(prop => prop.Id))
                .ForMember(m => m.IsDelivered, sm => sm.MapFrom(prop => true))
            .ForMember(m => m.SentDate, sm => sm.MapFrom(prop => prop.SentDate))
            .ForMember(m => m.SenderId, sm => sm.MapFrom(prop => prop.SenderId))
            .ForMember(m => m.ChatId, sm => sm.MapFrom(prop => prop.ChatId))
            .ForMember(m => m.Text, sm => sm.MapFrom(prop => prop.Text));
        }
    }
}

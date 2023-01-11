using AutoMapper;
using Core.DTOs;
using Core.Entities;

namespace Infrastructure.Mapper
{
    public class SimpleContactProfile:Profile
    {
        public SimpleContactProfile()
        {
            CreateMap<Contact, SimpleContact>().ForMember(c=>c.Username,sc=>sc.MapFrom(c=>c.Username)).ForMember(c=>c.Id,sc=>sc.MapFrom(c=>c.Id)) ;
        }
    }
}

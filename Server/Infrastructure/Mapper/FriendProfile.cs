using AutoMapper;
using Core.Entities;
using Core.DTOs;
namespace Infrastructure.Mapper
{
    public class FriendProfile:Profile
    {
        public FriendProfile()
        {
            CreateMap<Friend, FriendDTO>().ForMember(c => c.Id, f => f.MapFrom(c => c.FriendContactId))
                .ForMember(c => c.Username, f => f.MapFrom(c => c.FriendUsername));
        }
    }
}

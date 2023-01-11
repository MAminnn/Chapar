using AutoMapper;
using Core.Entities;
using Core.ViewModels;

namespace Infrastructure.Mapper
{
    public class ReceivedFriendRequestProfile : Profile
    {
        public ReceivedFriendRequestProfile()
        {
            CreateMap<FriendRequest, ReceivedFriendRequestViewModel>()
                .ForMember(f => f.Id, f => f.MapFrom(fr => fr.Id)).ForMember(f => f.FromContactUsername, f => f.MapFrom(fr => fr.FromContact.Username))
                .ForMember(f => f.FromContactId, f => f.MapFrom(fr => fr.FromContactId)).ForMember(f => f.Text, f => f.MapFrom(fr => fr.Text));
        }
    }
}

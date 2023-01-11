using Core.DTOs;
using Core.Entities;
using System.Threading.Tasks;

namespace Core.Interfaces
{
    public interface IChatManager
    {
        Task<Message> InsertMessage(Message message);
        public Task SeenChat(SeenCommand seenCommand);
    }
}

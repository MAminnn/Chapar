using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Core.ViewModels
{
    public class CreateGroupCommand
    {
        public List<int> ContactsIds { get; set; }
        [MaxLength(30)]
        public string Title { get; set; }
    }
}

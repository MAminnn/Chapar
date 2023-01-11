using Microsoft.AspNetCore.Mvc;
using System;
using System.Net.WebSockets;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using ProtoBuf;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Core.DTOs;
using Core.Interfaces;

namespace MessengerAPI.Controllers
{
    public class ChatController : Controller
    {
        private IContactManager _contactManager;
        private IChatManager _chatManager;


        public ChatController(IContactManager contactManager, IChatManager chatManager)
        {
            _contactManager = contactManager;
            _chatManager = chatManager;
        }
        private static List<Tuple<(int, int), WebSocket, string>> _chatWS = new();
        private static List<Tuple<int, WebSocket, string>> _chatsListWS = new();
        [Route("/chat/EnterRoom")]
        [HttpGet]
        [Authorize]
        public async Task EnterRoom()
        {
            int id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier).Value);
            int chatId = int.Parse(HttpContext.Request.Headers["chatid"]);
            string refToken = HttpContext.Request.Headers["Authorization"];
            try
            {
                using (var client = await HttpContext.WebSockets.AcceptWebSocketAsync())
                {
                    _chatWS.Add(new Tuple<(int, int), WebSocket, string>((id, chatId), client, refToken));

                    while (client.State == WebSocketState.Open)
                    {
                        using (var memoryStream = new MemoryStream())
                        {
                            byte[] buffer = new byte[1024 * 4];
                            WebSocketReceiveResult receiveResult = await client.ReceiveAsync(
                                buffer, CancellationToken.None);
                            if (receiveResult.MessageType == WebSocketMessageType.Close)
                            {
                                _chatWS.Remove(_chatWS.SingleOrDefault(s => s.Item1 == (id, chatId)));
                                continue;
                            }
                            var msg = Serializer.Deserialize<Message>(new MemoryStream(buffer, 0, receiveResult.Count));
                            var newMsg = await _chatManager.InsertMessage(new Core.Entities.Message()
                            {
                                ChatId = int.Parse(msg.ChatId),
                                SenderId = int.Parse(msg.SenderId),
                                SentDate = DateTime.Now,
                                Text = msg.Text,
                            });


                            foreach (var contact in newMsg.Chat.Contacts)
                            {
                                if (_chatWS.Any(s => s.Item1 == (contact.UserId, newMsg.ChatId)))
                                {
                                    foreach (var contactSocket in _chatWS.Where(s => s.Item1 == (contact.UserId, newMsg.ChatId)))
                                    {

                                        Serializer.Serialize<Message>(memoryStream, new Message()
                                        {

                                            ChatId = newMsg.ChatId.ToString(),
                                            Id = newMsg.Id.ToString(),
                                            SenderId = newMsg.SenderId.ToString(),
                                            SentDate = newMsg.SentDate.ToString("yyyy-MM-dd HH:mm:ss.FFFFFFF"),
                                            Text = msg.Text
                                        });
                                        memoryStream.Capacity = int.Parse(memoryStream.Length.ToString());
                                        await contactSocket.Item2.SendAsync(memoryStream.ToArray(), WebSocketMessageType.Binary, true, CancellationToken.None);
                                    }
                                }
                                else if (_chatsListWS.Any(s => s.Item1 == contact.UserId))
                                {
                                    foreach (var socket in _chatsListWS.Where(s => s.Item1 == contact.UserId))
                                    {
                                        Serializer.Serialize<Message>(memoryStream, new Message()
                                        {

                                            ChatId = newMsg.ChatId.ToString(),
                                            Id = newMsg.Id.ToString(),
                                            SenderId = newMsg.SenderId.ToString(),
                                            SentDate = newMsg.SentDate.ToString("yyyy-MM-dd HH:mm:ss.FFFFFFF"),
                                            Text = msg.Text
                                        });
                                        memoryStream.Capacity = int.Parse(memoryStream.Length.ToString());
                                        await socket.Item2.SendAsync(memoryStream.ToArray(), WebSocketMessageType.Binary, true, CancellationToken.None);
                                        await _chatManager.SeenChat(new SeenCommand()
                                        {
                                            ChatId = newMsg.ChatId,
                                            ContactId = contact.Id,
                                            Seen = false
                                        });
                                    }
                                }
                                else
                                {
                                    await _chatManager.SeenChat(new Core.DTOs.SeenCommand()
                                    {
                                        ChatId = newMsg.ChatId,
                                        ContactId = contact.Id,
                                        Seen = false
                                    });
                                }

                            }

                        }
                    }
                }
            }
            catch
            {
                refToken = HttpContext.Request.Headers["Authorization"];
                _chatWS.Remove(_chatWS.SingleOrDefault(s => s.Item3 == refToken));
            }
        }
        [Route("/chat/Connect")]
        [HttpGet]
        [Authorize]
        public async Task Connect()
        {
            string refToken = HttpContext.Request.Headers["Authorization"];
            int id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier).Value);
            try
            {
                using (var client = await HttpContext.WebSockets.AcceptWebSocketAsync())
                {
                    _chatsListWS.Add(new Tuple<int, WebSocket, string>(id, client, refToken));

                    while (client.State == WebSocketState.Open)
                    {
                        using (var memoryStream = new MemoryStream())
                        {
                            byte[] buffer = new byte[1024 * 4];
                            WebSocketReceiveResult receiveResult = await client.ReceiveAsync(
                                buffer, CancellationToken.None);
                            refToken = HttpContext.Request.Headers["Authorization"];
                            if (receiveResult.MessageType == WebSocketMessageType.Close)
                            {
                                _chatsListWS.Remove(_chatsListWS.SingleOrDefault(s => s.Item3 == refToken));
                                continue;
                            }
                        }
                    }
                }
            }
            catch
            {
                _chatsListWS.Remove(_chatsListWS.SingleOrDefault(s => s.Item3 == refToken));
            }
        }



        [Authorize]
        [HttpGet]
        [Route("/api/chat/seen/{contactChatId}/{contactId}/{seen}")]
        public async Task Seen([FromRoute] int contactChatId, [FromRoute] int contactId, [FromRoute] bool seen)
        {
            int Id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier).Value);
            if ((await _contactManager.GetContactByUserAsync(Id)).Id != contactId)
            {
                return;
            }
            await _chatManager.SeenChat(new Core.DTOs.SeenCommand()
            {
                ChatId = contactChatId,
                ContactId = contactId,
                Seen = seen
            });
        }
    }
    [ProtoContract]
    internal class Message
    {
        [ProtoMember(1)]
        public string Id { get; set; }
        [ProtoMember(2)]
        public string Text { get; set; }
        [ProtoMember(3)]
        public string SentDate { get; set; }
        [ProtoMember(4)]
        public string ChatId { get; set; }
        [ProtoMember(5)]
        public string SenderId { get; set; }
    }
}

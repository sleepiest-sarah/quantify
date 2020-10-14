quantify_chat = {}

local q = quantify
local qc = quantify_chat

quantify_chat.MODULE_KEY = "chat"

quantify_chat.CHANNEL_CHAT_PREFIX = "channel_sent_*"

qc.keys = {
  WHISPERS_SENT_TO = "chat/data/whispers_sent_to/",
  WHISPERS_RECEIVED_FROM = "chat/data/whispers_received_from/",
  CHANNEL_SENT = "chat/stats/channels/",
  EMOTES_USED = "chat/data/emotes/"
}
local keys = qc.keys

local function chatMsgWhisper(event, ...)
  local msg, author,_,_,recipient,_, _, _, _, _, _, _, bnSenderID = unpack({...})
  
  --check if author/recipient is actually a BN account string
  recipient = q:getBnAccountNameFromChatString(recipient) or recipient
  author = q:getBnAccountNameFromChatString(author) or author
  
  local _,bn_account_name = BNGetInfo()
  
  --pretty sure the inform events only fire for battle.net messages you send and don't include anything about the author. Both the author field and bnSenderId refer to the recepient
  if (event == "CHAT_MSG_BN_WHISPER_INFORM") then
    recipient = author
    author = bn_account_name
  end
  
  if (author == quantify_state:getPlayerNameRealm() or author == bn_account_name or BNIsSelf(bnSenderID)) then
    q:incrementStatByPath(keys.WHISPERS_SENT_TO..recipient,1)
    q:incrementStat("WHISPERS_SENT",1)
  else
    q:incrementStatByPath(keys.WHISPERS_RECEIVED_FROM..recipient,1)
    q:incrementStat("WHISPERS_RECEIVED",1)
  end  
end

local function chatMsgChannel(event, ...)
  local msg, author,_,_,_,_,_,channel_index,channel_name = unpack({...}) 
   
  if (author == quantify_state:getPlayerNameRealm()) then
    q:incrementStatByPath(keys.CHANNEL_SENT..channel_name,1)
  end
end

local function chatMsgGuild(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    q:incrementStat("GUILD_SENT", 1)
  end
end

local function chatMsgParty(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    q:incrementStat("PARTY_SENT",1)
  end 
end

local function chatMsgRaid(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    q:incrementStat("RAID_SENT",1)
  end
end

local function chatMsgYell(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    q:incrementStat("YELL_SENT",1)
  end
end

local function chatMsgSay(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    q:incrementStat("SAY_SENT",1)
  end  
end

local function chatMsgEmote(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    q:incrementStatByPath(keys.EMOTES_USED..msg,1)
    q:incrementStat("EMOTES_SENT",1)
  end    
end

local function chatMsg(event, ...)
  local msg, author = unpack({...})
  
  local player = quantify_state:getPlayerNameRealm()
  local player_no_realm = quantify_state:getPlayerName()

  if (author == player or event == "CHAT_MSG_BN_WHISPER_INFORM") then
    if (quantify_state:isPlayerInCombat()) then
      q:incrementStat("COMBAT_MESSAGES",1)
    end
  end
  
  for word in string.gmatch(msg, "([^%s]+)") do
    word = string.lower(word)
    word = string.gsub(word, "(%p+)$", "") --strip any punctuation at the end of the word
    word = string.gsub(word, "^(%p+)", "") --or beginning
  
    if (string.lower(word) == string.lower(player_no_realm)) then 
      q:incrementStat("MENTIONS",1)
      break
    end
  end

end

function quantify_chat:calculateDerivedStats(segment)
  
  if (q:length(segment.data.whispers_sent_to) > 0) then
    local bff_sent = q:getKeyForMaxValue(segment.data.whispers_sent_to)
    segment.stats.bff_sent = bff_sent
  end
  
  if (q:length(segment.data.whispers_received_from) > 0) then
    local bff_received = q:getKeyForMaxValue(segment.data.whispers_received_from)
    segment.stats.bff_received = bff_received
  end
   
end

function quantify_chat:updateStats(segment)
  quantify_chat:calculateDerivedStats(segment)
end
 
function quantify_chat:newSegment(segment)
  segment.data = segment.data or {}
  segment.data.emotes = segment.data.emotes or {}
  segment.data.whispers_sent_to = segment.data.whispers_sent_to or {}
  segment.data.whispers_received_from = segment.data.whispers_received_from or {}
  
  segment.stats = segment.stats or 
              {combat_messages = 0,
              whispers_sent = 0, 
              whispers_received = 0,
              party_sent = 0,
              say_sent = 0,
              guild_sent = 0,
              yell_sent = 0,
              emotes_sent = 0,
              raid_sent = 0,
              mentions = 0}
end

table.insert(quantify.modules, quantify_chat)

quantify:registerEvent("CHAT_MSG_BN_WHISPER", chatMsgWhisper)
quantify:registerEvent("CHAT_MSG_BN", chatMsgWhisper)
quantify:registerEvent("CHAT_MSG_BN_WHISPER_INFORM", chatMsgWhisper)
quantify:registerEvent("CHAT_MSG_CHANNEL", chatMsgChannel)
quantify:registerEvent("CHAT_MSG_OFFICER", chatMsgGuild)
quantify:registerEvent("CHAT_MSG_GUILD", chatMsgGuild)
quantify:registerEvent("CHAT_MSG_PARTY", chatMsgParty)
quantify:registerEvent("CHAT_MSG_PARTY_LEADER", chatMsgParty)
quantify:registerEvent("CHAT_MSG_RAID", chatMsgRaid)
quantify:registerEvent("CHAT_MSG_RAID_LEADER", chatMsgRaid)
quantify:registerEvent("CHAT_MSG_RAID_WARNING", chatMsgRaid)
quantify:registerEvent("CHAT_MSG_SAY", chatMsgSay)
quantify:registerEvent("CHAT_MSG_TEXT_EMOTE", chatMsgEmote)
quantify:registerEvent("CHAT_MSG_EMOTE", chatMsgEmote)
quantify:registerEvent("CHAT_MSG_WHISPER", chatMsgWhisper)
quantify:registerEvent("CHAT_MSG_YELL", chatMsgYell)

quantify:registerEvent("CHAT_MSG_BN_WHISPER", chatMsg)
quantify:registerEvent("CHAT_MSG_BN", chatMsg)
quantify:registerEvent("CHAT_MSG_BN_WHISPER_INFORM", chatMsg)
quantify:registerEvent("CHAT_MSG_CHANNEL", chatMsg)
quantify:registerEvent("CHAT_MSG_OFFICER", chatMsg)
quantify:registerEvent("CHAT_MSG_GUILD", chatMsg)
quantify:registerEvent("CHAT_MSG_PARTY", chatMsg)
quantify:registerEvent("CHAT_MSG_PARTY_LEADER", chatMsg)
quantify:registerEvent("CHAT_MSG_SAY", chatMsg)
quantify:registerEvent("CHAT_MSG_RAID_LEADER", chatMsg)
quantify:registerEvent("CHAT_MSG_RAID_WARNING", chatMsg)
quantify:registerEvent("CHAT_MSG_RAID", chatMsg)
quantify:registerEvent("CHAT_MSG_WHISPER", chatMsg)
quantify:registerEvent("CHAT_MSG_YELL", chatMsg)
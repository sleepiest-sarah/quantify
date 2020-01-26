quantify_chat = {}

local q = quantify

quantify_chat.Session = {}

quantify_chat.MODULE_KEY = "chat"

quantify_chat.CHANNEL_CHAT_PREFIX = "channel_sent_*"
quantify_chat.WORD_CLOUD_PREFIX = "word_cloud_*"
quantify_chat.MAX_CLOUD_WORDS_DISPLAY = 10

quantify_chat.MAX_CLOUD_WORDS_STORE = 200
quantify_chat.ABSOLUTE_MAX_CLOUD_WORDS_STORE = 500
quantify_chat.CLOUD_WORDS_AGE_OFF_SECONDS = 604800

quantify_chat.WORD_CLOUD_TIMESTAMP_KEY = "word_cloud_timestamps"

quantify_chat.filtered_words = {"a", "the", "and", "of", "in", "it", "for", "ok", "i", "i'm", "no", "yea", "yes", "to", "on", "an", "or", "you","is","was",
                                "could", "did", "they", "are", "doing", "from", "have", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "is", "do", "there", "too", "that", "if", "be",
                                "would", "get", "can", "while"}

function quantify_chat.Session:new(o)
  o = o or {word_cloud = {}, combat_messages = 0, whispers_sent = 0, whispers_received = 0, whispers_received_from = {}, whispers_sent_to = {}, party_sent = 0, say_sent = 0, guild_sent = 0, yell_sent = 0, emotes_sent = 0, emotes_used = {}, raid_sent = 0, mentions = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local function init()
  q.current_segment.stats.chat = {}
  q.current_segment.stats.chat.raw = quantify_chat.Session:new()
  q.current_segment.stats.chat.derived_stats = { }
  session = q.current_segment.stats.chat.raw
  
  local filtered = {}
  for _,w in ipairs(quantify_chat.filtered_words) do
    filtered[w] = w
  end
  quantify_chat.filtered_words = filtered
end

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
    if (session.whispers_sent_to[recipient] == nil) then
      session.whispers_sent_to[recipient] = 0
    end
    
    session.whispers_sent_to[recipient] = session.whispers_sent_to[recipient] + 1
    session.whispers_sent = session.whispers_sent + 1
  else
    if (session.whispers_received_from[author] == nil) then
      session.whispers_received_from[author] = 0
    end
    
    session.whispers_received_from[author] = session.whispers_received_from[author] + 1
    session.whispers_received = session.whispers_received + 1
  end  
end

local function chatMsgChannel(event, ...)
  local msg, author,_,_,_,_,_,channel_index,channel_name = unpack({...}) 
   
  if (author == quantify_state:getPlayerNameRealm()) then
    if (session[quantify_chat.CHANNEL_CHAT_PREFIX..channel_name] == nil) then
      session[quantify_chat.CHANNEL_CHAT_PREFIX..channel_name] = 0
    end
    
    session[quantify_chat.CHANNEL_CHAT_PREFIX..channel_name] = session[quantify_chat.CHANNEL_CHAT_PREFIX..channel_name] + 1
  end
end

local function chatMsgGuild(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    session.guild_sent = session.guild_sent + 1
  end
end

local function chatMsgParty(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    session.party_sent = session.party_sent + 1
  end 
end

local function chatMsgRaid(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    session.raid_sent = session.raid_sent + 1
  end
end

local function chatMsgYell(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    session.yell_sent = session.yell_sent + 1
  end
end

local function chatMsgSay(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    session.say_sent = session.say_sent + 1
  end  
end

local function chatMsgEmote(event, ...)
  local msg, author = unpack({...})
  
  if (author == quantify_state:getPlayerNameRealm()) then
    if (session.emotes_used[msg] == nil) then
      session.emotes_used[msg] = 0
    end
    
    session.emotes_used[msg] = session.emotes_used[msg] + 1
    session.emotes_sent = session.emotes_used + 1
  end    
end

local function chatMsg(event, ...)
  local msg, author = unpack({...})
  
  local player = quantify_state:getPlayerNameRealm()
  local player_no_realm = quantify_state:getPlayerName()
  for word in string.gmatch(msg, "([^%s]+)") do
    word = string.lower(word)
    word = string.gsub(word, "(%p+)$", "") --strip any punctuation at the end of the word
    word = string.gsub(word, "^(%p+)", "") --or beginning
    if (quantify_chat.filtered_words[word] == nil) then
      if (author == player or event == "CHAT_MSG_BN_WHISPER_INFORM") then
        if (session.word_cloud[word] == nil) then
          session.word_cloud[word] = 0
        end
        session.word_cloud[word] = session.word_cloud[word] + 1
        
        local word_cloud_timestamps = q:getData(quantify_chat.WORD_CLOUD_TIMESTAMP_KEY)
        if (not word_cloud_timestamps) then
          word_cloud_timestamps = {}
        end
        word_cloud_timestamps[word] = time()
        q:storeData(quantify_chat.WORD_CLOUD_TIMESTAMP_KEY, word_cloud_timestamps)
        
        if (quantify_state:isPlayerInCombat()) then
          session.combat_messages = session.combat_messages + 1
        end
      elseif (string.lower(word) == string.lower(player_no_realm)) then
        session.mentions = session.mentions + 1
      end
    end
  end

end

--prob need to optimize this
--either don't sort every loop or truncate the table based on counts as you insert keys
local function sortWordCloud(cloud)
  local cloud_keys = {}
  table.foreach(cloud, function(k,v) table.insert(cloud_keys,k); end)
  table.sort(cloud_keys,function(a,b) return cloud[a] > cloud[b] end)
  
  return cloud_keys
end

function quantify_chat:calculateDerivedStats(segment)
  --segment.stats.chat.session_rates = quantify:calculateSegmentRates(segment, segment.stats.chat.raw)
  
  local derived_stats = {}
  local sorted_keys = sortWordCloud(segment.stats.chat.raw.word_cloud)
  for i=1,quantify_chat.MAX_CLOUD_WORDS_DISPLAY do
    if (sorted_keys[i] ~= nil) then
      derived_stats[quantify_chat.WORD_CLOUD_PREFIX..sorted_keys[i]] = segment.stats.chat.raw.word_cloud[sorted_keys[i]]
    end
  end
  
  if (q:length(segment.stats.chat.raw.whispers_sent_to) > 0) then
    local bff_sent = q:getKeyForMaxValue(segment.stats.chat.raw.whispers_sent_to)
    derived_stats.bff_sent = bff_sent
  end
  
  if (q:length(segment.stats.chat.raw.whispers_received_from) > 0) then
    local bff_received = q:getKeyForMaxValue(segment.stats.chat.raw.whispers_received_from)
    derived_stats.bff_received = bff_received
  end
   
  segment.stats.chat.derived_stats = derived_stats
end

function quantify_chat:updateStats(segment)
  quantify_chat:calculateDerivedStats(segment)
end
 
function quantify_chat:newSegment(previous_seg,new_seg)
  
  init()
  
end

function quantify_chat:cleanWordCloud(wordcloud)
  local sorted_keys = sortWordCloud(wordcloud)
  local cloud_timestamps = q:getData(quantify_chat.WORD_CLOUD_TIMESTAMP_KEY)
  
  if (#sorted_keys > quantify_chat.MAX_CLOUD_WORDS_STORE and cloud_timestamps) then
    
    local cur = time()
    
    for i=quantify_chat.MAX_CLOUD_WORDS_STORE,#sorted_keys do
      if (sorted_keys[i] ~= nil and ((cur - (cloud_timestamps[sorted_keys[i]] or 0) > quantify_chat.CLOUD_WORDS_AGE_OFF_SECONDS) or (i > quantify_chat.ABSOLUTE_MAX_CLOUD_WORDS_STORE))) then
        wordcloud[sorted_keys[i]] = nil
        cloud_timestamps[sorted_keys[i]] = nil
      end
    end
  end
  
  for i=1,#sorted_keys do
    if (sorted_keys[i] ~= nil and quantify_chat.filtered_words[sorted_keys[i]]) then
      wordcloud[sorted_keys[i]] = nil
      cloud_timestamps[sorted_keys[i]] = nil
    end
  end
end

init()

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
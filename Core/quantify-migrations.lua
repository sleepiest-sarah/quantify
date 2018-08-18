local q = quantify


local function correctBnAccountNames()
  if (true) then
    for seg_k,seg in pairs(qDb) do
      local new_whispers_stat = {}
      if (type(seg) == "table" and seg.stats ~= nil and seg.stats.chat ~= nil and seg.stats.chat.whispers_received_from ~= nil) then
        for player,v in pairs(seg.stats.chat.whispers_received_from) do
          local id = string.match(player, "|K[gsf]([0-9]+)|")
          if (id == nil) then
            new_whispers_stat[player] = v
          else
            local _,_,bnname = BNGetFriendInfoByID(id)
            new_whispers_stat[bnname] = v
          end
        end
        seg.stats.chat.whispers_received_from = new_whispers_stat
      end
    end
  end
end

function q:runMigrations()
  correctBnAccountNames()
end
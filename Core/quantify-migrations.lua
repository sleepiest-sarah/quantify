local q = quantify


local function correctBnAccountNames()
  for seg_k,seg in pairs(qDb) do
    local new_whispers_stat = {}
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats.chat ~= nil and seg.stats.chat.whispers_received_from ~= nil) then
      for player,v in pairs(seg.stats.chat.whispers_received_from) do
        local id = string.match(player, "|K[gsf]([0-9]+)|")
        if (id == nil) then
          new_whispers_stat[player] = v
        else
          local _,_,bnname = BNGetFriendInfoByID(id)
          if (bnname) then					--friend could have been removed
            new_whispers_stat[bnname] = v
          end
        end
      end
      seg.stats.chat.whispers_received_from = new_whispers_stat
    end
  end
end

local function isPreReleaseVersion(v)
  return string.find(v, "alpha") or string.find(v, "beta")
end

function q:runMigrations()
  local installed_version = GetAddOnMetadata("quantify", "Version")
  
  --always run all migrations if the current version or data is an alpha or beta release
  if (qDbOptions.version == nil or installed_version == nil or isPreReleaseVersion(installed_version) or isPreReleaseVersion(installed_version) then
    correctBnAccountNames()
  elseif (qDbOptions.version < "1.0") then
    correctBnAccountNames()
  end
end
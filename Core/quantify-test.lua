local q = quantify

quantify_test = {}
local qTest = quantify_test

function qTest:PrintChallengeModeMaps()
  local IDs = C_ChallengeMode.GetMapTable()
  
  for i,id in ipairs(IDs) do
    q:printTable({C_ChallengeMode.GetMapUIInfo(id)})
  end
end

function qTest:segments()
  print(quantify:getStat(quantify.current_segment,quantify_instances.keys.DUNGEON))
end

function qTest:shadowlandsItems()
  --new expacId
  --also mop is missing from expacIds?
end

function qTest:insertTestParties()
  for seg_k,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats[quantify_instances.MODULE_KEY] ~= nil) then
      local instances = seg.stats[quantify_instances.MODULE_KEY]
      instances.data.parties = {["Jim-TANK|John-DAMAGER"] = {kills = 4, wipes = 2, player_deaths = 12, dungeons_completed = 1, 
                                    members = {["Jim"] = {name = "Jim", role = "TANK"},
                                               ["John"] = {name = "John", role = "DAMAGER"}}
                                      }}
    end
  end
end

function qTest:RunTestSuite()
  
end
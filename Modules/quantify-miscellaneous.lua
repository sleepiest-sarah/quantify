quantify_misc = {}

local q = quantify

quantify_misc.MODULE_KEY = "miscellaneous"

local function jump()
  if (quantify_state:CanPlayerJump()) then
    q:incrementStat("JUMPS",1)
  end
end

function quantify_misc:calculateDerivedStats(segment, fullSeg)
  
  local rates = quantify:calculateSegmentRates(fullSeg, segment.stats)
  segment.stats.jumps_rate = rates.jumps
end

function quantify_misc:updateStats(segment, fullSeg)
  quantify_misc:calculateDerivedStats(segment, fullSeg)
end
 
function quantify_misc:newSegment(segment)
  segment.stats = q:addKeysLeft(segment.stats, {jumps = 0})
end

table.insert(quantify.modules, quantify_misc)

q:hookSecureFunc("JumpOrAscendStart", jump)
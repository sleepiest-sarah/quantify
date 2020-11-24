quantify.STATS = {
  
  --chat
  WHISPERS_SENT = {text = "Whispers Sent", path = "chat/stats/whispers_sent", units = "integer"},
  SAY_SENT = {text = "Say Sent", path = "chat/stats/say_sent", units = "integer"},
  YELL_SENT = {text = "Yell Sent", path = "chat/stats/yell_sent", units = "integer"},
  PARTY_SENT = {text = "Party Sent", path = "chat/stats/party_sent", units = "integer"},
  RAID_SENT = {text = "Raid Sent", path = "chat/stats/raid_sent", units = "integer"},
  GUILD_SENT = {text = "Guild Sent", path = "chat/stats/guild_sent", units = "integer"},
  COMBAT_MESSAGES = {text = "Messages Sent While in Combat", path = "chat/stats/combat_messages", units = "integer"},
  MENTIONS = {text = "Times Mentioned", path = "chat/stats/mentions", units = "integer"},
  EMOTES_SENT = {text = "Emotes Used", path = "chat/stats/emotes_sent", units = "integer"},
  WHISPERS_RECEIVED = {text = "Whispers Received", path = "chat/stats/whispers_received", units = "integer"},
  CHANNEL_SENT = {text = "Channel Sent: *", path = "chat/stats/channels/*", units = "integer"},
  BFF_SENT = {text = "Top Recipient", path = "chat/stats/bff_sent", units = "string"},
  BFF_RECEIVED = {text = "Top Sender", path = "chat/stats/bff_received", units = "string"},  
  
  
  --combat
  KD_RATIO = {text = "Kill-to-Death Ratio", path = "combat/stats/kd_ratio", units = "decimal"},
  NUM_REZ_ACCEPTED = {text = "Rezes Accepted", path = "combat/stats/num_rez_accepted",  units = "integer"},
  NUM_SPIRIT_HEALER_REZ = {text = "Rezs by Spirit Healer", path = "combat/stats/num_spirit_healer_rez", units = "integer"},
  NUM_DEATHS = {text = "Deaths", path = "combat/stats/num_deaths", units = "integer"},
  NUM_BREZ_ACCEPTED = {text = "Battle Rezes Accepted", path = "combat/stats/num_brez_accepted", units = "integer"},
  NUM_CORPSE_RUNS = {text = "Corpse Runs", path = "combat/stats/num_corpse_runs", units = "integer"},
  TIME_CROWD_CONTROLLED = {text = "Time Spent CC'd", path = "combat/stats/time_crowd_controlled", units = "time"},
  PLAYER_ACTUAL_KILLS = {text = "Killing Blows", path = "combat/stats/player_actual_kills",  units = "integer"},
  PLAYER_KILLS = {text = "Total Kills", path = "combat/stats/player_kills", units = "integer"},
  
  --currency
  QUEST_MONEY = {text = "Money from Quests", path = "currency/stats/quest_money", abbr = "Quest Money", units = "money"},
  QUEST_MONEY_RATE = {text = "Quest Money Per Hour", path = "currency/stats/quest_money_rate", abbr = "QMpH", units = "money/hour"},
  AUCTION_MONEY = {text = "Money from Auction House", path = "currency/stats/auction_money", abbr = "AH Money", units = "money"},
  AUCTION_MONEY_SPENT = {text = "Money Spent at Auction House", path = "currency/stats/auction_money_spent", abbr = "AH Spent", units = "money"},
  AUCTION_MONEY_SPENT_RATE = {text = "Auction Money Spent Per Hour", path = "currency/stats/auction_money_spent_rate", abbr = "AH Spent/hr", units = "money/hour"},
  PCT_MONEY_QUEST = {text = "% Money Earned: Quest", path = "currency/stats/pct_money_quest", units = "percentage", order = 845},
  PCT_MONEY_AUCTION = {text = "% Money Earned: Auctions", path = "currency/stats/pct_money_auction", units = "percentage", order = 845},
  PCT_MONEY_LOOT = {text = "% Money Earned: Loot", path = "currency/stats/pct_money_loot", units = "percentage", order = 845},  
  VENDOR_MONEY = {text = "Money from Vendor Sales", path = "currency/stats/vendor_money", abbr = "Vendor Sales", units = "money"},
  VENDOR_MONEY_SPENT = {text = "Money Spent at Vendors", path = "currency/stats/vendor_money_spent", abbr = "Vendor Spent", units = "money"},
  VENDOR_MONEY_SPENT_RATE = {text = "Vendor Money Spent Per Hour", path = "currency/stats/vendor_money_spent_rate", abbr = "Vendor Spent/hr", units = "money/hour"},
  PCT_MONEY_VENDOR = {text = "% Money Earned: Vendor", path = "currency/stats/pct_money_vendor", units = "percentage", order = 845},
  MONEY_PICKPOCKETED = {text = "Money from Pick Pocketing", path = "currency/stats/money_pickpocketed", abbr = "Pick Pocketing", units = "money"},
  MONEY_PICKPOCKETED_RATE ={text = "Pick Pocketing Money Per Hour", path = "currency/stats/money_pickpocketed_rate", abbr = "PPpH", units = "money/hour"},
  REPAIR_MONEY = {text = "Money Spent on Repairs", path = "currency/stats/repair_money", units = "money"},
  REPAIR_MONEY_RATE ={text = "Money Spent on Repairs Per Hour", path = "currency/stats/repair_money_rate", abbr = "Hourly Repair Cost", units = "money/hour"},
  CURRENCY_GAINED = {text = "* Gained", path = "currency/data/currency/*/gained", units="integer"},
  DELTA_MONEY = {text = "Net Money Earned", path = "currency/stats/delta_money", units="money"},
  TOTAL_MONEY_GAINED = {text = "Money Earned", path = "currency/stats/total_money_gained", units="money"},
  TOTAL_MONEY_SPENT = {text = "Money Spent", path = "currency/stats/total_money_spent", units="money"},
  MONEY_LOOTED = {text = "Money Looted", path = "currency/stats/money_looted", units="money"},
  CURRENCY_GAINED_RATES = {text = "* Gained Per Hour", path = "currency/stats/currency_gained_rates/*", units="integer/hour"},
  DELTA_MONEY_RATE = {text = "Net Money Earned Per Hour", path = "currency/stats/delta_money_rate", units="money/hour"},
  TOTAL_MONEY_GAINED_RATE = {text = "Money Earned Per Hour", path = "currency/stats/total_money_gained_rate", units="money/hour"},
  TOTAL_MONEY_SPENT_RATE = {text = "Money Spent Per Hour", path = "currency/stats/total_money_spent_rate", units="money/hour"},
  MONEY_LOOTED_RATE = {text = "Money Looted Per Hour", path = "currency/stats/money_looted_rate", units="money/hour"},
  
  --instances
  BFA_TOTAL_DUNGEON_COMPLETED = {text = "Total BFA Dungeons Completed", path = "instances/stats/bfa_total_dungeon_completed", units = "integer", version="retail"},
  BFA_DUNGEON_BOSS_KILLS = {text = "BFA Dungeon Boss Kills", path = "instances/stats/bfa_dungeon_boss_kills", units = "integer", order = 200},
  BFA_DUNGEON_BOSS_WIPES = {text = "BFA Dungeon Boss Wipes", path = "instances/stats/bfa_dungeon_boss_wipes", units = "integer", order = 200},
  BFA_RAID_BOSS_KILLS = {text = "BFA Raid Boss Kills", path = "instances/stats/bfa_raid_boss_kills", units = "integer", order = 200},
  BFA_RAID_BOSS_WIPES = {text = "BFA Raid Boss Wipes", path = "instances/stats/bfa_raid_boss_wipes", units = "integer", order = 200},
  OVERALL_RAID_BOSS_KILLS = {text = "Raid Boss Kills", path = "instances/stats/overall_raid_boss_kills", units = "integer"},
  LEGION_DUNGEON_BOSS_KILLS = {text = "Legion Dungeon Boss Kills", path = "instances/stats/legion_dungeon_boss_kills", units = "integer"},
  OVERALL_DUNGEON_BOSS_KILLS = {text = "Dungeon Boss Kills", path = "instances/stats/overall_dungeon_boss_kills", units = "integer"},
  PLAYER_RAID_DEATHS = {text = "Players Deaths in Raids", path = "instances/stats/player_raid_deaths", units = "integer"},
  PLAYER_DUNGEON_DEATHS = {text = "Player Deaths in Dungeons", path = "instances/stats/player_dungeon_deaths", units = "integer"},
  LEGION_RAID_BOSS_KILLS = {text = "Legion Raid Boss Kills", path = "instances/stats/legion_raid_boss_kills", units = "integer"},
  LEGION_DUNGEON_BOSS_WIPES = {text = "Legion Dungeon Boss Wipes", path = "instances/stats/legion_dungeon_boss_wipes", units = "integer"},
  OVERALL_DUNGEON_BOSS_WIPES = {text = "Dungeon Boss Wipes", path = "instances/stats/overall_dungeon_boss_wipes", units = "integer"},
  OVERALL_RAID_BOSS_WIPES = {text = "Raid Boss Wipes", path = "instances/stats/overall_raid_boss_wipes", units = "integer"},
  LEGION_RAID_BOSS_WIPES = {text = "Legion Raid Boss Wipes", path = "instances/stats/legion_raid_boss_wipes", units = "integer"},
  
  --loot
  UPGRADES_RECEIVED = {text = "iLvl Upgrades: *", path = "loot/stats/upgrades_received/*", units = "integer", order = 150},
  UPGRADES_RECEIVED_RATES = {text = "iLvl Upgrades Per Day: *", path = "loot/stats/upgrades_received_rates/*", units = "decimal/hour", order = 160},
  OVERALL_ILEVEL_UPGRADES = {text = "Total iLvl Upgrades", path = "loot/stats/overall_ilevel_upgrades", units = "integer", order = 140},
  PCT_ARMOR_CLASS_LOOTED = {text = "Armor Class Looted: *", path = "loot/stats/pct_armor_class_looted/*", units = "percentage", order = 870},
  PCT_LOOT_QUALITY = {text = "* Loot", path = "loot/stats/pct_loot_quality/*", units = "percentage", order = 825},
  INV_TYPE_LOOTED = {text = "* Items Looted", path = "loot/stats/inv_type_looted/*", units = "integer", order = 900},
  JUNK_LOOTED_VALUE = {text = "Value of Junk Looted", path = "loot/stats/junk_looted_value", units = "money", order = 451},
  TOTAL_ITEMS_LOOTED = {text = "Total Items Looted", path = "loot/stats/total_items_looted", units = "integer", order = 150},
  GEAR_LOOT = {text = "Gear Looted", path = "loot/stats/gear_loot", units = "integer", order = 580},
  JUNK_LOOTED = {text = "Junk Items Looted", path = "loot/stats/junk_looted", units = "integer", order = 450},
  POOR_LOOT = {text = "Greys Looted", path = "loot/stats/poor_loot", units = "integer", order = 600},
  COMMON_LOOT = {text = "Common Items Looted", path = "loot/stats/common_loot", units = "integer", order = 601},
  UNCOMMON_LOOT = {text = "Greens Looted", path = "loot/stats/uncommon_loot", units = "integer", order = 602},
  RARE_LOOT = {text = "Blues Looted", path = "loot/stats/rare_loot", units = "integer", order = 603},
  EPIC_LOOT = {text = "Purples Looted", path = "loot/stats/epic_loot", units = "integer", order = 604},
  BFA_POOR_LOOT = {text = "BFA Greys Looted", path = "loot/stats/bfa_poor_loot", units = "integer", order = 590, version="retail"},
  BFA_COMMON_LOOT = {text = "BFA Common Items Looted", path = "loot/stats/bfa_common_loot", units = "integer", order = 591, version="retail"},
  BFA_UNCOMMON_LOOT = {text = "BFA Greens Looted", path = "loot/stats/bfa_uncommon_loot", units = "integer", order = 592, version="retail"},
  BFA_RARE_LOOT = {text = "BFA Blues Looted", path = "loot/stats/bfa_rare_loot", units = "integer", order = 593, version="retail"},
  BFA_EPIC_LOOT = {text = "BFA Purples Looted", path = "loot/stats/bfa_epic_loot", units = "integer", order = 594, version="retail"},
  CLOTH_GEAR_LOOT = {text = "Cloth Pieces Looted", path = "loot/stats/cloth_gear_loot", units = "integer", order = 750},
  LEATHER_GEAR_LOOT = {text = "Mail Pieces Looted", path = "loot/stats/leather_gear_loot", units = "integer", order = 751},
  MAIL_GEAR_LOOT = {text = "Mail Pieces Looted", path = "loot/stats/mail_gear_loot", units = "integer", order = 752},
  PLATE_GEAR_LOOT = {text = "Plate Gear Looted", path = "loot/stats/plate_gear_loot", units = "integer", order = 753},
  
   --misc
  JUMPS = {text = "Total Jumps", path = "miscellaneous/stats/jumps", units = "integer"},
  JUMPS_RATE = {text = "Jumps Per Hour", path = "miscellaneous/stats/jumps_rate", units = "integer/hour"},  
  
  --pet battles
  TOTAL_BATTLES = {text = "Total Pet Battles", path = "battlepets/stats/total_battles", units = "integer", version="retail"},
  TOTAL_WILD_BATTLES = {text = "Total Wild Pet Battles", path = "battlepets/stats/total_wild_battles", units = "integer", version="retail"},
  TOTAL_TRAINER_BATTLES = {text = "Total Trainer Pet Battles", path = "battlepets/stats/total_trainer_battles", units = "integer", version="retail"},
  TOTAL_BATTLE_WINS = {text = "Total Pet Battle Victories", path = "battlepets/stats/total_battle_wins", units = "integer", version="retail"},
  TOTAL_WILD_BATTLE_WINS = {text = "Total Wild Pet Battle Victories", path = "battlepets/stats/total_wild_battle_wins", units = "integer", version="retail"},
  TOTAL_TRAINER_BATTLE_WINS = {text = "Total Trainer Pet Battle Victories", path = "battlepets/stats/total_trainer_battle_wins", units = "integer", version="retail"},
  TOTAL_WILD_FORFEITS = {text = "Total Wild Pet Battle Forfeits", path = "battlepets/stats/total_wild_forfeits", units = "integer", version="retail"},
  TOTAL_TRAINER_FORFEITS = {text = "Total Trainer Pet Battle Forfeits", path = "battlepets/stats/total_trainer_forfeits", units = "integer", version="retail"}, 
  TOTAL_FORFEITS = {text = "Total Pet Battle Forfeits", path = "battlepets/stats/total_forfeits", units = "integer", version="retail"},
  PCT_BATTLE_WINS = {text = "% Pet Battle Victories", path = "battlepets/stats/pct_battle_wins", units = "percentage", version = "retail"},
  PCT_WILD_BATTLE_WINS = {text = "% Wild Pet Battle Victories", path = "battlepets/stats/pct_wild_battle_wins", units = "percentage", version = "retail"},
  PCT_TRAINER_BATTLE_WINS = {text = "% Trainer Pet Battle Victories", path = "battlepets/stats/pct_trainer_battle_wins", units = "percentage", version = "retail"},
  PCT_BATTLE_WINS_NO_FORFEITS = {text = "% Pet Battle Victories Exclude Forfeits", path = "battlepets/stats/pct_battle_wins_no_forfeits", units = "percentage", version = "retail"},
  PCT_WILD_BATTLE_WINS_NO_FORFEITS = {text = "% Wild Pet Battle Victories Exclude Forfeits", path = "battlepets/stats/pct_wild_battle_wins_no_forfeits", units = "percentage", version = "retail"},
  PCT_TRAINER_BATTLE_WINS_NO_FORFEITS = {text = "% Trainer Pet Battle Victories Exclude Forfeits", path = "battlepets/stats/pct_trainer_battle_wins_no_forfeits", units = "percentage", version = "retail"},
  TOTAL_PETS = {text = "Total Pets", units = "integer", path = "battlepets/stats/total_pets", version = "retail", order = 100, exclude_total = true},
  MAX_LEVEL_PETS = {text = "Total Max Level Pets", path = "battlepets/stats/max_level_pets", units = "integer", version = "retail", order = 101, exclude_total = true},
  COMBAT_PETS = {text = "Total Combat Pets", units = "integer", path = "battlepets/stats/combat_pets", version = "retail", order = 102, exclude_total = true},
  WILD_CAUGHT_PETS = {text = "Total Pets Caught in the Wild", path = "battlepets/stats/wild_caught_pets", units = "integer", version = "retail", order = 103, exclude_total = true},
  PET_RARITY_COUNTS = {text = "Total * Pets", units = "integer", path = "battlepets/stats/pet_rarity/*", version = "retail", order = 110, exclude_total = true},
  PET_TYPE_COUNTS = {text = "Total * Type Pets", units = "integer", path = "battlepets/stats/pet_type/*", version = "retail", order = 120, exclude_total = true},
  PET_BATTLE_COUNTS = {text = "Most Used Pets: *", units = "integer", path = "battlepets/data/pet_battle_counts/*", version = "retail", order = 200},
  
  --reputation
  FACTION_REMAINING = {text = "*: Remaining Rep to Next Rank", path = "reputation/stats/faction_remaining/*", units = "integer", order = 300},
  FACTION_REMAINING_TIME = {text = "*: Time Until Next Rank", path = "reputation/stats/faction_remaining_time/*", units = "time", order = 300},
  FACTION_TIME_NEUTRAL = {text = "*: Time until Neutral", path = "reputation/stats/faction_time_neutral/*", units = "time", order = 300, exclude_total = true},
  FACTION_TIME_EXALTED = {text = "*: Time until Exalted", path = "reputation/stats/faction_time_exalted/*", units = "time", order = 300, exclude_total = true},
  FACTION_REMAINING_EXALTED = {text = "*: Remaining Rep until Exalted", path = "reputation/stats/faction_remaining_exalted/*", units = "integer", order = 300, exclude_total = true},
  FACTION_CHANGE_DELTA_RATE = {text = "*: Rep. Gained Per Day", path = "reputation/stats/faction_change_delta_rate/*", units = "integer/day", order = 300},
  --faction_delta_* = {text = "Delta: *", units = "integer", order = 100}, --FOR TESTING ONLY
  
  
  --time
  TIME_FISHING = {text = "Total Time Fishing", units = "time", path = "time/stats/time_fishing", order = 850, version="retail"},
  PCT_TIME_FISHING = {text = "% Play Time: Fishing", path = "time/stats/pct_time_fishing", units = "percentage", order = 852, version="retail"},
  TIME_INDOORS = {text = "Total Time Indoors", units = "time", path = "time/stats/time_indoors", abbr="Indoors", order = 855},
  PCT_TIME_INDOORS = {text = "% Play Time: Indoors", path = "time/stats/pct_time_indoors", abbr = "Indoors", units = "percentage", order = 857},
  TIME_OUTDOORS = {text = "Total Time Outdoors", units = "time", path = "time/stats/time_outdoors", abbr="Outdoors", order = 858},
  PCT_TIME_OUTDOORS = {text = "% Play Time: Outdoors", path = "time/stats/pct_time_outdoors", abbr = "Outdoors", units = "percentage", order = 859},
  AIR_TIME = {text = "Jump Air Time", path = "time/stats/air_time", units = "time", order = 870},
  PCT_TIME_JUMP = {text = "% Play Time: Jump Air Time", path = "time/stats/pct_time_jump", abbr = "Jump Air Time", units = "percentage", order = 871},
  TIME_COMBAT = { text = "Total Time in Combat", path = "time/stats/time_combat", units = "time", order = 400},
  PCT_PLAY_TIME_AFK = {text="% Play Time: AFK", path = "time/stats/pct_play_time_afk", units = "percentage", order = 610},
  PCT_PLAY_TIME_COMBAT = {text = "% Play Time: Combat", path = "time/stats/pct_play_time_combat", units = "percentage", order = 410},
  TIME_AFK = {text = "Total Time AFK", path = "time/stats/time_afk", units = "time", order = 600},
  PLAY_TIME = {text = "Total Play Time", path = "time/stats/play_time", units = "time", order = 50},
  TIME_SUB_MAX_LEVEL = {text = "Total Time Below Level Cap", path = "time/stats/time_sub_max_level", units = "time", order = 50},
  TIME_MOUNTED = {text = "Total Time Mounted", path = "time/stats/time_mounted", units = "time", order = 650},
  PCT_TIME_MOUNTED = {text = "% Play Time: Mounted", path = "time/stats/pct_time_mounted", units = "percentage", order = 660},
  TIME_RESTED = {text = "Total Time with Rested XP", path = "time/stats/time_rested", units = "time"},
  PCT_TIME_RESTED = {text = "% Play Time: Rested", path = "time/stats/pct_time_rested", units = "percentage"},
  TIME_PET_BATTLE = {text = "Total Time in Pet Battles", path = "time/stats/time_pet_battle", units = "time", order = 872, version = "retail"},
  PCT_TIME_PET_BATTLES = {text = "% Play Time: Pet Battles", path = "time/stats/pct_time_pet_battles", abbr = "Pet Battles", units = "percentage", order = 873, version = "retail"},
  
  --tradeskill
  COOKING_LOOTED = {text = "Cooking Items and Fish Gathered", path = "tradeskill/stats/cooking_looted", units = "integer", order = 801, version = "retail"},
  CLOTH_LOOTED = {text = "Cloth Gathered", path = "tradeskill/stats/cloth_looted", units = "integer", order = 801, version = "retail"},
  TRADESKILL_LOOTED = {text = "Tradeskill Items Looted", path = "tradeskill/stats/tradeskill_looted", units = "integer", order = 800},
  ENCHANTING_LOOTED = {text = "Enchanting Items Gathered", path = "tradeskill/stats/enchanting_looted", units = "integer", order = 801, version = "retail"},
  HERB_LOOTED = {text = "Herbs Gathered", units = "integer", path = "tradeskill/stats/herb_looted", order = 801, version = "retail"},
  JEWELCRAFTING_LOOTED = {text = "Jewelcrafting Items Gathered", path = "tradeskill/stats/jewelcrafting_looted", units = "integer", order = 801, version = "retail"},
  MEAT_LOOTED = {text = "Meat Gathered", units = "integer", path = "tradeskill/stats/meat_looted", order = 801, version = "retail"},
  LEATHER_LOOTED = {text = "Leather Gathered", units = "integer", path = "tradeskill/stats/leather_looted", order = 801, version = "retail"},
  METAL_LOOTED = {text = "Ore Gathered", path = "tradeskill/stats/metal_looted", units = "integer", order = 801, version = "retail"},
  BFA_TRADE_GOOD_COLLECTED = {text = "* Gathered", path = "tradeskill/stats/bfa_trade_good_collected/*", units = "integer", order = 650, version="retail"},
  LEGION_TRADE_GOOD_COLLECTED = {text = "* Gathered", path = "tradeskill/stats/legion_trade_good_collected/*", units = "integer", order = 650, version="retail"},
  WOD_TRADE_GOOD_COLLECTED = {text = "* Gathered", path = "tradeskill/stats/wod_trade_good_collected/*", units = "integer", order = 650, version="retail"},
  MOP_TRADE_GOOD_COLLECTED = {text = "* Gathered", path = "tradeskill/stats/mop_trade_good_collected/*", units = "integer", order = 650, version="retail"},
  CATA_TRADE_GOOD_COLLECTED = {text = "* Gathered", path = "tradeskill/stats/cata_trade_good_collected/*", units = "integer", order = 650, version="retail"},
  WOTLK_TRADE_GOOD_COLLECTED = {text = "* Gathered", path = "tradeskill/stats/wotlk_trade_good_collected/*", units = "integer", order = 650, version="retail"},
  BC_TRADE_GOOD_COLLECTED = {text = "* Gathered", path = "tradeskill/stats/bc_trade_good_collected/*", units = "integer", order = 650, version="retail"},
  CLASSIC_TRADE_GOOD_COLLECTED = {text = "* Gathered", path = "tradeskill/stats/classic_trade_good_collected/*", units = "integer", order = 650, version="retail"},
  SL_TRADE_GOOD_COLLECTED = {text = "* Gathered", path = "tradeskill/stats/sl_trade_good_collected/*", units = "integer", order = 650, version="retail"},
  
  --xp
  PET_BATTLE_XP = {text = "Total XP from Pet Battles", path = "xp/stats/pet_battle_xp", abbr="Pet Battle XP", units = "integer", version="retail"},
  PET_BATTLE_XP_RATE = {text = "Pet Battle XP Per Hour", path = "xp/stats/pet_battle_xp_rate", abbr="Pet Battle xp/hr", units = "integer/hour", version="retail"},  
  RESTED_XP_TIME_SAVED = {text = "Time Saved from Rested XP", path = "xp/stats/rested_xp_time_saved", units = "time"},
  PCT_XP_KILL = {text = "% XP: Kills", path = "xp/stats/pct_xp_kill", units = "percentage", order = 820},
  PCT_XP_PET_BATTLE = {text = "% XP: Pet Battles", path = "xp/stats/pct_xp_pet_battle", units = "percentage", order = 820, version="retail"},
  PCT_XP_QUEST = {text = "% XP: Quests", path = "xp/stats/pct_xp_quest", units = "percentage", order = 820},
  PCT_XP_OTHER = {text = "% XP: Other", path = "xp/stats/pct_xp_other", units = "percentage", order = 820},
  GATHERING_XP = {text = "Total XP from Gathering", path = "xp/stats/gathering_xp", abbr="Gathering XP", units = "integer", version="retail"},
  GATHERING_XP_RATE = {text = "Gathering XP Per Hour", path = "xp/stats/gathering_xp_rate", abbr="Gathering xp/hr", units = "integer/hour", version="retail"},  
  PCT_XP_GATHERING = {text = "% XP: Gathering", path = "xp/stats/pct_xp_gathering", units = "percentage", version="retail"},
  KILL_XP = {text = "Total XP from Kills", path = "xp/stats/kill_xp", units = "integer"},
  QUEST_XP = {text = "Total XP from Quests", path = "xp/stats/quest_xp", units = "integer"},
  RESTED_XP = { text = "Bonus Rested XP", path = "xp/stats/rested_xp", units ="integer"},
  PCT_LEVELS_GAINED_RATE = {text = "Fractional Levels Earned Per Hour", path = "xp/stats/pct_levels_gained_rate", units = "decimal/hour"},
  LEVELS_GAINED = { text = "Total Levels Earned", path = "xp/stats/levels_gained", units = "integer"},
  XP = { text = "Total XP", path = "xp/stats/xp", units = "integer"},
  QUEST_XP_RATE = { text = "Quest XP Per Hour", path = "xp/stats/quest_xp_rate", units = "integer/hour"},
  PCT_LEVELS_GAINED = {text = "Total Fractional Levels Earned", path = "xp/stats/pct_levels_gained", units="decimal"},
  SCENARIO_XP = {text = "Total XP from Scenarios", path = "xp/stats/scenario_xp", units="integer", version="retail"},
  KILL_XP_RATE = {text = "Kill XP Per Hour", path = "xp/stats/kill_xp_rate", units = "integer/hour"},
  BONUS_RESTED_XP_RATE = {text = "Bonus Rested XP Per Hour", path = "xp/stats/bonus_rested_xp_rate", units = "integer/hour"},
  TIME_TO_LEVEL = {text = "Est. Time to Next Level", path = "xp/stats/time_to_level", units = "time", exclude_total = true},
  LEVELS_GAINED_RATE = {text = "Total Levels Earned Per Hour", path = "xp/stats/levels_gained_rate", units = "integer/hour"},
  XP_RATE_TIL_MAX = {text = "Total XP Per Hour", path = "xp/stats/xp_rate_til_max", units = "integer/hour"},
  OTHER_XP_RATE = {text = "Misc. XP Per Hour", path = "xp/stats/other_xp_rate", units = "integer/hour"},
  OTHER_XP = {text = "Total Misc. XP", path = "xp/stats/other_xp", units = "integer"},
  SCENARIO_XP_RATE = {text = "Scenario XP Per Hour", path = "xp/stats/scenario_xp_rate", units = "integer/hour", version="retail"},
  GROUP_XP = {text = "Bonus Group XP", path = "xp/stats/group_xp", units = "integer", version="retail"},
  GROUP_XP_RATE = {text = "Bonus Group XP Per Hour", path = "xp/stats/group_xp_rate", units = "integer/hour", version="retail"},
  AZERITE_XP_RATE = {text = "Azerite XP Per Hour", path = "xp/stats/azerite_xp_rate", units = "integer/hour", order = 344, version="retail"},
  AZERITE_XP = {text = "Azerite XP Gained", path = "xp/stats/azerite_xp", units = "integer", order = 343, version="retail"},
  AZERITE_TIME_TO_LEVEL = {text = "Time to Next Azerite Level", path = "xp/stats/azerite_time_to_level", units = "time", order = 345, exclude_total = true, version="retail"}, 
  
  --zone
  ZONE_PCT = {text = "Zone %: *", path = "zones/stats/pct_zones/*", units = "percentage", order = 800},
  ZONE_TIME = {text = "*", path = "zones/stats/zones/*", units ="time", order = 200},

}

quantify.VIEWS = {
	["All"] = {	stats = {"*"}
	
			},
	["Zone Times"] = {
				stats = {"ZONE_TIME"}
			},
	["Zone Percentages"] = {
				stats = { "ZONE_PCT"}
			},
	["Gold Spent"] = {
				stats = {"REPAIR_MONEY", "AUCTION_MONEY_SPENT", "VENDOR_MONEY_SPENT"}
			},
	["Gold Spent Per Hour"] = {
				stats = {"REPAIR_MONEY_RATE", "AUCTION_MONEY_SPENT_RATE", "VENDOR_MONEY_SPENT_RATE"}
			},
	["Gold Earned"] = {
				stats = {"QUEST_MONEY", "AUCTION_MONEY", "VENDOR_MONEY", "MONEY_PICKPOCKETED", "MONEY_LOOTED"}
			},
	["Gold Earned Per Hour"] = {
				stats = {"QUEST_MONEY_RATE", "MONEY_PICKPOCKETED_RATE", "MONEY_LOOTED_RATE"} -- missing auction and vendor earned per hour
			},
	["Gold Overview"] = {
				stats = {"TOTAL_MONEY_GAINED", "TOTAL_MONEY_SPENT", "DELTA_MONEY"}
			},
	["Gold Overview Per Hour"] = {
				stats = {"TOTAL_MONEY_GAINED_RATE", "TOTAL_MONEY_SPENT_RATE", "DELTA_MONEY_RATE"}
			},
	["Gold Sources"] = {
				stats = {"PCT_MONEY_QUEST", "PCT_MONEY_AUCTION", "PCT_MONEY_LOOT", "PCT_MONEY_VENDOR"}
			},
	["Currency Gained"] = {
				stats = {"CURRENCY_GAINED"}
			},
	["Currency Gained Per Hour"] = {
				stats = {"CURRENCY_GAINED_RATES"}
			},
	["Chat Channels"] = {
				stats = {"WHISPERS_SENT", "SAY_SENT", "YELL_SENT", "PARTY_SENT", "RAID_SENT", "GUILD_SENT", "CHANNEL_SENT"}
			}, 
	["Chat Overview"] = {
				stats = {"COMBAT_MESSAGES", "MENTIONS", "EMOTES_SENT", "WHISPERS_RECEIVED", "BFF_SENT", "BFF_RECEIVED"}
			},
	["Combat Overview"] = {
				stats = {"KD_RATIO", "NUM_REZ_ACCEPTED", "NUM_SPIRIT_HEALER_REZ", "NUM_DEATHS", "NUM_BREZ_ACCEPTED", "NUM_CORPSE_RUNS", "TIME_CROWD_CONTROLLED", "PLAYER_ACTUAL_KILLS", "PLAYER_KILLS"}
			},
	["Armor Class Percentages"] = {
				stats = {"PCT_ARMOR_CLASS_LOOTED"}
			},	
	["Loot Quality Percentages"] = {
				stats = {"PCT_LOOT_QUALITY"}
			},
	["Loot Counts"] = {
				stats = {"INV_TYPE_LOOTED", "JUNK_LOOTED_VALUE", "TOTAL_ITEMS_LOOTED", "GEAR_LOOT", "JUNK_LOOTED", "POOR_LOOT", "COMMON_LOOT", "UNCOMMON_LOOT", "RARE_LOOT",
						"EPIC_LOOT", "BFA_POOR_LOOT", "BFA_COMMON_LOOT", "BFA_UNCOMMON_LOOT", "BFA_RARE_LOOT", "BFA_EPIC_LOOT", "CLOTH_GEAR_LOOT", "LEATHER_GEAR_LOOT", "MAIL_GEAR_LOOT", "PLATE_GEAR_LOOT"}
			},
	["Loot Upgrades"] = {
				stats = {"UPGRADES_RECEIVED", "OVERALL_ILEVEL_UPGRADES", "UPGRADES_RECEIVED_RATES"}
			},
	["Miscellaneous"] = {
				stats = {"JUMPS", "JUMPS_RATE"}
			},
	["Pet Counts"] = {
				stats = {"TOTAL_PETS", "MAX_LEVEL_PETS", "COMBAT_PETS", "WILD_CAUGHT_PETS", "PET_RARITY_COUNTS", "PET_TYPE_COUNTS", "PET_BATTLE_COUNTS", }
			},
	["Pet Battle Statistics"] = {
				stats = {"TOTAL_BATTLES", "TOTAL_WILD_BATTLES", "TOTAL_TRAINER_BATTLES", "TOTAL_FORFEITS", "TOTAL_BATTLE_WINS", "TOTAL_WILD_BATTLE_WINS", "TOTAL_TRAINER_BATTLE_WINS", "TOTAL_WILD_FORFEITS", "TOTAL_TRAINER_FORFEITS", }
			},
	["Pet Battle Win Rates"] = {
				stats = {"PCT_BATTLE_WINS", "PCT_WILD_BATTLE_WINS", "PCT_TRAINER_BATTLE_WINS", "PCT_BATTLE_WINS_NO_FORFEITS", "PCT_WILD_BATTLE_WINS_NO_FORFEITS", "PCT_TRAINER_BATTLE_WINS_NO_FORFEITS"}
			},
	["Pet Battle Counts"] = {
				stats = {"PET_BATTLE_COUNTS"}
			},
	["Time Overview"] = {
				stats = {"TIME_FISHING", "TIME_INDOORS", "TIME_OUTDOORS", "AIR_TIME", "TIME_COMBAT", "TIME_AFK", "PLAY_TIME", "TIME_SUB_MAX_LEVEL", "TIME_MOUNTED", "TIME_RESTED", "TIME_PET_BATTLE"}
			},
	["Play Time Percents"] = {
				stats = {"PCT_TIME_FISHING", "PCT_TIME_INDOORS", "PCT_TIME_OUTDOORS", "PCT_TIME_JUMP", "PCT_PLAY_TIME_AFK", "PCT_PLAY_TIME_COMBAT", "PCT_TIME_MOUNTED", "PCT_TIME_RESTED", "PCT_TIME_PET_BATTLES"}
			},
	["Trade Good Counts"] = {
				stats = {"COOKING_LOOTED", "CLOTH_LOOTED", "TRADESKILL_LOOTED", "ENCHANTING_LOOTED", "HERB_LOOTED", "JEWELCRAFTING_LOOTED", "MEAT_LOOTED", "LEATHER_LOOTED", "METAL_LOOTED"}
			},
	["Expansion Trade Goods"] = {
				stats = {"BFA_TRADE_GOOD_COLLECTED", "LEGION_TRADE_GOOD_COLLECTED", "WOD_TRADE_GOOD_COLLECTED", "MOP_TRADE_GOOD_COLLECTED", "CATA_TRADE_GOOD_COLLECTED", "WOTLK_TRADE_GOOD_COLLECTED", "BC_TRADE_GOOD_COLLECTED", "CLASSIC_TRADE_GOOD_COLLECTED", "SL_TRADE_GOOD_COLLECTED"},
				filter = {
					[0] = "CLASSIC_TRADE_GOOD_COLLECTED",
					[1] = "BC_TRADE_GOOD_COLLECTED",
					[2] = "WOTLK_TRADE_GOOD_COLLECTED",
					[3] = "CATA_TRADE_GOOD_COLLECTED",
					[4] = "MOP_TRADE_GOOD_COLLECTED",
					[5] = "WOD_TRADE_GOOD_COLLECTED",
					[6] = "LEGION_TRADE_GOOD_COLLECTED",
					[7] = "BFA_TRADE_GOOD_COLLECTED",
					[8] = "SL_TRADE_GOOD_COLLECTED",
				}
			},
	["Faction Reputations"] = {
				stats = {"FACTION_REMAINING", "FACTION_REMAINING_TIME", "FACTION_TIME_NEUTRAL", "FACTION_TIME_EXALTED", "FACTION_REMAINING_EXALTED", "FACTION_CHANGE_DELTA_RATE"}
			},
	["Character Advancement Overview"] = {
				stats = {"RESTED_XP_TIME_SAVED", "PCT_LEVELS_GAINED_RATE", "LEVELS_GAINED", "PCT_LEVELS_GAINED", "TIME_TO_LEVEL", "LEVELS_GAINED_RATE"}
			},	
	["Character XP"] = {
				stats = {"PET_BATTLE_XP", "GATHERING_XP", "KILL_XP", "QUEST_XP", "RESTED_XP", "XP", "SCENARIO_XP", "OTHER_XP", "GROUP_XP"}
			},
	["Character XP Rates"] = {
				stats = {"PET_BATTLE_XP_RATE", "GATHERING_XP_RATE", "KILL_XP_RATE", "QUEST_XP_RATE", "BONUS_RESTED_XP_RATE", "XP_RATE_TIL_MAX", "SCENARIO_XP_RATE", "OTHER_XP_RATE", "GROUP_XP_RATE"}
			},
	["Character XP Percentages"] = {
				stats = {"PCT_XP_KILL", "PCT_XP_PET_BATTLE", "PCT_XP_QUEST", "PCT_XP_GATHERING"}
			},
	["Azerite XP"] = {
				stats = {"AZERITE_XP_RATE", "AZERITE_XP", "AZERITE_TIME_TO_LEVEL"}
			},	
}

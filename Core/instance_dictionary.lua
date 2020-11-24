quantify.LEGION_DUNGEON_IDS = {1501, 1677, 1571, 1466, 1456, 1477, 1492, 1458, 1651, 1753, 1516, 1493, 1544}
quantify.LEGION_RAID_IDS = {1520,1648,1530,1676,1712}
quantify.BFA_DUNGEON_IDS = {1877,1862,1763,1754,1762,1864,1822,1594,1841,1771, 2097}
quantify.BFA_RAID_IDS = {1861,2070,2096,2164,2217}
quantify.BFA_END_BOSSES = {"Yazma", "Lord Harlan Sweete", "Dazar, The First King", "Vol'zith the Whisperer", "Viq'Goth", "Avatar of Sethraliss", "Mogul Razdunk", "Unbound Abomination", "Overseer Korgus", "Gorak Tul", "King Mechagon"}
quantify.BFA_END_BOSS_IDS = {2108,2117,2087,2127,2123,2096,2143,2133,2100,2104,2260}

quantify.SL_DUNGEON_IDS = {2286,2289,2290,2287,2293,2291,2285,2284}
quantify.SL_END_BOSS_IDS = {2396,2381,2393,2390,2386,2363,2359,2404}


quantify.CLASSIC_DUNGEON_IDS = {48, 230, 229, 429, 90, 349, 389, 129, 47, 1001, 1004, 1007, 33, 329, 36, 34, 109, 70, 43, 209}
quantify.CLASSIC_RAID_IDS = {469, 409, 509, 531}
quantify.CLASSIC_END_BOSSES = {"Aku'mai", "Emperor Dagran Thaurissan", "Overlord Wyrmthalak", "Bazzalan", "Edwin VanCleef", "Mutanus the Devourer", "Archmage Arugal", "Bazil Thredd", "Mekgineer Thermaplugg", "Charlga Razorflank", "High Inquisitor Whitemane", "Amnennar the Coldbringer", "Archaedas", "Gahz'rilla", "Princess Theradras", "Shade of Eranikus", "King Gordok", "Darkmaster Gandling", "Baron Rivendare", "Lava Guard Gordoth"}


quantify.CLASSIC_DUNGEONS = {
    [389] = {
        name = "Ragefire Chasm",
        bosses = {
            ["Taragaman the Hungerer"] = {},
            ["Oggleflint"] = {},
            ["Jergosh"] = {},
            ["Bazzalan"] = {final = true},
            ["Adarogg"] = {},
            ["Dark Shaman"] = {},
            ["Slagmaw"] = {},
            ["Lava Guard Gordoth"] = {final = true}
          }
      },
    [34] = {
        name = "The Stockade",
        bosses = {
          ["Targorr the Dread"] = {},
          ["Kam Deepfury"] = {},
          ["Hamhock"] = {},
          ["Dextren Ward"] = {},
          ["Bazil Thredd"] = {final = true},
          ["Bruegal Ironknuckle"] = {}
        }
      },
    [36] = {
        name = "The Deadmines",
        bosses = {
          ["Rhahk'Zor"] = {},
          ["Miner Johnson"] = {},
          ["Sneed's Shredder"] = {},
          ["Gilnid"] = {},
          ["Mr. Smite"] = {},
          ["Captain Greenskin"] = {},
          ["Edwin VanCleef"] = {final = true},
          ["Cookie"] = {}
        }
      },
    [43] = {
        name = "Wailing Caverns",
        bosses = {
          ["Kresh"] = {},
          ["Lady Anacondra"] = {},
          ["Lord Cobrahn"] = {},
          ["Deviate Faerie Dragon"] = {},
          ["Lord Pythas"] = {},
          ["Skum"] = {},
          ["Lord Serpentis"] = {},
          ["Verdan the Everliving"] = {},
          ["Mutanus the Devourer"] = {final = true}
        }
      },
    [33] = {
        name = "Shadowfang Keep",
        bosses = {
          ["Rethilgore"] = {},
          ["Fel Steed"] = {siblings =  {"Shadow Charger"}},
          ["Shadow Charger"] = {siblings = {"Fel Steed"}},
          ["Razorclaw the Butcher"] = {},
          ["Baron Silverlaine"] = {},
          ["Commander Springvale"] = {},
          ["Odo the Blindwatcher"] = {},
          ["Deathsworn Captain"] = {},
          ["Fenrus the Devourer"] = {},
          ["Wolf Master Nandos"] = {},
          ["Archmage Argual"] = {final = true}
        }
      },
    [48] = {
        name = "Blackfathom Deeps",
        bosses = {
          ["Ghamoo-ra"] = {},
          ["Lady Sarevess"] = {},
          ["Gelihast"] = {},
          ["Lorgus Jett"] = {},
          ["Baron Aquanis"] = {},
          ["Twilight Lord Kelris"] = {},
          ["Old Serra'kis"] = {},
          ["Aku'mai"] = {final = true}
        }
      },
    [230] = {
        name = "Blackrock Depths",
        bosses = {
          ["Lord Roccor"] = {},
          ["Bael'Gar"] = {},
          ["Houndmaster Grebmar"] = {},
          ["High Interrogator Gerstahn"] = {},
          ["High Justice Grimstone"] = {},
          ["Pyromancer Loregrain"] = {},
          ["General Angerforge"] = {},
          ["Golem Lord Argelmach"] = {},
          ["Ribbly Screwspigot"] = {},
          ["Hurley Blackbreath"] = {},
          ["Plugger Spazzring"] = {},
          ["Phalanx"] = {},
          ["Lord Incendius"] = {},
          ["Fineous Darkvire"] = {},
          ["Warder Stilgiss"] = {siblings = {"Verek"}},
          ["Verek"] = {siblings = {"Warder Stilgiss"}},
          ["Dark Coffer"] = {},
          ["Ambassador Flamelash"] = {},
          ["Chest of The Seven"] = {},
          ["Magmus"] = {},
          ["Princess Moira Bronzebeard"] = {},
          ["Emperor Dagran Thaurissan"] = {final = true}
        }
      },
    [229] = {
        name = "Lower Blackrock Spire",
        bosses = {
          ["Highlord Omokk"] = {},
          ["Shadow Hunter Vosh'gajin"] = {},
          ["War Master Voone"] = {},
          ["Mother Smolderweb"] = {},
          ["Urok Doomhowl"] = {},
          ["Quartermaster Zigris"] = {},
          ["Gizrul the Slavener"] = {},
          ["Halcyon"] = {},
          ["Overlord Wyrmthalak"] = {final = true},
        }
      },
    [429] = { --not available until phase 2
        name = "Dire Maul",
        bosses = {

        }
      },
    [90] = {
        name = "Gnomeregan",
        bosses = {
          ["Grubbis"] = {},
          ["Viscous Fallout"] = {},
          ["Electrocutioner 6000"] = {},
          ["Crowd Pummeler 9-60"] = {},
          ["Dark Iron Ambassador"] = {},
          ["Mekgineer Thermaplugg"] = {final = true}
        }
      },
    [349] = {
        name = "Maraudon",
        bosses = {
          ["Noxxion"] = {},
          ["Razorlash"] = {},
          ["Lord Vyletongue"] = {},
          ["Celebras the Cursed"] = {},
          ["Landslide"] = {},
          ["Tinkerer Gizlock"] = {},
          ["Rotgrip"] = {},
          ["Princess Theradras"] = {final = true},
        }
      },
    [129] = {
        name = "Razorfen Downs",
        bosses = {
          ["Tuten'kash"] = {},
          ["Plaguemaw the Rotting"] = {},
          ["Mordresh Fire Eye"] = {},
          ["Ragglesnout"] = {},
          ["Glutton"] = {},
          ["Amnennar the Coldbringer"] = {final = true}
        }
      },
    [47] = {
        name = "Razorfen Kraul",
        bosses = {
          ["Roogug"] = {},
          ["Aggem Thorncurse"] = {},
          ["Death Speaker Jargba"] = {},
          ["Overlord Ramtusk"] = {},
          ["Agathelos the Raging"] = {},
          ["Charlga Razorflank"] = {final = true}
        }
      },
    [1001] = {    --not entirely sure what this is
        name = "Scarlet Halls",
        bosses = {
          
        }
      },
    [1004] = {
        name = "Scarlet Monastery",
        bosses = {
          ["Interrogator Vishas"] = {},
          ["Bloodmage Thalnos"] = {},
          ["Azshir the Sleepless"] = {},
          ["Fallen Champion"] = {},
          ["Ironspine"] = {},
          ["Houndmaster Loksey"] = {},
          ["Arcanist Doan"] = {},
          ["Herod"] = {},
          ["Scarlet Command Mograine"] = {final = true},
          ["High Inquisitor Whitemane"] = {},
          ["High Inquisitor Fairbanks"] = {},
        }
      },
    [329] = {
        name = "Stratholme",
        bosses = {
          ["Fras Siabi"] = {},
          ["Skul"] = {},
          ["Hearthsinger Forresten"] = {},
          ["The Unforgiven"] = {},
          ["Postmaster Malown"] = {},
          ["Timmy the Cruel"] = {},
          ["Malor the Zealous"] = {},
          ["Cannon Master Willey"] = {},
          ["Crimson Hammersmith"] = {},
          ["Archivist Galford"] = {},
          ["Balnazzar"] = {},
          ["Magistrate Barthilas"] = {},
          ["Stonespine"] = {},
          ["Nerub'enkan"] = {},
          ["Black Guard Swordsmith"] = {},
          ["Maleki the Pallid"] = {},
          ["Baroness Anastari"] = {},
          ["Ramstein the Gorger"] = {},
          ["Baron Rivendare"] = {final = true},
        }
      },
    [1007] = {
        name = "Scholomance",
        bosses = {
          ["Kirtonos the Herald"] = {},
          ["Jandice Barov"] = {},
          ["Rattlegore"] = {},
          ["Marduk Blackpool"] = {},
          ["Vectus"] = {},
          ["Ras Frostwhisper"] = {},
          ["Instructor Malicia"] = {},
          ["Doctor Theolen Krastinov"] = {},
          ["Lorekeeper Polkelt"] = {},
          ["The Ravenian"] = {},
          ["Lord Alexei Barov"] = {},
          ["Lady Illucia Barov"] = {},
          ["Darkmaster Gandling"] = {final = true},
        }
      },
    [109] = {
        name = "The Temple of Atal'Hakkar",
        bosses = {
          ["Atal'ai Defenders"] = {},
          ["Atal'alarion"] = {},
          ["Dreamscythe"] = {},
          ["Weaver"] = {},
          ["Jammal'an the Prophet"] = {},
          ["Ogom the Wretched"] = {},
          ["Morphaz"] = {},
          ["Hazzas"] = {},
          ["Avatar of Hakkar"] = {},
          ["Shade of Eranikus"] = {final = true},
        }
      },
    [70] = {
        name = "Uldaman",
        bosses = {
          ["Revelosh"] = {},
          ["Baelog"] = {},
          ["Ironaya"] = {},
          ["Obsidian Sentinel"] = {},
          ["Ancient Stone Keeper"] = {},
          ["Galgann Firehammer"] = {},
          ["Grimlok"] = {},
          ["Archaedas"] = {final = true},
        }
      },
    [209] = {
        name = "Zul'Farrak",
        bosses = {
          ["Antu'sul"] = {},
          ["Theka the Martyr"] = {},
          ["Witch Doctor Zum'rah"] = {},
          ["Nekrum Gutchewer"] = {},
          ["Shadowpriest Sezz'ziz"] = {},
          ["Sergeant Bly"] = {},
          ["Hydromancer Velratha"] = {},
          ["Dustwraith"] = {},
          ["Chief Ukorz Sandscalp"] = {final = true},
          ["Ruuzlu"] = {},
          ["Zerillis"] = {},
          ["Sandarr Dunereaver"] = {},
        }
      },
}
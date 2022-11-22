BACKDROP_QUANTIFY_WINDOW = {
  bgFile="Interface\\FrameGeneral\\UI-BACKGROUND-MARBLE",
  edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
  tile=true,
  tileSize = 256,
  edgeSize = 16,
  insets = {left=4, right=4, top=4, bottom=4}
}

BACKDROP_QUANTIFY_BAR = {
  bgFile="Interface\\FrameGeneral\\UI-BACKGROUND-MARBLE",
  tile=true,
  tileSize = 256,
  edgeSize = 16,
  insets = {left=4, right=4, top=4, bottom=4}
}

BACKDROP_QUANTIFY_WATCHLIST = {
  bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
  tile=true,
  tileSize = 256,
  edgeSize = 16,
  insets = {left=4, right=4, top=4, bottom=4}
}

QUANTIFY_WIDGETS = {
    ["All"] = {
      widget = "StatWidget",
      data = {
        rows = 1,
        columns = 1,
        views = { 
                {view_type = "filter", padding_x = 450, padding_y = -540, grid_position = "0,0", 
                 view_data = {"All"},
                 view_options = {filter_type = "text", label = "", col_widths = {500, 200}, columns = {"Stat", "Value"}, filter_padding = {-240, 0}}
                  }
               }
      }
    },
    ["Battle Pets"] = {
      widget = "StatWidget",
      retail_only = true,
      data = {
        rows = 2,
        columns = 2,
        views = {
            {view_type = "table", grid_position = "0,0", colspan = 1, rowspan = 1, padding_x = 30, padding_y = -220,
              view_data = {"Pet Battle Statistics"},
              view_options = {columns = {"Stat", "Value"}, label = "Battle Statistics"}
                },
            {view_type = "table", grid_position = "1,0", colspan = 1, rowspan = 1, padding_x = 30, padding_y = -220,
              view_data = {"Pet Battle Win Rates"},
              view_options = {columns = {"Category", "Win Percent"}, label = "Win Rates"}
                },
            {view_type = "table", grid_position = "0,1", colspan = 1, rowspan = 1, padding_x = 30, padding_y = -220,
              view_data = {"Pet Counts"},
              view_options = {columns = {"Category", "Number"}, label = "Pets"}
                },
            {view_type = "table", grid_position = "1,1", colspan = 1, rowspan = 1, padding_x = 30, padding_y = -220,
              view_data = {"Pet Battle Counts"},
              view_options = {columns = {"Pet", "Battles"}, label = "Favorite Pets"}
                },
          }
        }
    },
    ["Chat"] = {
      widget = "StatWidget",
      data = {
        rows = 1,
        columns = 2,
        views = {
          {view_data = {"Chat Channels"}, grid_position = "1,0", padding_x = 50, padding_y = -470,
           view_options = {columns = {"Channel", "Messages Sent"}}},
          {view_data = {"Chat Overview"}, padding_x = 50, padding_y = -470, grid_position = "0,0"}
        }
      }
    },
    ["Combat"] = {
      widget = "StatWidget",
      data = {
        rows = 1,
        columns = 1,
        views = {
          {view_data = {"Combat Overview"}, grid_position = "0,0", padding_x = 450, padding_y = -500,
           view_options = {label = "", col_widths = {500,200}}}
        }
      }
    },
    ["Currency"] = {
      widget = "StatWidget",
      data = {
        rows = 1,
        columns = 1,
        views = {
            {view_type = "table", grid_position = "0,0", padding_y = -500, padding_x = 450, 
              view_data = {"Currency Gained","Currency Gained Per Hour"},
              view_options = {columns = {"Currency", "Amount", "Amount Per Hour"}, col_widths = {400, 140, 140}, label = ""}}
          }
      }
    },
    ["Dungeons"] = {
      widget = "DungeonWidget",
      retail_only = true
    },
    ["Loot"] = {
      widget = "StatWidget",
      data = {
        rows = 5,
        columns = 2,
        views = {
          {view_type = "table", grid_position = "0,0", padding_x = 30, padding_y = -290, rowspan = 3, colspan = 1,
           view_data = {"Loot Counts"},
           view_options = {columns = {"Category", "Amount"}, label = "Loot"}
          },
          {view_type = "table", grid_position = "1,0", padding_x = 30, padding_y = -290, rowspan = 3, colspan = 1,
          view_data = {"Loot Upgrades"},
          view_options = {columns = {"Category", "Amount"}, label = "Upgrades"}
          },         
          {view_type = "pie", grid_position = "0,3", padding_x = 30, padding_y = 0, rowspan = 2,
           view_data = {"Loot Quality Percentages"},
           view_options = {label = "Loot Quality"}
          },
          {view_type = "pie", grid_position = "1,3", padding_x = 30, padding_y = 0, rowspan = 2,
           view_data = {"Armor Class Percentages"},
           view_options = {label = "Loot Armor Class"}
          },
        }
      }
    },
    ["Miscellaneous"] = {
      widget = "StatWidget",
      data = {
        rows = 1,
        columns = 1,
        views = {
            {view_type = "table", grid_position = "0,0", padding_y = -500, padding_x = 450, 
              view_data = {"Miscellaneous"},
              view_options = {label = "", col_widths = {500, 200}}
            }
          }
      }
    },
    ["Reputation"] = {
      widget = "StatWidget",
      data = {
        rows = 1,
        columns = 1,
        views = {
          {view_type = "filter", grid_position = "0,0", padding_x = 450, padding_y = -480,
           view_data = {"Faction Reputations"},
           view_options = {dropdown_values = qDA.getFactions, filter_type = "dropdown", col_widths = {400, 140}, filter_padding = {-320, 0}, filter_refresh_events = {"PROCESSED_ALL_FACTIONS"}}
          }
        }
      }
    },
    ["Time"] = {
      widget = "StatWidget",
      data = {
        rows = 1,
        columns = 2,
        views = {
          {view_data = {"Time Overview"}, grid_position = "0,0", padding_x = 50, padding_y = -470,
           view_options = {columns = {"Category", "Total Time"}, label = "Play Time Overview"}},
          {view_data = {"Play Time Percents"}, padding_x = 50, padding_y = -470, grid_position = "1,0",
           view_options = {columns = {"Category", "Percent"}}}
        }
      }
    },
    ["Tradeskill"] = {
      widget = "StatWidget",
      data = {
        rows = 1,
        columns = 2,
        views = {
          {view_data = {"Trade Good Counts"}, grid_position = "0,0", padding_x = 50, padding_y = -470,
           view_options = {columns = {"Type", "Amount"}, label = "Trade Goods Collected"}},
          {view_data = {"Expansion Trade Goods"}, view_type = "filter", padding_x = 50, padding_y = -470, grid_position = "1,0",
           view_options = {filter_type = "dropdown", filter_method = "table", dropdown_values = qDA.getExpansionLootIds, columns = {"Type", "Amount"}, label = "Trade Goods"}}
        }
      }
    },    
    ["Wealth"] = {
      widget = "StatWidget",
      data = {
        rows = 2,
        columns = 2,
        views = {
            {view_type = "multi", grid_position = "1,0", colspan = 1, rowspan = 1, padding_x = 30, padding_y = -220,
              view_data = {"Gold Spent", "Gold Spent Per Hour"},
              view_options = {button_text = {"Totals", "Per Hour"},
                              columns = {{"Category", "Gold"},{"Category", "Gold Per Hour"}}}
                },
            {view_type = "multi", grid_position = "0,1", colspan = 1, rowspan = 1, padding_x = 30, padding_y = -220,
              view_data = {"Gold Earned", "Gold Earned Per Hour"},
              view_options = {button_text = {"Totals", "Per Hour"},
                              columns = {{"Source", "Gold"},{"Source", "Gold Per Hour"}}}
                },
            {view_type = "multi", grid_position = "0,0", colspan = 1, rowspan = 1, padding_x = 30, padding_y = -220,
              view_data = {"Gold Overview", "Gold Overview Per Hour"},
              view_options = {button_text = {"Totals", "Per Hour"},
                              columns = {{"Category", "Gold"},{"Category", "Gold Per Hour"}}}
                },
            {view_type = "pie", padding_x = 30, padding_y = -50, grid_position = "1,1", colspan = 1, rowspan = 1,
              view_data = {"Gold Sources"}
            },
          }
        }
    },
    ["XP"] = {
      widget = "StatWidget",
      data = {
        rows = 2,
        columns = 2,
        views = {
            {view_type = "table", grid_position = "0,1", colspan = 2, rowspan = 1, padding_x = 450, padding_y = -220,
              view_data = {"Character XP", "Character XP Rates"},
              view_options = {columns = {"Source", "Total", "Per Hour"}, label = "XP Gained", col_widths = {400, 120, 120}}
                },
            {view_type = "table", grid_position = "0,0", colspan = 1, rowspan = 1, padding_x = 30, padding_y = -220,
              view_data = {"Character Advancement Overview"},
              view_options = {label = "Overview"}
                },
            {view_type = "pie", padding_x = 30, padding_y = -50, grid_position = "1,0", colspan = 1, rowspan = 1,
              view_data = {"Character XP Percentages"},
              view_options = {label = "XP Sources", complete_pie = false}
            },
          }
        }
    },
    ["Zones"] = {
      widget = "StatWidget",
      data = {
        rows = 1,
        columns = 1,
        views = {
            {view_type = "table", grid_position = "0,0", padding_y = -500, padding_x = 470, 
              view_data = {"Zone Times","Zone Percentages"},
              view_options = {columns = {"Zone", "Time", "Percentage"}, col_widths = {480, 130, 130}, label = ""}}
        }
      }
    }
  
}
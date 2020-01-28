
local L = LibStub("AceLocale-3.0"):NewLocale("BagSync", "enUS", true)
if not L then return end

L.Yes = "Yes"
L.No = "No"
L.TooltipCrossRealmTag = "XR"
L.TooltipBattleNetTag = "BN"
L.TooltipBag = "Bags:"
L.TooltipBank = "Bank:"
L.TooltipEquip = "Equip:"
L.TooltipGuild = "Guild:"
L.TooltipMail = "Mail:"
L.TooltipVoid = "Void:"
L.TooltipReagent = "Reagent:"
L.TooltipAuction = "AH:"
L.TooltipTotal = "Total:"
L.TooltipItemID = "[ItemID]:"
L.TooltipFakeID = "[FakeID]:"
L.TooltipDelimiter = ", "
L.TooltipRealmKey = "RealmKey:"
L.Search = "Search"
L.Refresh = "Refresh"
L.Profiles = "Profiles"
L.Professions = "Professions"
L.Currency = "Currency"
L.Blacklist = "Blacklist"
L.Recipes = "Recipes"
L.Gold = "Gold"
L.Close = "Close"
L.FixDB = "FixDB"
L.Config = "Config"
L.DeleteWarning = "Select a profile to delete. NOTE: This is irreversible!"
L.Delete = "Delete"
L.Confirm = "Confirm"
L.FixDBComplete = "A FixDB has been performed on BagSync!  The database is now optimized!"
L.ResetDBInfo = "BagSync:\nAre you sure you want to reset the database?\n|cFFDF2B2BNOTE: This is irreversible!|r"
L.ON = "ON"
L.OFF = "OFF"
L.LeftClickSearch = "|cffddff00Left Click|r |cff00ff00= Search Window|r"
L.RightClickBagSyncMenu = "|cffddff00Right Click|r |cff00ff00= BagSync Menu|r"
L.ProfessionInformation = "|cffddff00Left Click|r |cff00ff00a Profession to view Recipes.|r"
L.ClickViewProfession = "Click to view profession: "
L.ClickHere = "Click Here"
L.ErrorUserNotFound = "BagSync: Error user not found!"
L.EnterItemID = "Please enter an ItemID. (Use http://Wowhead.com/)"
L.AddGuild = "Add Guild"
L.AddItemID = "Add ItemID"
L.RemoveItemID = "Remove ItemID"
L.ItemIDNotFound = "[%s] ItemID not found.  Try again!"
L.ItemIDNotValid = "[%s] ItemID not valid ItemID or the server didn't respond.  Try again!"
L.ItemIDRemoved = "[%s] ItemID Removed"
L.ItemIDAdded = "[%s] ItemID Added"
L.ItemIDExist = "[%s] ItemID already in blacklist database."
L.GuildExist = "Guild [%s] already in blacklist database."
L.GuildAdded = "Guild [%s] Added"
L.GuildRemoved = "Guild [%s] Removed"
L.BlackListRemove = "Remove [%s] from the blacklist?"
L.BlackListErrorRemove = "Error deleting from blacklist."
L.ProfilesRemove = "Remove [%s][|cFF99CC33%s|r] profile from BagSync?"
L.ProfilesErrorRemove = "Error deleting from BagSync."
L.ProfileBeenRemoved = "[%s][|cFF99CC33%s|r] profile deleted from BagSync!"
L.ProfessionsFailedRequest = "[%s] Server Request Failed."
L.ProfessionHasRecipes = "Left click to view recipes."
L.ProfessionHasNoRecipes = "Has no recipes to view."
L.KeybindBlacklist = "Show Blacklist window."
L.KeybindCurrency = "Show Currency window."
L.KeybindGold = "Show Gold tooltip."
L.KeybindProfessions = "Show Professions window."
L.KeybindProfiles = "Show Profiles window."
L.KeybindSearch = "Show Search window."
L.ObsoleteWarning = "\n\nNote: Obsolete items will continue to show as missing.  To repair this issue, scan your characters again in order to remove obsolete items.\n(Bags, Bank, Reagent, Void, etc...)"
L.DatabaseReset = "Due to changes in the database.  Your BagSync database has been reset."
L.UnitDBAuctionReset = "Auction data has been reset for all characters."
L.ScanGuildBankStart = "Querying server for Guild Bank info, please wait....."
L.ScanGuildBankDone = "Guild Bank scan complete!"
L.ScanGuildBankError = "Warning: Guild Bank scanning incomplete."
-- ----THESE ARE FOR SLASH COMMANDS
L.SlashItemName = "[itemname]"
L.SlashSearch = "search"
L.SlashGold = "gold"
L.SlashMoney = "money"
L.SlashConfig = "config"
L.SlashCurrency = "currency"
L.SlashFixDB = "fixdb"
L.SlashProfiles = "profiles"
L.SlashProfessions = "professions"
L.SlashBlacklist = "blacklist"
L.SlashResetDB = "resetdb"
------------------------
L.HelpSearchItemName = "/bgs [itemname] - Does a quick search for an item"
L.HelpSearchWindow = "/bgs search - Opens the search window"
L.HelpGoldTooltip = "/bgs gold (or /bgs money) - Displays a tooltip with the amount of gold on each character."
L.HelpCurrencyWindow = "/bgs currency - Opens the currency window."
L.HelpProfilesWindow = "/bgs profiles - Opens the profiles window."
L.HelpFixDB = "/bgs fixdb - Runs the database fix (FixDB) on BagSync."
L.HelpResetDB = "/bgs resetdb - Resets the entire BagSync database."
L.HelpConfigWindow = "/bgs config - Opens the BagSync Config Window"
L.HelpProfessionsWindow = "/bgs professions - Opens the professions window."
L.HelpBlacklistWindow = "/bgs blacklist - Opens the blacklist window."
L.EnableBagSyncTooltip = "Enable BagSync Tooltips"
L.EnableExtTooltip = "Display item count data in an external toolip."
L.EnableLoginVersionInfo = "Display BagSync version text at login."
L.DisplayTotal = "Display [Total] amount."
L.DisplayGuildGoldInGoldTooltip = "Display [Guild] gold totals in Gold Tooltip."
L.DisplayGuildBank = "Display guild bank items."
L.DisplayMailbox = "Display mailbox items."
L.DisplayAuctionHouse = "Display auction house items."
L.DisplayMinimap = "Display BagSync minimap button."
L.DisplayFaction = "Display items for both factions (Alliance/Horde)."
L.DisplayClassColor = "Display class colors for characters."
L.DisplayTooltipOnlySearch = "Display BagSync tooltip |cFF99CC33(ONLY)|r in the search window."
L.DisplayLineSeperator = "Display empty line seperator."
L.DisplayCrossRealm = "Display Cross-Realms characters. |cffff7d0a[XR]|r"
L.DisplayBNET = "Display Battle.Net Account characters. |cff3587ff[BNet]|r |cFFDF2B2B(Not Recommended)|r."
L.DisplayItemID = "Display ItemID in tooltip."
L.DisplayTooltipTags = "Tags"
L.DisplayTooltipRealmNames = "Realm Names"
L.DisplayGreenCheck = "Display %s next to current character name."
L.DisplayRealmIDTags = "Display |cffff7d0a[XR]|r and |cff3587ff[BNet]|r realm identifiers."
L.DisplayRealmNames = "Display realm names."
L.DisplayRealmAstrick = "Display [*] instead of realm names for |cffff7d0a[XR]|r and |cff3587ff[BNet]|r."
L.DisplayShortRealmName = "Display short realm names for |cffff7d0a[XR]|r and |cff3587ff[BNet]|r."
L.DisplayFactionIcons = "Display faction icons in tooltip."
L.DisplayShowUniqueItemsTotals = "Enabling this option will allow unique items to be added towards the total item count, regardless of item stats. |cFF99CC33(Recommended)|r."
L.DisplayShowUniqueItemsTotals_2 = [[
Certain items like |cffff7d0a[Legendaries]|r can share the same name but have different stats.  Since these items are treated independently from one another, they are sometimes not counted towards the total item count. Enabling this option will completely disregard the unique item stats and treat them all the same, so long as they share the same item name.

Disabling this option will display the item counts independently as item stats will be taken into consideration.  Item totals will only display for each character that share the same unique item with the exact same stats. |cFFDF2B2B(Not Recommended)|r
]]
L.DisplayShowUniqueItemsTotalsTitle = "Show Unique Item Tooltip Totals"
L.DisplayShowUniqueItemsEnableText = "Enable unique item totals."
L.ColorPrimary = "Primary BagSync tooltip color."
L.ColorSecondary = "Secondary BagSync tooltip color."
L.ColorTotal = "BagSync [Total] tooltip color."
L.ColorGuild = "BagSync [Guild] tooltip color."
L.ColorCrossRealm = "BagSync [Cross-Realms] tooltip color."
L.ColorBNET = "BagSync [Battle.Net] tooltip color."
L.ColorItemID = "BagSync [ItemID] tooltip color."
L.ConfigHeader = "Settings for various BagSync features."
L.ConfigDisplay = "Display"
L.ConfigTooltipHeader = "Settings for the displayed BagSync tooltip information."
L.ConfigColor = "Color"
L.ConfigColorHeader = "Color settings for BagSync tooltip information."
L.ConfigMain = "Main"
L.ConfigMainHeader = "Main settings for BagSync."
L.WarningItemSearch = "WARNING: A total of [|cFFFFFFFF%s|r] items were not searched!\n\nBagSync is still waiting for the server/cache to respond.\n\nPress refresh button."
L.WarningUpdatedDB = "You have been updated to latest database version!  You will need to rescan all your characters again!|r"
L.WarningHeader = "Warning!"
L.ConfigFAQ= "FAQ / Help"
L.ConfigFAQHeader = "Frequently asked questions and help section for BagSync."
L.FAQ_Question_1 = "I'm experiencing hitching/stuttering/lagging with tooltips."
L.FAQ_Question_1_p1 = [[
This issue normally happens when there is old or corrupt data in the database, which BagSync cannot interpret.  The problem can also occur when there is overwhelming amount of data for BagSync to go through.  If you have thousands of items across multiple characters, that's a lot of data to go through within a second.  This can lead to your client stuttering for a brief moment.  Finally, another cause for this problem is having an extremely old computer.  Older computer's will experience hitching/stuttering as BagSync processes thousands of item and character data.  Newer computer's with faster CPU's and memory don't typically have this issue.

In order to fix this problem, you can try resetting the database.  This usually resolves the problem.  Use the following slash command. |cFF99CC33/bgs resetdb|r
If this does not resolve your issue, please file an issue ticket on GitHub for BagSync.
]]
L.FAQ_Question_2 = "No item data for my other WOW accounts found in a |cFFDF2B2Bsingle|r |cff3587ffBattle.net|r account."
L.FAQ_Question_2_p1 = [[
Addon's do not have the ability to read data from other WOW accounts.  This is because they don't share the same SavedVariable folder.  This is a built in limitation within Blizzard's WOW Client.  Therefore, you will not be able to see item data for multiple WOW accounts under a |cFFDF2B2Bsingle|r |cff3587ffBattle.net|r.  BagSync will only be able to read character data across multiple realms within the same WOW Account, not the entire Battle.net account.

There is a way to connect multiple WOW Accounts, within a |cFFDF2B2Bsingle|r |cff3587ffBattle.net|r account, so that they share the same SavedVariables folder.  This involves creating Symlink folders.  I will not provide assistance on this.  So don't ask!  Please visit the following guide for more details.  |cFF99CC33https://www.wowhead.com/guide=934|r
]]
L.FAQ_Question_3 = "Can you view item data from |cFFDF2B2Bmultiple|r |cff3587ffBattle.net|r Accounts?"
L.FAQ_Question_3_p1 = "No, it's not possible.  I will not provide assistance in this.  So don't ask!"
L.FAQ_Question_4 = "Can I view item data from multiple WOW accounts |cFFDF2B2Bcurrently logged in|r?"
L.FAQ_Question_4_p1 = "Currently BagSync does not support transmitting data between multiple logged in WOW accounts.  This may change in the future."
L.FAQ_Question_5 = "Why do I get a message that guild bank scanning is incomplete?"
L.FAQ_Question_5_p1 = [[
BagSync has to query the server for |cFF99CC33ALL|r your guild bank information.  It takes time for the server to transmit all the data.  In order for BagSync to properly store all your items, you must wait until the server query is complete.  When the scanning process is complete, BagSync will notify you in chat.  Leaving the Guild Bank window before the scanning process is done, will result in incorrect data being stored for your Guild Bank.
]]
L.FAQ_Question_6 = "Why do I see [FakeID] instead of [ItemID] for Battle Pets?"
L.FAQ_Question_6_p1 = [[
Blizzard does not assign ItemID's to Battle Pets for WOW.  Instead, Battle Pets in WOW are assigned a temporary PetID from the server.  This PetID is not unique and will be changed when the server resets.  In order to keep track of Battle Pets, BagSync generates a FakeID.  A FakeID is generated from static numbers associated with the Battle Pet.  Using a FakeID allows BagSync to track Battle Pets even across server resets.
]]


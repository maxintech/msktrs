class Common
   ## Cache keys
   CACHE_PLAYED_GAMES_KEY = "played.games"
   CACHE_PLAYERS_STATS_KEY = "players.stats"
   CACHE_GAME_THUMBNAIL_KEY = "game.thumb.%s"

   # URIs
   MUSKETEERS_PLAYS_URL = "https://www.boardgamegeek.com/xmlapi2/plays?username=%s&subtype=boardgame&mindate=%s&page=%s"
   GAME_INFORMATION_URL = "https://www.boardgamegeek.com/xmlapi2/thing/?id=%s&stats=1"
   FUTURE_PLAYLIST_URL = "https://www.boardgamegeek.com/xmlapi2/geeklist/243477?comments=1"

   BASE_MUSKETEERS = [ "agustinn", "flashshadow69", "gus77avo", "RaulMC" ] 
   PLAYED_GEEKLIST_IDS = [ "243963", "251571", "267195" ]
      

   ## Getters
   def self.getBaseParentsHash
      return { 
         "223555" => "169786",  # Scythe Wind Gambit
         "242277" => "169786",  # Scythe Rise of Fenris
         "204814" => "164928",  # Orleans: Trade & Intrigue
         "213984" => "25554",   # Notre Dame: 10th Anniversary Edition
         "232945" => "171623",  # Marco Polo: Agents of Venice
         "144811" => "121297",  # Fleet: Arctic Bounty
         "209323" => "183840",  # Oh My Goods!: Longsdale in revolt
         "216944" => "73439",   # Troyes: 2016 edition
         "256916" => "124361"   # Concordia Venus
         }
   end

   def self.getBasePlayedGamesHash
      return { 
         "name"=>"", "plays"=>0, 
         "avg"=>0, "rank"=>0, 
         "players"=> Hash[BASE_MUSKETEERS.collect { |i| [i, {"plays"=>0, "wins"=>0}] }] 
      }
   end   

   def self.getBasePlayerHash()
      return { 
         "plays"=>0, "wins"=>0, "ties"=>0, "secondPlace"=>0, 
         "neverWon"=>[], "mostVictorious"=>[]
      }
   end
   
   def self.getGreenGameList()
      return @@greenGameList
   end
   
   private 
   
   def self.initGreenGameList()
      return {
         "140620" => { "name" => "Lewis & Clarke", "players" => Array[BASE_MUSKETEERS] },
         "3076" => { "name" => "Puerto Rico", "players" => Array[BASE_MUSKETEERS] },
      }
   end 

   # Green Game list
   @@greenGameList = initGreenGameList()
end   
   
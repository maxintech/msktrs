require 'nokogiri'
require 'open-uri'
require 'oj'

$:.unshift(File.dirname(File.expand_path(__FILE__)))
require 'cache'
require 'common'

=begin
def obainGeeklistData(glId)
   puts("Obtaining The Musketeers Played GeekList (#{glId})...")
   uri = "https://www.boardgamegeek.com/xmlapi2/geeklist/#{glId}" 

   try = true
   doc = nil
   while (try == true) do
      doc = Nokogiri::XML(open(uri))
      set = doc.xpath("//message")
      if set.size == 0 then
	     try = false
      else
	     puts("The server is busy, trying in a few seconds...")      
         sleep 4 + rand(2)
      end   
   end
   return doc
end

def evaluatePossibleParentGame(xmlDoc)
   gameId = xmlDoc["id"]
   otype = xmlDoc["type"]
   ogameName = xmlDoc.at_xpath("name")["value"]
   set = xmlDoc.xpath("link")
   baseId = nil
   set.each { |itemDoc|
      type = itemDoc["type"]
      if (otype == "boardgameexpansion" && type == "boardgameexpansion") then 
         baseId = itemDoc["id"]      
         break
      elsif (otype == "boardgame" && type == "boardgamecompilation") then   
         if (ogameName.include?(itemDoc["value"])) then
            baseId = itemDoc["id"]      
            break
         end   
      end
   }
   puts("Warn! #{ogameName}(#{gameId}) (#{otype}) --> (#{baseId.inspect}) has rank 0.")
   return baseId
end

def processGeeklist(doc, games)
   puts("Processing the items in the geeklist...")
   newGames = []
   
   # Pass 1. Obtain ID, name and number of plays
   set = doc.xpath("//geeklist//item")
   set.each { |itemDoc|  
      gameId = itemDoc["objectid"]
      gameName = itemDoc["objectname"]
      if (games.has_key?(gameId) == false) then
         games[gameId] = { 
            "name" => gameName,
            "plays" => 0 
         }
         newGames.push(gameId)
      end
      games[gameId]["plays"] = games[gameId]["plays"] + 1
   }
   
   # Pass 2 obtain rank, avg and take note what games could have parent 
   if (newGames.size == 0) then
      return
   end   
   ids = newGames.join(",")  
   uri = "https://www.boardgamegeek.com/xmlapi2/thing/?id=#{ids}&stats=1"
   doc = Nokogiri::XML(open(uri))
   set = doc.xpath("//items//item")
   pin = []
   set.each { |itemDoc|  
      gameId = itemDoc["id"]
      avg = itemDoc.at_xpath("statistics//ratings//averageweight")["value"].to_f
      rank = itemDoc.at_xpath("statistics//ratings//ranks//rank")["value"].to_i
      games[gameId]["avg"] = avg
      games[gameId]["rank"] = rank
      if (rank == 0) then
         pin.push(itemDoc)
      end
   }      
   
   # Pass 3. Look for parent information
   rankZero = {}
   pin.each { |itemDoc|
      gameId = itemDoc["id"]
      baseId = evaluatePossibleParentGame(itemDoc)
      baseDoc = games[baseId]
      if (baseDoc.nil? == false) then
         puts("Found the rank of #{baseId} parent of #{gameId} in the cache.")
         games[gameId]["rank"] = baseDoc["rank"]
         games[gameId]["parent"] = baseId
      else   
         rankZero[baseId] = gameId
      end   
   }
   ids = rankZero.keys.join(",")
   uri = "https://www.boardgamegeek.com/xmlapi2/thing/?id=#{ids}&stats=1"
   doc = Nokogiri::XML(open(uri))
   set = doc.xpath("//items//item")
   set.each { |itemDoc|  
      baseId = itemDoc["id"]
      avg = itemDoc.at_xpath("statistics//ratings//averageweight")["value"].to_f
      rank = itemDoc.at_xpath("statistics//ratings//ranks//rank")["value"].to_i
      gameName = itemDoc.at_xpath("name")["value"]
      games[baseId] = { 
         "name" => gameName,
         "avg" => avg,
         "rank" => rank,
         "plays" => 0 
      }
      games[rankZero[baseId]]["rank"] = rank
      games[rankZero[baseId]]["parent"] = baseId
   } 
  
end

def doIt(fresh=false)
   games = {}
   if (!fresh) then   
      games = Oj.load(CacheHelper.get(CACHE_PLAYED_GAMES_KEY))         
      if (games.nil?) then
         games = {}
      end   
   end   
   PLAYED_GEEKLIST_IDS.each { |glId|
      doc = obainGeeklistData(glId)
      processGeeklist(doc, games)
   }
   CacheHelper.set(CACHE_PLAYED_GAMES_KEY, Oj.dump(games))
end


##### main
# Collect information about the Musketeers list of played games
# and add the information to the cache

fresh = false
if (ARGV.size == 1 && ARGV[0] == "fresh") then
   fresh = true
end

# cache
CacheHelper.setup()

# JSON parser
Oj.default_options = {:bigdecimal_load => :float, :mode => :compat }

doIt(fresh)

=end

def obtainDataFromUserPlays(username, startDate, location)
   page = 1
   url = Common::MUSKETEERS_PLAYS_URL % [username, startDate, page]
   playsData = []

   puts("Obtaining plays data...")
   doc = Nokogiri::XML(open(url))
   total = doc.xpath("//plays").first["total"].to_i
   pages = (total / 100) + 1
   loop do
      set = doc.xpath("//play")
      set.each { |play|  
         if (play["location"] != location) then
            next
         end   
         q = play["quantity"].to_i
         ddate = play["date"]
         playId = play["id"]
         gameId = play.at_xpath("item")["objectid"]
         players = play.xpath("players/player")
         ps = []
         players.each { |player|
            if (Common::BASE_MUSKETEERS.include?(player["username"]) == false) then
               next
            end   
            p = {
               "username" => player["username"],
               "score" => player["score"].to_f,
               "color" => player["color"],
               "won" => (player["win"].to_i == 1) ? true : false
            }   
            ps.push(p)
         }
         playsData.push({
            "playId" => playId,
            "gameId" => gameId,
            "date" => ddate,
            "players" => ps
         })
      }
      break if pages == page
      page = page + 1   
      url = Common::MUSKETEERS_PLAYS_URL % [username, startDate, page]
      doc = Nokogiri::XML(open(url))
   end  
   return playsData.sort_by! { |pd| [ pd["date"], pd["playId"].to_i ] }
end 

def groupGameByRank(v, game, rank)
#   a = rank/100
#   bot = a * 100 + 1
#   top = (a+1) * 100
   if (rank <= 100) then
      bot = 1
      top = 100
   elsif (rank <= 1000) then
      bot = 101
      top = 1000
   else
      a = rank/1000
      bot = a * 1000 + 1
      top = (a+1) * 1000
   end
   
   b = "#{bot} - #{top}"
   if (v[b].nil?) then
      v[b] = []
   end
   v[b].push(game)
end

def groupGameByWeight(v, name, avg)
   # 1.54 -> x1 = 1, x2 = 2
   # 1.49 -> x1 = 1, x2 = 1
   x1 = avg.to_i
   x2 = avg.round
   if (x1 != x2) then
      top = x2
      bot = top - 0.5
   else
      bot = x1
      top = bot + 0.5
   end
   if (top > 5) then
      top = 5.0
   end

   b = "#{bot} - #{top}"
   if (v[b].nil?) then
      v[b] = []
   end
   v[b].push(name)
end

def groupGameByCategory(v, name, categories)
   categories.each { |c|
      if (v.has_key?(c) == false) then
         v[c] = []
      end
      v[c].push(name)
   }
end

def evaluate2ndLast(play, playersData)
   # play = {gameId, date, players[{username, score, color, won}, ...]}
   
   ## Dead Last
   sorted = play["players"].sort { |v1, v2| v1["score"] <=> v2["score"] }
   first = -1234567890
   dlNames = []
   sorted.each_with_index { |o, idx| 
      name = o["username"]
      score = o["score"]
      if (idx == 0) then
         first = score
         dlNames.push(name)
      else
         if (score != first) then
            break
         else
            dlNames.push(name)
         end         
      end   
   }

   # Are all with the same score?
   if (play["players"].size == dlNames.size) then
      return
   end   

#z=play["players"].collect { |item|  {"u" => item["username"], "s" => item["score"]} }   
#z=sorted.collect { |item|  {"u" => item["username"], "s" => item["score"]} }   
#puts "2ndLast: #{play["gameId"]} => #{dlNames.inspect}, #{z.inspect}" 
  
   dlNames.each { |name|
      if (playersData[name].has_key?("deadLast") == false) then
         playersData[name]["deadLast"] = 0
      end
      playersData[name]["deadLast"] = playersData[name]["deadLast"] + 1
   }

   ## 2nd place
   sorted = play["players"].sort { |v1, v2| v2["score"] <=> v1["score"] }
   scndNames = []
   sorted.each { |o| 
      if (o["won"] == true) then
         next
      end   
      name = o["username"]
      score = o["score"]
      if (scndNames.size == 0) then
         first = score
         scndNames.push(name)
      else
         if (score != first) then
            break
         else
            scndNames.push(name)
         end         
      end
   }
   scndNames.each { |name|
      playersData[name]["secondPlace"] = playersData[name]["secondPlace"] + 1
   }
#z=sorted.collect { |item|  {"u" => item["username"], "s" => item["score"]} }   
#puts "2ndLast: #{play["gameId"]} => #{scndNames.inspect}, #{z.inspect}"   

end

def getGameCategories(xmlDoc)
   categories = []
   set = xmlDoc.xpath("link")
   set.each { |itemDoc|
      type = itemDoc["type"]
      if (type != "boardgamecategory") then 
         next
      end
      categories.push(itemDoc["value"])
   }
   return categories.uniq   
end

def processPlaysData(playsData)
   playersData = Hash[Common::BASE_MUSKETEERS.collect { |i| [i, Common::getBasePlayerHash()] }]
   baseParents = Common::getBaseParentsHash()
   gamesData = Hash[baseParents.values.collect { |i| [i, Common::getBasePlayedGamesHash()] }]

   puts("Processing plays data...")

   # 1. Process plays collecting base player stats and collecting games Ids/plays...
   playsData.each_with_index { |play, idx| 
      winners = []
      gameId = play["gameId"]

      # Check if the game id corresponds to a base Parents. If so, use the base parents game ID
      if (baseParents.has_key?(gameId) == true) then
#puts("#{gameId} has the parent: #{baseParents[gameId]}")      
         gameId = baseParents[gameId]
      end

      # Put gameId into the game's hash
      if (gamesData.has_key?(gameId) == false) then
         gamesData[gameId] = Common::getBasePlayedGamesHash()
      end
      g = gamesData[gameId]
      g["plays"] = g["plays"] + 1

      # Evaluate each players performance
      play["players"].each { |player|
         name = player["username"]
         p = playersData[name]
         g["players"][name]["plays"] = g["players"][name]["plays"] + 1
         
         p["plays"] = p["plays"] + 1
         if (player["won"] == true) then
            winners.push(name)
            p["wins"] = p["wins"] + 1
            g["players"][name]["wins"] = g["players"][name]["wins"] + 1
            
            # Allocate the last victory
            playersData[name]["lastVictory"] = { "date" => play["date"], "gameId" => gameId }
         end
      }
      
      # Evaluate ties
      if (winners.size > 1) then
         winners.each { |winner|
            playersData[winner]["ties"] = playersData[winner]["ties"] + 1
         }
      end
      
      # Evaluate 2nd, 3rd and dead last
      evaluate2ndLast(play, playersData)
   }
   
   # 2. Read avg, rank, name from gameIds (use base parents when possible)
   #   game categories 
   ids = gamesData.keys.join(",")  
   uri = Common::GAME_INFORMATION_URL % [ ids ]
   doc = Nokogiri::XML(open(uri))
   set = doc.xpath("//items//item")
   set.each { |itemDoc|  
      gameId = itemDoc["id"]
      name = itemDoc.at_xpath("name")["value"]
      avg = itemDoc.at_xpath("statistics//ratings//averageweight")["value"].to_f
      rank = itemDoc.at_xpath("statistics//ratings//ranks//rank")["value"].to_i
=begin 
DELETE hasn't any sense. All children were moved to parend Ids in step 1
      
      if (rank == 0) then
puts("#{gameId}, #{name} has rank 0")      
         if (baseParents.has_key?(gameId) == true) then
            rank = gamesData[baseParents[gameId]]["rank"]
         else
            puts("Can't find parent for #{name}(#{gameId})")
         end
      end
=end      
      if (gamesData.has_key?(gameId) == false) then
         gamesData[gameId] = Common::getBasePlayedGamesHash()
      end
      gamesData[gameId]["name"] = name
      gamesData[gameId]["avg"] = avg
      gamesData[gameId]["rank"] = rank
      gamesData[gameId]["categories"] = getGameCategories(itemDoc)
   }      
#gamesData.each { |k,v| puts("#{k}: #{v["name"]}, #{v["plays"]} plays") }   
   
   # 3. Save games'data into cache
   CacheHelper.set(Common::CACHE_PLAYED_GAMES_KEY, Oj.dump(gamesData))
   

   # 4. Takes game's name from gamesData to apply it to playersData (last victory)
   playersData.each { |p,data|
      data["lastVictory"]["gameName"] = gamesData[data["lastVictory"]["gameId"]]["name"]
   }
   
   # 5. Evaluate how many games are played once, twice, etc...
   #    And group them by BGG's ranks
   aux = {}
   aux2 = {}
   aux3 = {}
   aux4 = {}
   gamesData.each { |g,data|
      if (aux.has_key?(data["plays"]) == false) then
         aux[data["plays"]] = []
      end
      aux[data["plays"]].push(data["name"])
      
      groupGameByRank(aux2, data["name"], data["rank"])
      groupGameByWeight(aux3, data["name"], data["avg"])     
      groupGameByCategory(aux4, data["name"], data["categories"])     
   }
   aux2 = aux2.sort_by { |k,v| k.split(' ')[0].to_i }.to_h
   aux3 = aux3.sort_by { |k,v| k.split(' ')[0].to_f }.to_h

   # 5.1 Evaluate for a player what games are more successful and 
   #     what games never won
   gamesData.each { |gk, gd|    
      plays = gd["plays"]
      if (plays < 2) then
         next
      end   

      winners = {}
      gd["players"].each { |pn, pc|
         # Never won
         if (pc["wins"] == 0 && pc["plays"] > 1) then
            playersData[pn]["neverWon"].push({ 
               "gameId" => gk, 
               "gameName" => gd["name"], 
               "plays" => pc["plays"]
            })
            next
         end
         if (pc["wins"] > 0) then
            winners[pn] = pc["wins"]
         end   
      }

      # Most victorious
      winners = winners.sort_by { |k, v| -v }
      lv = -1
      winners.each {|wa|
         if (lv == -1) then
            lv = wa[1]
         end
         if (lv == wa[1]) then
            playersData[wa[0]]["mostVictorious"].push({ 
               "gameId" => gk, 
               "gameName" => gd["name"], 
               "plays" => plays,
               "victories" => lv
            })
         end
      }
#puts("game #{gd["name"]}, plays #{plays}, game #{winners}")   

   }
   playersData.each { |pk, pd|
      pd["mostVictorious"].sort! {|v1,v2| v2["victories"] <=> v1["victories"]}
#      pd["neverWon"].shuffle
      pd["neverWon"].sort! {|v1,v2| v2["plays"] <=> v1["plays"]}
#puts "#{pk}: #{pd["mostVictorious"].inspect}" 
   }
    
   # 6. Save plays/players data into cache
   ppData = {
      "totalPlays" => playsData.size,
      "players" => playersData,
      "stats" => {
         "gamesByPlays" => aux,
         "ranksGrouped" => aux2,
         "weightGrouped" => aux3,
         "categoriesGrouped" => aux4
      }
   }
   CacheHelper.set(Common::CACHE_PLAYERS_STATS_KEY, Oj.dump(ppData))
   
end


def doIt()      
   # Read Musketeers' plays information from BGG   
   startDate = "2018-01-01"
   location = "@gameday"
   username = "gus77avo"

   playsData = obtainDataFromUserPlays(username, startDate, location)
   processPlaysData(playsData)
end

##### main
# Collect information about the Musketeers list of played games
# and add the information to the cache

# cache
CacheHelper.setup()

# JSON parser
Oj.default_options = {:bigdecimal_load => :float, :mode => :compat }

doIt()

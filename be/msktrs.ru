# encoding: utf-8

require 'rack'
require 'logger'
require 'oj'
require 'nokogiri'
require 'open-uri'

$:.unshift(File.dirname(File.expand_path(__FILE__)))
require 'cache'
require 'common'

##### helpers
class LogHelper
   def self.inspectBacktrace(backtrace, n)
      if (backtrace.nil? == true) then
         return ""
      end
      len = 0
      out = ""
      backtrace.each { |b| 
         len = len + b.size
         out = out + "#{b}\n"
         if (len > n) then
            break
         end   
      }
      return out
   end
   
   def self.setup()
      $stdout.sync = true  
      @log = Logger.new($stdout)
      @log.level = Logger::DEBUG
      @log.debug("Warming up V#{SERVER_CODE_VERSION} compat:#{SERVER_CODE_COMPATIBILITY}...")
   end
   
   def self.logger
      return @log
   end   
   
   def self.elapsedTimeEx(t1, onError=false)
      t2 = Time.new
      delta = t2 - t1
      @log.info("Call x #{delta.to_s}" + ((onError) ? " on error." : "."))
      return delta
   end
   def self.elapsedTime(t1)
      return self.elapsedTimeEx(t1)
   end   
   def self.elapsedTimeOnError(t1)
      return self.elapsedTimeEx(t1, true)
   end   
   
end
class ServerException < Exception
  EXCEPTION_INTERNALERROR_CODE = 500
  EXCEPTION_INVALIDGAMECONFIGURATION_CODE = 400
  EXCEPTION_INVALIDCREDENTIALS_CODE = 401
  EXCEPTION_INVALIDQUERYARGUMENTS_CODE = 402
  EXCEPTION_FORBIDEN_CODE = 403
  EXCEPTION_NOTFOUND_CODE = 404
  EXCEPTION_ALREADYEXISTS_CODE = 405
  EXCEPTION_NOTACCEPTED_CODE = 406
  EXCEPTION_INVALIDARGUMENTS_CODE = 407
  EXCEPTION_AUTHTOKENEXPIRED_CODE = 408
  EXCEPTION_AUTHTOKENMISSING_CODE = 409
  EXCEPTION_SERVERTOOBUSY_CODE = 410

  def initialize(code = EXCEPTION_INTERNALERROR_CODE, msg = "Internal error", e=nil)
	 super(msg)
	 @error_msg = msg
	 @error_code = code
	 if e.nil? == false and e.kind_of?(Exception) == true then
		self.set_backtrace(e.backtrace)
	 end
  end

  def to_hash
	 return { 
		"error_code" => @error_code, 
		"error_message" => @error_msg
	 }
  end   

  def to_json
	 begin
		err = { 
		   "error_code" => @error_code, 
		   "error_message" => @error_msg
		}
		return Oj.dump(err)
	 rescue
		return "{ \"error_code\" : #{@error_code}, \"error_message\" : \"#{@error_msg}\" }"
	 end
  end

end
class ExceptionHelper
  def self.base(code, defaultMsg, msg=nil, e=nil)
	 message = defaultMsg
	 if msg.nil? == false then
		message = "#{message} : #{msg}"
	 end 
	 return ServerException.new(code, message, e)
  end 
  def self.internalErrorException(msg=nil, e=nil)
	 return self.base(ServerException::EXCEPTION_INTERNALERROR_CODE, 
		'Internal Error',
		msg,
		e)
  end
  def self.notAcceptedException(msg=nil, e=nil)
	 return self.base(ServerException::EXCEPTION_NOTACCEPTED_CODE, 
		'Not accepted',
		msg,
		e)
  end
end

##### EntryPoint classes
# Base class
class EntryPointBaseClass
   def execute(req)
      raise ExceptionHelper.notAcceptedException("Invalid entty point")
   end
end

# /fql
class GetFutureListEP < EntryPointBaseClass
   def getPlayers(excludes, list, playedGames)   
      players = {
         "agustinn" => { "name" => "Agustín", "color" => "#ffc107", "proposed" => 0, "excluded" => false },
         "gus77avo" => { "name" => "Gustavo", "color" => "#dc3545", "proposed" => 0, "excluded" => false },
         "flashshadow69" => { "name" => "Maxi", "color" => "#6f42c1", "proposed" => 0, "excluded" => false },
         "RaulMC" => { "name" => "Raúl", "color" => "#28a745", "proposed" => 0, "excluded" => false }
      }
      
      # update excluded attribute
      excludes.each { |ex|
         players[ex]["excluded"] = true         
      }

      # Sum up who proposed what game
      list.each { |g|
         players[g["proposedBy"]]["proposed"] = players[g["proposedBy"]]["proposed"] + 1

         # evaluate if all players included already played the game
         gameId = g["id"]
         missedPlayers = []
         if (playedGames.has_key?(gameId) == true) then
            gplayers = playedGames[gameId]["players"]
            allIn = true
            players.each { |p, v|
               if (v["excluded"] == true) then
                  next
               end
               if (gplayers.has_key?(p) == false || 
                   (gplayers.has_key?(p) == true && gplayers[p]["plays"] == 0)) then
                  allIn = false
                  missedPlayers.push(p)
               end     
            }
            g["allPlayed"] = allIn
            if (allIn == false) then
               g["missedPlayers"] = missedPlayers
            end   
         end   
      }

	 return players
   end

   def obtainListData()
      log = LogHelper.logger
      
      log.debug("obtaining The Musketeers Future GeekList...")
      uri = Common::FUTURE_PLAYLIST_URL

      try = true
      doc = nil
      while (try == true) do
         doc = Nokogiri::XML(open(uri))
         set = doc.xpath("//message")
         if set.size == 0 then
   	        try = false
         else
	        log.debug("The server is busy, trying in a few seconds...")      
            sleep 4 + rand(2)
         end   
      end
      return doc
   end
   
   def obtainThumbnailForGamesIds(gamesIds)
      log = LogHelper.logger
      thumbs = {}
      
      log.debug("obtaining thumbnail URLs for the geeklist's games...")

      ids = []
      log.debug("looking in cache for thumbnails...")
      gamesIds.each { |v|
         key = Common::CACHE_GAME_THUMBNAIL_KEY % [ v ]
         thumbnail = CacheHelper.get(key)
         if (thumbnail.nil? == true) then
            ids.push(v)
         else
            thumbs[v] = thumbnail
         end        
      }
      
      if (ids.size > 0) then
         idss = ids.join(",")
         log.debug("looking in BGG page for some thumbnails #{idss}...")
         url = Common::GAME_INFORMATION_URL % [ idss ] 
         try = true
         while (try == true) do
            doc = Nokogiri::XML(open(url))
            set = doc.xpath("//message")
            if set.size == 0 then
               try = false
            else
               sleep 4 + rand(2)
            end   
         end
         set = doc.xpath("//items//item")
         set.each { |itemDoc|  
            thumbnail = itemDoc.at_xpath("thumbnail").text
            id = itemDoc["id"]
            thumbs[id] = thumbnail
            key = Common::CACHE_GAME_THUMBNAIL_KEY % [ id ]
            CacheHelper.set(key, thumbnail)
         }
      end
      
      return thumbs
   end
   
   def getPlayedGamesFromCache()
      data = CacheHelper.get(Common::CACHE_PLAYED_GAMES_KEY)
      value = Oj.load(data)         
      return value
   end
   
   def setTag(hash, tag, match)
      hash[tag] = (match.nil? == false)
   end
   
   def parseTags(body)
      tags = {}
      setTag(tags, "kbe", body.match(/(?<tag>\@knownByEveryone)/i))
      setTag(tags, "ana", body.match(/(?<tag>\@asteriskNotAllowed)/i))
      setTag(tags, "asl", body.match(/(?<tag>\@allSessionLong)/i))
      m = body.match(/(?<tag>\@playersCount):(?<from>[2-8])-(?<to>[3-9])/i)
      if (m.nil? == false && m[:from] <= m[:to]) then
         tags["pcf"] = m[:from]
         tags["pct"] = m[:to]
         setTag(tags, "pc", m)
      else   
         setTag(tags, "pc", nil)
      end
      return tags
   end

   def filterListData(data, excludes, playedGames, sortByAgedTotal=true)
      log = LogHelper.logger
      now = Date.today
      games = []
      gamesIds = []
      baseParents = Common::getBaseParentsHash()
      greenList = Common::getGreenGameList()
      
      set = data.xpath("//geeklist//item")
      set.each { |item|
         gameId = item["objectid"]
         gameName = item["objectname"]
         sdate = DateTime.parse(item["postdate"])
         itemId = item["id"]
         gamesIds.push(gameId)
         proposedBy = item["username"]
         body = item.xpath("body").first.text         
         tags = parseTags(body)
         
         log.debug("game: #{gameName}(#{gameId}) ...")
         set2 = item.xpath("comment")
         players = []
         set2.each { |comment|         
            uname = comment["username"]    
            if (Common::BASE_MUSKETEERS.include?(uname) == false) then
               next
            end   
            if (excludes.include?(uname)) then
               next
            end
            match = comment.text.match(/\:d6\-([1-6])\:/)
            if (match.nil?) then
               next
            end
            value = match[1]
            playerDoc = { uname => value }
            players.push(playerDoc)
         }
         players.uniq! { |v| v.keys[0] }
         players.sort! { |a,b| b.values[0].to_i <=> a.values[0].to_i }
         total = players.inject(0) { |sum,hash| sum+hash.values[0].to_i }
         agedTotal = total + (((now-sdate).to_i)/7 * 0.5)
         times = playedGames.has_key?(gameId) ? playedGames[gameId]["plays"] : 0
          
         gameDoc = {
            "id" => gameId, 
            "name" => gameName,
            "item" => itemId,
            "players" => players,
            "total" => total,
            "agedTotal" => agedTotal,
            "date" => sdate.to_time.to_i,
            "played" => times,
            "proposedBy" => proposedBy,
            "tags" => tags
         }                  
         if (greenList.has_key?(gameId) == true) then
            gameDoc["inGreenList"] = true
         end
         if (times == 0) then
            if (baseParents.has_key?(gameId) == true) then
               gameDoc["hasParent"] = true
            end
         end
         games.push(gameDoc)
      }
      thumbs = obtainThumbnailForGamesIds(gamesIds)
      games.each { |v|  v["thumbnail"] = thumbs[v["id"]] }
      if (sortByAgedTotal == true) then
         games.sort_by! { |hash| [ hash["agedTotal"]*-1, hash["date"] ] }
      else
         games.sort_by! { |hash| [ hash["total"]*-1, hash["date"] ] }
      end   
      
      return games
   end
   
   def getList(excludes, playedGames, sortByAgedTotal)
      data = obtainListData()
      list = filterListData(data, excludes, playedGames, sortByAgedTotal)
      
      return list
   end
   
   def getMissingVotes(players, list)
      mv = {}
      players.keys.each { |p|
         if (players[p]["excluded"] == true) then
            next
         end   
         list.each { |v|
            h = v["players"].flat_map{|x| x.to_a}.to_h
            if (h.has_key?(p) == false) then
               mg = { 
                  "id" => v["id"],
                  "name" => v["name"]
               }
               if (mv.has_key?(p) == false) then
                  mv[p] = []
               end
               mv[p].push(mg)
            end
         }
      }
      return mv
   end
   
   def getHeader(list)
      games = list.size
      unplayed = 0
      list.each { |g|
         if (g["played"] == 0) then
            unplayed = unplayed + 1
         end   
      }
      return {
         "items" => games,
         "unplayed" => unplayed,
         "played" => (games-unplayed)
      }
   end
   
   def getWizardChoice(list)
      sortedList = list.sort_by { |hash| [ hash["total"]*-1, hash["date"] ] }

      if (list.size > 3) then 
         item = sortedList[3]
         ldx = 3;
         list.each_with_index { |i, idx| 
            if (i["id"] == item["id"]) then 
               ldx = idx
               break
            end
         }
         return ldx
      else
         return list.size-1
      end      
   end
   
   def execute(req)
      # Validating arguments...
      excludes = []
      if (req.params.has_key?("excludes")) then
         excludes = req.params["excludes"].gsub(/\s+/, "").split(",")
      end
      sortByAgedTotal = true
      if (req.params.has_key?("sortByAgedTotal")) then
         sortByAgedTotal = (req.params["sortByAgedTotal"] == "false") ? false : true
      end

      playedGames = getPlayedGamesFromCache()
      list = getList(excludes, playedGames, sortByAgedTotal)
      players = getPlayers(excludes, list, playedGames)
      header = getHeader(list)
      out = { 
         "header" => header,
         "players" => players,
         "list" => list,
         "missingVotes" => getMissingVotes(players, list),
         "wizardChoice" => getWizardChoice(list)
      }      
      return out
   end
end
   
# /cts   
class GetChartStatsEP < EntryPointBaseClass

   def getPlayers(ppData)
      players = [
         { "username" => "agustinn", "name" => "Agustín", "color" => "#ffc107", "motto" => "Me gusta mi nuevo traje con forro suavecito." },
         { "username" => "gus77avo", "name" => "Gustavo", "color" => "#dc3545", "motto" => "¿Cómo puedo ser tan malo en todo lo que intento y ser tan genial?" },
         { "username" => "flashshadow69", "name" => "Maxi", "color" => "#6f42c1", "motto" => "Debo hacer algo... pero ya me puse la piyama." },
         { "username" => "RaulMC", "name" => "Raúl", "color" => "#28a745", "motto" => "Lo importante es no asustarse, hay reglas para situaciones como esta." }
      ]
      players.each { |p|
         username = p["username"] 
         ppp = ppData["players"][username]
         p["plays"] = ppp["plays"]
         p["wins"] = ppp["wins"]
         p["ties"] = ppp["ties"]
         p["deadLast"] = ppp["deadLast"]
         p["lastVictory"] = ppp["lastVictory"]
         p["secondPlace"] = ppp["secondPlace"]
         p["mostVictorious"] = ppp["mostVictorious"]
         p["neverWon"] = ppp["neverWon"]
      }
      
      return players.shuffle
   end
   
   def getGamesByPlays(ppData)
      outcome = {}
      # Put together games with 5+ games
      aux = { "5+" => [] }
      ppData["stats"]["gamesByPlays"].each { |k,v| 
         if (k.to_i < 5) then
            aux[k] = v
         else
            aux["5+"].push(*v)
         end
      }
      aux.each { |k,v| 
         games = (v.size < 10) ? v : []   
         outcome[k] = { "size" => v.size, "games"=> games }
      }
      return outcome
   end
   
   def getBGGRankingGrouped(ppData)
      outcome = {}
      ppData["stats"]["ranksGrouped"].each { |k,v| 
         games = (v.size < 10) ? v : []   
         outcome[k] = { "size" => v.size, "games"=> games }
      }
      return outcome
   end
   
   def getBGGWeightGrouped(ppData)
      outcome = {}
      ppData["stats"]["weightGrouped"].each { |k,v| 
         games = (v.size < 10) ? v : []   
         outcome[k] = { "size" => v.size, "games"=> games }
      }
      return outcome
   end
   
   def getBGGCategoriesGrouped(ppData)
      outcome = {}
      limit = 7
      others = { "size" => limit-1, "games" => [] }
      ppData["stats"]["categoriesGrouped"].each { |k,v| 
         if (v.size < limit) then
            others["games"].push("#{k}: #{v.size}")
         else
            games = v
            outcome[k] = { "size" => v.size, "games"=> games }
         end   
      }
      outcome["Others"] = others

      return outcome.sort_by {|k,v| v["size"]*-1 }.to_h
   end
   
   def execute(req)
      # Validating arguments...
      
      ppData = Oj.load(CacheHelper.get(Common::CACHE_PLAYERS_STATS_KEY))
      players = getPlayers(ppData)
      
      outcome = {
         "totalPlays" => ppData["totalPlays"],
         "players" => players,
         "stats" => {
            "gamesByPlays" => getGamesByPlays(ppData),
            "bggRankingGrouped" => getBGGRankingGrouped(ppData),
            "bggWeightGrouped" => getBGGWeightGrouped(ppData),
            "bggCategoriesGrouped" => getBGGCategoriesGrouped(ppData)
         }
      }
      
      return outcome
   end   
end


##### MusketeersAdapter class
# Mapping /_msktrsbe

SERVER_CODE_COMPATIBILITY = 1
SERVER_CODE_VERSION = 13

class MusketeersAdapter

   def initialize()
      super()
      @epMap = {
         "/fql" => GetFutureListEP.new(),
         "/cts" => GetChartStatsEP.new()
      }
   end	 

   # call. Startup point by Rack to process the request
   def call(env)
      t1 = Time.new
      log = LogHelper.logger

      begin
         req = Rack::Request.new(env)
         # Detecting method and reject other than GET method
         body = req.body.read
         log.debug("METHOD: #{req.request_method}")
         log.debug("params: #{req.params.inspect}")
         log.debug("path / pathInfo: [#{req.path}] [#{req.path_info}]")

         if req.request_method != 'GET' then
            raise ExceptionHelper.notAcceptedException("Invalid HTTP Method")
         end
         
         # Look for in the map an executes the code
         if (@epMap.has_key?(req.path_info)) then
            ep = @epMap[req.path_info]
         else
            ep = EntryPointBaseClass.new()
         end
         out = ep.execute(req)
         t2 = LogHelper.elapsedTime(t1)
         st = Time.new
         sts = "#{st.to_i}.#{st.nsec}"
         meta = {
            "serverTime" => sts,
            "delta" => t2,
            "version" => SERVER_CODE_VERSION,
            "compatibility" => SERVER_CODE_COMPATIBILITY
         }
         out["meta"] = meta         
         outJson = Oj.dump(out)
          
         # Return JSON output
         [
            200, 
            { 'Content-Type' => 'application/json' },
            [ outJson ]
         ]
      rescue ServerException => e
         log.error("catch E (#{e.to_s})\n #{LogHelper.inspectBacktrace(e.backtrace, 500)}")   
         log.info("json out: #{e.to_json.inspect}")
         LogHelper.elapsedTimeOnError(t1)
         [
            200,
            { "Content-Type" => "application/json" },
            [ e.to_json ]
         ]
      rescue Exception => e
         log.error("catch E (#{e.to_s})\n #{LogHelper.inspectBacktrace(e.backtrace, 500)}")   
         log.info("json out: #{ExceptionHelper.internalErrorException().to_json.inspect}")
         LogHelper.elapsedTimeOnError(t1)
         [
            200,
            { "Content-Type" => "application/json" },
            [ ExceptionHelper.internalErrorException().to_json ]
         ]
      end
   end   

end


##### main

# logger
LogHelper.setup()
# cache
CacheHelper.setup()

# JSON parser
Oj.default_options = {:bigdecimal_load => :float, :mode => :compat }

# Rack up!
app = Rack::URLMap.new('/_msktrsbe' => MusketeersAdapter.new)
run Rack::Lint.new(app)

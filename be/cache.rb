require 'redis'
require 'msgpack'


##### Cache
class BaseCache

  ## Overridable methods by subclass 
  ## 

  def get(key)
	 cacheConn = BaseCache.redisConn
	 # 1. Check if mem cache is enabled
	 if (cacheConn.nil? == false) then
		# 2.1. If is enabled. Check if is in the mem cache
		value = getRedisKeyValuePair(cacheConn, key)
		# 2.1.1. If is in mem cache return data 
		if (value.nil? == false) then
		   return translateRedisValueToRuby(value)
		else
		   # 2.1.2. If is not in the cache return nil
		   return nil
		end
	 else      
		# 2.2. If is not the cache enabled return nil
		return nil
	 end
  end
  
  def set(key, value)
	 cacheConn = BaseCache.redisConn
	 # 1. Check if mem cache is enabled
	 if (cacheConn.nil? == false) then
		# 1.1. If is enabled. Check if the value is overridable
		if (isKeyOverridable(key) == true) then
		   # 1.1.1. If is overridable. Set the value
		   setRedisKeyValuePair(cacheConn, key, value)
		else
		   # 1.1.2. If is not overridable. Get the value
		   value = getRedisKeyValuePair(cacheConn, key)
		   if (value.nil? == true) then
			  # 1.1.2.1. If the value is nil, Set the value
			  setRedisKeyValuePair(cacheConn, key, entityDoc)
		   else   
			  # 1.1.2.2. If the value is not nil, do nothing
		   end
		end
	 else      
		# 2.2. If is not the cache enabled return nil
		return nil
	 end
  end
  
  def isKeyOverridable(key)
	 return true
  end    
		  
  # Obtain a value given a key in Redis
  def getRedisKeyValuePair(r, key)
	 keys = translateRedisKeys(key)
	 if (keys.size == 1) then
		return r.get(keys[0])
	 elsif (keys.size == 2) then
		return r.hget(keys[0], keys[1])
	 else
		return nil
	 end
  end

  # Traslate ruby key into Redis key. Default behaviour use the same value
  def translateRedisKeys(key)
	 return [ key ]
  end
		 
  # Translate the value stored in Redis to be readable in Ruby
  def translateRedisValueToRuby(value)
	 return Oj.load(value, {:mode => :compat})
  end 

  # Set a value into Redis
  def setRedisKeyValuePair(r, key, entityDoc)
	 value = translateRubyValueToRedis(entityDoc)
	 keys = translateRedisKeys(key)
	 if (keys.size == 1) then
		r.set(keys[0], value, obtainSetRedisOptions(key))
	 elsif (keys.size == 2) then
		r.hset(keys[0], keys[1], value)
	 end
  end
		
  # Translate the Ruby object into a something Redis could understand
  def translateRubyValueToRedis(value)
	 return Oj.dump(value, {:mode => :compat})
  end 

  def obtainSetRedisOptions(key)
	 return {}
  end
  

  private

  @redisConn = nil     

  def self.redisConn
	 begin 
		if (@redisConn.nil? == true) then
		   @redisConn = Redis.new
		else
		   # test if the connection still alive             
		   begin
			  @redisConn.ping
		   rescue Exception => e
			  @redisConn = Redis.new
		   end                     
		end
		return @redisConn
	 rescue
		return nil
	 end      
  end
			  
end

class BaseBinaryCache < BaseCache
  ## Overrides...

  # Translate the value stored in Redis to be readable in Ruby
  def translateRedisValueToRuby(value)
	 return MessagePack.unpack(value)
  end 

  # Translate the Ruby object into a something Redis could understand
  def translateRubyValueToRedis(value)
	 return MessagePack.pack(value)
  end 
end

class MsktrCache < BaseBinaryCache
      ## Overrides...

      def translateRedisKeys(key)
         newKey = "mk.#{key}"
         return [ newKey ]
      end
end

class CacheHelper
   def self.setup()
      @cache = MsktrCache.new
   end	 
   def self.set(k, v)
      @cache.set(k, v)
   end   
   def self.get(k)
      return @cache.get(k)
   end   
end

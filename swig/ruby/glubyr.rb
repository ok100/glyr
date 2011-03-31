require 'rubygems'

begin 
	require '../glyr'
rescue LoadError
	print "FATAL: glyr.so could not be loaded.. :-("
end

=begin
= Simple libglyr wrapper with more Objectlike approach
= as the pure bindings (which are actually the same as in C)
=end

class Glubyr
        # Called when object is destroyed
        # Does cleanup work, frees memory..
        # The dector of CacheList is not called
        # because it was created in libglyr by a call to malloc()
        def Glubyr.finalize(id)
                #puts "Object #{id} dying at #{Time.new}"
                Glyr::freeList(@cache_list)
        end

        def initialize
                @cache_list = nil
                @query = Glyr::GlyQuery.new
               
                # Register finalize to be called on death of object (Gevatter GarbageCollector)
                ObjectSpace.define_finalizer(self,self.class.method(:finalize).to_proc)
        end 

        ## -- PUBLIC GET/SET ##

	def reset
		@query = nil
		Glyr::freeList(@cache_list)
		@query = Glyr::GlyQuery.new
	end

        def getLyrics(artist,album,title)
                @query.artist = artist
                @query.album  = album
                @query.title  = title
                @query.type   = Glyr::GET_LYRIC
                call_get
        end

        def getCover(artist, album)
                @query.artist = artist
                @query.album  = album
                @query.type   = Glyr::GET_COVER
                call_get
        end

        def getPhotos( artist )
                @query.artist = artist
                @query.type   = Glyr::GET_PHOTO
                call_get
        end

        def getAinfo( artist )
                @query.artist = artist
                @query.type   = Glyr::GET_AINFO
                call_get
        end

        def getSimiliar( artist )
                @query.artist = artist
                @query.type   = Glyr::GET_SIMILIAR
                call_get
        end

        def getReview( album )
                @query.album = album
                @query.type   = Glyr::GET_REVIEW
                call_ge
        end

        def version
                return Glyr::version()
        end

        def quiet!
                @query.verbosity = 0
        end

        def verbose! 
                @query.verbosity = 2
        end

        def debug! 
                @query.verbosity = 3
        end       

	def type
		return @query.type
	end

        # return bytes written
        def writeBinaryCache( path, cache ) 
                return Glyr::write(path, cache, ".", "data", @query)
        end

        def number=( num )
                Glyr::GlyOpt_number(@query,num)
        end

        def number
                return @query.number
        end

        def plugmax=( num )
                Glyr::GlyOpt_plugmax(@query,num)
        end

        def plugmax
                return @query.plugmax
        end

        def lang= ( code )
                Glyr::GlyOpt_lang(@query,code)
        end

        def lang 
                return @query.lang
        end

        def curlopt=( timeout, redirects, parallel )
                Glyr::GlyOpt_timeout(@query,timeout)
                Glyr::GlyOpt_redirects(@query,redirects)
                Glyr::GlyOpt_parallel(@query,parallel)
        end

        def curlopt
                return @query.timeout,@query.redirects,@query.parallel
        end

        def coverSize=( min, max ) 
                Glyr::GlyOpt_cminsize(@query,min);
                Glyr::GlyOpt_cmaxsize(@query,max);
        end

        def coverSize
                return @query.cover.min_size, @query.cover.max_size
        end

        def from=( argstring )
                Glyr::GlyOpt_from(@query,argstring)
        end

        def download=( boolean )
                Glyr::GlyOpt_download(@query,boolean)
        end

        def download?
                return @query.download
        end

        def color=( boolean )
                Glyr::GlyOpt_color(@query,boolean)
        end
       
	def fuzzynes( fuzzval ) 
		Glyr::GlyOpt_fuzzyness(@query,fuzzval)
	end
 
	def fuzzyness 
		return @query.fuzzyness
	end

        def color?
                return @query.color
        end

	def grouped_download?
		return @query.grouped_download
	end

	def grouped_download( make_it_grouped )
		Glyr::GlyOpt_groupedDL(@query,make_it_grouped)
	end

	def formats
		return @query.formats
	end

	def formats( allowed_formats )
		Glyr::GlyOpt_formats(@query, allowed_formats)
	end

	def call_direct_use
		return @query.call_direct.use
	end

	def call_direct_use=(icall)
		Glyr::GlyOpt_call_direct_use(@query,icall)
	end

	def call_direct_provider=(provider_string)
		Glyr::GlyOpt_call_direct_provider(@query,provider_string)
	end

	def call_direct_provider
		return @query.call_direct.provider
	end

	def call_direct_url
		return @query.call_direct.url
	end

	def call_direct_url=(url_string)
		return Glyr::GlyOpt_call_direct_url(url_string)
	end
	
        # ------ 
        private
        # ------
        
        def call_get
                @cache_list = Glyr::get(@query,nil)

                convert = []

                # convert to a normal Ruby Array
                # cachelist is of no use in such a powerful language
                @cache_list.size.times do |iter|
                       convert << Glyr::list_at(@cache_list,iter) 
                end

                return convert
        end
end

m = Glubyr.new
puts m.call_direct_use = true
puts m.call_direct_provider = "a"
puts m.get_cover(
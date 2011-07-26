# What #
This tiny little library is an example of code I wrote for [LisaUSA](http://lisausa.net) when I was tasked with migrating [LISA](http://lisausa.net) from REE to JRuby.  

# Why #
Prior to the migration [LISA](http://lisausa.net) made use of a curl gem for some web service requests. This gem was not JRuby friendly (libcurl has C extensions that are not supported for JRuby).  

I was not interested in reengineering how these web services operated so I set out to recreate the libcurl behaviors we were using with the REE version of [LISA](http://lisausa.net). This way I was able to just drop Rurl in place. 

I was not able to find a lot of help on the tubes when I set out on this task so I thought I'd publish an example of what I did to make this all work. My employer agreed and so here it is.

# How #
*   You'll need apache commons [http-client](http://hc.apache.org/httpcomponents-client-ga/index.html) and have them somewhere `java_import` can find it. 
*   Have conn_manager and rurl be available to your app. We're a rails shop so all of this is in our `lib` dir. 
*   I used JarJar to package up the common libs to avoid version conflicts with torquebox (hacky i know). You'll want to change the associated `java_imports` back to the proper package name. 

## Modes ##
There are two ways to perform a connection with Rurl. 

#### One shot ####
do something like this:

	url = "http://your.webservice.com"
	timeout = 250.seconds
	@connection = Rurl.new(url, timeout)
	Timeout::timeout(timeout) { @connection.perform }
	str = @connection.body_str


#### Chunky ####
Using a parser to analyze the results as it comes down the wire. 

	doc    = SearchResultsDocument.new
	parser = Nokogiri::XML::SAX::Parser.new(doc)
	http_request = lambda {
      connection         = Rurl.new(url, MAX_SECONDS)
      connection.headers = LISA_HTTP_HEADER
      connection.on_body do |data|
         parser << data
      end

      begin
        connection.perform
      rescue Nokogiri::XML::SyntaxError => se
        log "#{se.class}: Error: #{se}: URL: #{url}"
      end
    }

	Timeout::timeout(MAX_SECONDS) { http_request.call }
	
	doc.results
	
NoteL `SearchResultsDocument` isa Nokogiri::XML::SAX::Document that helps us parse our xml. and `LISA_HTTP_HEADER` is simply our connection headers. 


# Later #
I hope this helps someone out, or if you can help me out by pointing out bugs or better ways of doing things with this code let me know! 

Thanks for checking it out. 


	
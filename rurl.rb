require 'java'

java_import com.lisa.http.HttpResponse
java_import java.io.InputStream
java_import java.io.InputStreamReader
java_import com.lisa.http.impl.client.DefaultHttpClient
java_import com.lisa.http.client.methods.HttpGet
java_import java.io.BufferedReader
java_import com.lisa.http.util.EntityUtils
java_import java.io.DataInputStream
java_import com.lisa.http.params.HttpConnectionParams

class Rurl
  attr_reader :body_str, :content_type
  CHUNK_SIZE = 1048576

  def initialize(url, time_out=15.seconds)
    cm     = ConnManager.instance.connection
    params = com.lisa.http.params.BasicHttpParams.new()
    HttpConnectionParams.setConnectionTimeout(params, TimeUnit::SECONDS.toMillis(time_out.to_i))
    HttpConnectionParams.setSoTimeout(params, TimeUnit::SECONDS.toMillis(time_out.to_i))
    @url        = url
    @httpclient = DefaultHttpClient.new(cm, params)
    @method     = HttpGet.new url
    @body_str   = ''
  end

  def headers=(h)
    h.each { |key, value|
      @method.set_header(key, value)
    }
  end

  def perform
    begin
      response      = @httpclient.execute @method
      entity        = response.getEntity
      java_ins      = entity.getContent
      in_stream     = java_ins.to_io
      @content_type = entity.getContentType.getValue

      if block_given?
        while !in_stream.eof?
          yield(in_stream.readpartial(CHUNK_SIZE))
        end
      else
        while !in_stream.eof?
          @body_str << in_stream.readpartial(CHUNK_SIZE)
        end
      end
 
    rescue => e
      raise e
    ensure
      java_ins.close() if java_ins
      in_stream.close if in_stream
      EntityUtils.consume entity if entity
    end
  end
end
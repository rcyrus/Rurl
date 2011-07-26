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
  attr_reader :body_str

  def initialize(url, time_out=15.seconds)
    cm     = ConnManager.instance.connection
    params = com.lisa.http.params.BasicHttpParams.new()
    HttpConnectionParams.setConnectionTimeout(params, TimeUnit::SECONDS.toMillis(time_out.to_i))
    HttpConnectionParams.setSoTimeout(params, TimeUnit::SECONDS.toMillis(time_out.to_i))
    @url        = url
    @httpclient = DefaultHttpClient.new(cm, params)
    @method     = HttpGet.new url
    @body_str   = ''
    @on_body    = lambda { |data| @body_str << data }
  end

  def headers=(h)
    h.each { |key, value|
      @method.set_header(key, value)
    }
  end

  def on_body(&block)
    @on_body = block
  end

  def perform
    begin
      response    = @httpclient.execute @method
      entity      = response.getEntity
      in_stream   = entity.getContent
      data_stream = DataInputStream.new(in_stream)
      rd          = BufferedReader.new(InputStreamReader.new data_stream)

      while (line = rd.readLine)
        begin
          @on_body.call(line)
          #rescue => e
          #  #derp
          #end
        end
      end
    rescue => e
      @method.abort
      raise e
    ensure
      in_stream.close() if in_stream
      EntityUtils.consume entity if entity
    end
  end
end
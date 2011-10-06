class ConnManager
  require 'java'
  require 'idle_connection_killer'
  require 'singleton'
  java_import com.lisa.http.impl.client.DefaultHttpClient
  java_import com.lisa.http.impl.conn.tsccm.ThreadSafeClientConnManager
  java_import java.util.concurrent.TimeUnit
  java_import com.lisa.http.conn.scheme.Scheme
  java_import com.lisa.http.conn.scheme.PlainSocketFactory
  java_import com.lisa.http.conn.scheme.SchemeRegistry


  include Singleton

  attr_reader :connection

  def initialize
    http = Scheme.new("http", 80, PlainSocketFactory.getSocketFactory())
    sr   = SchemeRegistry.new()
    sr.register(http)
    @cm = ThreadSafeClientConnManager.new(sr, 5, TimeUnit::SECONDS)
    @cm.setMaxTotal 200
    @cm.setDefaultMaxPerRoute 20

    params = com.lisa.http.params.BasicHttpParams.new()
    HttpConnectionParams.setConnectionTimeout(params, TimeUnit::SECONDS.toMillis(30.to_i))
    HttpConnectionParams.setSoTimeout(params, TimeUnit::SECONDS.toMillis(30.to_i))
    @httpclient = DefaultHttpClient.new(@cm, params)
    connKiller = IdleConnectionKiller.new(@cm)
    connKiller.start()
  end

end

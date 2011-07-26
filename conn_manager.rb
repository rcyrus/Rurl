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
    @connection = ThreadSafeClientConnManager.new(sr, 5, TimeUnit::SECONDS)
    @connection.setMaxTotal 200
    @connection.setDefaultMaxPerRoute 20
    connKiller = IdleConnectionKiller.new(@connection)
    connKiller.start()
  end

end

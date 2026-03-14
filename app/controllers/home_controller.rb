class HomeController < ApplicationController
  def index
    @ruby_version = RUBY_VERSION
    @rails_version = Rails.version
    @current_time = Time.current
    @db_adapter = ActiveRecord::Base.connection.adapter_name

    @redis_status = begin
      redis = Redis.new(url: ENV["REDIS_URL"])
      redis.ping == "PONG" ? "Connected" : "Error"
    rescue => e
      "Error: #{e.message}"
    end
  end
end

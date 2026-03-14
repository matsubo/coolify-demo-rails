require "net/http"
require "json"

class HomeController < ApplicationController
  def index
    @ruby_version = RUBY_VERSION
    @rails_version = Rails.version
    @current_time = Time.current
    @db_adapter = ActiveRecord::Base.connection.adapter_name

    @redis_status = check_redis
    @ollama_status, @ollama_models = check_ollama
    @messages = Message.order(created_at: :desc).limit(20).reverse
  end

  def chat
    prompt = params[:prompt].to_s.strip
    if prompt.empty?
      redirect_to root_path
      return
    end

    Message.create!(role: "user", content: prompt)

    response = chat_with_ollama(prompt)
    Message.create!(role: "assistant", content: response)

    redirect_to root_path
  end

  private

  def check_redis
    redis = Redis.new(url: ENV["REDIS_URL"])
    redis.ping == "PONG" ? "Connected" : "Error"
  rescue => e
    "Error: #{e.message}"
  end

  def check_ollama
    uri = URI("#{ENV['OLLAMA_URL']}/api/tags")
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      models = data["models"]&.map { |m| m["name"] } || []
      ["Connected", models]
    else
      ["Error: HTTP #{response.code}", []]
    end
  rescue => e
    ["Error: #{e.message}", []]
  end

  def chat_with_ollama(prompt)
    uri = URI("#{ENV['OLLAMA_URL']}/api/generate")
    body = { model: "tinyllama", prompt: prompt, stream: false }.to_json
    response = Net::HTTP.post(uri, body, "Content-Type" => "application/json")
    JSON.parse(response.body)["response"]
  rescue => e
    "Error: #{e.message}"
  end
end

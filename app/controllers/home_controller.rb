class HomeController < ApplicationController
  def index
    @ruby_version = RUBY_VERSION
    @rails_version = Rails.version
    @current_time = Time.current
  end
end

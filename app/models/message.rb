class Message < ApplicationRecord
  validates :role, presence: true, inclusion: { in: %w[user assistant] }
  validates :content, presence: true
end

class Family < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :profiles, dependent: :destroy
  validates :name, presence: true
end

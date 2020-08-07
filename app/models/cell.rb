class Cell < ApplicationRecord
  has_many :crystals
  has_one :token

  validates_uniqueness_of :x, scope: :y
end

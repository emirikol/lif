class Cell < ApplicationRecord
  has_one :crystal
  has_one :token

  validates_uniqueness_of :x, scope: :y
end

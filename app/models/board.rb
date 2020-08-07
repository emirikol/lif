class Board < ApplicationRecord

  def activate!
    self.class.activate(self.id)
    reload
  end

  def self.activate id
    transaction do 
      update_all(active: false)
      find(id).update_attributes!(active: true)
    end
  end
end

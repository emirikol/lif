class Crystal < ApplicationRecord
  belongs_to :cell

  def self.active
    where(board_id: Board.where(active: true).first.id)
  end

  def live
    state =='live' || state == 'lit'
  end

  def dead
    state == 'dead'
  end

  def light!
    update_attributes(state: state == 'dead' ? :lit : :dead)
  end
end

class Crystal < ApplicationRecord
  belongs_to :cell

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

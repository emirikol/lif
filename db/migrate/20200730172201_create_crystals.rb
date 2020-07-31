class CreateCrystals < ActiveRecord::Migration[6.0]
  def change
    create_table :crystals do |t|
      t.references :cell
      t.string :state, default: :dead
    end
  end
end

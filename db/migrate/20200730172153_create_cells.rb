class CreateCells < ActiveRecord::Migration[6.0]
  def change
    create_table :cells do |t|
      t.integer :x, :y
    end
  end
end

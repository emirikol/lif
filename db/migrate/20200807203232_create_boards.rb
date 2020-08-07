class CreateBoards < ActiveRecord::Migration[6.0]
  def change
    create_table :boards do |t|
      t.boolean :active, default: false
    end
    add_column :crystals, :board_id, :integer
    b = Board.create!(active: true)
    Crystal.update_all(board_id: b.id)
  end
end

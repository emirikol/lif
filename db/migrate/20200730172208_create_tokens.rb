class CreateTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :tokens do |t|
      t.references :cell
      t.string :name, :color
    end
  end
end

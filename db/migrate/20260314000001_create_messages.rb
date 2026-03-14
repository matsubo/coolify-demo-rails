class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.string :role, null: false
      t.text :content, null: false
      t.timestamps
    end
  end
end

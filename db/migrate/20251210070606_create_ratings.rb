class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps

      t.index [:post_id, :user_id], unique: true
      t.check_constraint 'value >= 1 AND value <= 5', name: 'value_range'
    end
  end
end

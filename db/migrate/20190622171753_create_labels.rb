class CreateLabels < ActiveRecord::Migration[5.2]
  def change
    create_table :labels do |t|
      t.references :destination, foreign_key: true
      t.string :tag
      t.float :score

      t.timestamps
    end
  end
end

class CreateRecordings < ActiveRecord::Migration
  def change
    create_table :recordings do |t|
      t.string :url
      t.text :transcription
      t.string :phone_number

      t.timestamps
    end
  end
end

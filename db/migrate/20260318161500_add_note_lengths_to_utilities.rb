class AddNoteLengthsToUtilities < ActiveRecord::Migration[6.0]
  def change
    add_column :utilities, :short_note_length, :integer, default: 50
    add_column :utilities, :long_note_length, :integer, default: 100
  end
end

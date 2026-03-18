class ChangeNoteTypeToInteger < ActiveRecord::Migration[6.1]
  def change
    change_column :notes, :note_type, :integer, 
      using: "CASE WHEN note_type = 'review' THEN 0 WHEN note_type = 'critique' THEN 1 ELSE NULL END"
  end
end

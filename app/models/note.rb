# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  title      :string
#  content    :text
#  note_type  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint(8)        not null
#
class Note < ApplicationRecord
  enum note_type: { review: 0, critique: 1 }

  validates :title, :content, :note_type, presence: true
  validate :review_length

  belongs_to :user
  belongs_to :book

  def review_length
    return unless note_type == 'review'
    if content.blank?
      errors.add(:content, "can't be blank")
      return
    end

    length = book.utility.note_length(content)

    return if length == 'short'
    max_words = book.utility.short_note_length
    errors.add(:content, "must be #{max_words} words long or less")
  end
end

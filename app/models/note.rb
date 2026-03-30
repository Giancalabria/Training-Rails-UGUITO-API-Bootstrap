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
  has_one :utility, through: :user

  def note_length
    return if content.blank?
    book.utility.note_length(word_count)
  end

  def word_count
    content.split.length
  end

  private

  def review_length
    return unless note_type == 'review' && note_length != 'short'
    errors.add(:content, "must be #{book.utility.short_note_length} words long or less")
  end
end

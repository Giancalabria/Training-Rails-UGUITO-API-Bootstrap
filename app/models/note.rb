class Note < ApplicationRecord
  enum note_type: { review: 'review', critique: 'critique' }

  validates :title, :content, :note_type, presence: true
  validate :review_length

  belongs_to :user
  belongs_to :book

  def word_count
    content.split.length
  end

  def content_length
    count = word_count

    utility = user.utility

    if utility.class.name == 'NorthUtility'
      range = [50, 100]
    else
      range = [60, 120]
    end

    case count
    when 0..range[0]
      'short'
    when (range[0] + 1)..range[1]
      'medium'
    else
      'long'
    end
  end

  def review_length
    if note_type == 'review' && content_length != 'short'
      errors.add(:content, "must be short for review notes")
    end
  end
end

class Note < ApplicationRecord
  enum note_type: { review: 'review', critique: 'critique' }

  validates :title, :content, :note_type, presence: true
  validate :review_length

  belongs_to :user
  belongs_to :book

  def word_count
    return 0 if content.blank?
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
    return unless note_type == 'review'

    if content_length != 'short'
      limit = user.utility.class.name == 'NorthUtility' ? 50 : 60
      errors.add(:content, "must be less than #{limit} words")
    end
  end
end

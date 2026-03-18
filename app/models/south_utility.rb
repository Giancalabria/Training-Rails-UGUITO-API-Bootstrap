class SouthUtility < Utility
  def note_length(content)
    count = content.split.length
    range = [60, 120]

    case count
    when 0..range[0]
      'short'
    when (range[0] + 1)..range[1]
      'medium'
    else
      'long'
    end
  end
end

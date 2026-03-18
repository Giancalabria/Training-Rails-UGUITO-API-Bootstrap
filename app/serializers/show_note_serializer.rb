class ShowNoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :note_type, :word_count, :created_at, :content, :content_length
  belongs_to :user, serializer: UserShowNoteSerializer

  def word_count
    object.content.split.length
  end

  def content_length
    object.user.utility.note_length(object.content)
  end
end

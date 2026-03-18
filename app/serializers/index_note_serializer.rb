class IndexNoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :note_type, :content_length

  def content_length
    object.user.utility.note_length(object.content)
  end
end

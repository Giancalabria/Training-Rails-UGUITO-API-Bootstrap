class IndexNoteAsyncSerializer < ActiveModel::Serializer
  attributes :title, :note_type, :created_at, :content
  belongs_to :user, serializer: UserAsyncNoteSerializer
  belongs_to :book, serializer: BookNoteAsyncSerializer
end

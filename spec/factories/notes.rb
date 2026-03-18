FactoryBot.define do
  factory :note do
    user
    book
    title { Faker::Name.unique.name }
    content { Faker::Lorem.paragraph(sentence_count: 10) }
    note_type { %w[review critique].sample }
  end
end

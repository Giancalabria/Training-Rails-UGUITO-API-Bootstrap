FactoryBot.define do
  factory :note do
    user
    book
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph(sentence_count: 10) }
    note_type { ['review', 'critique'].sample }
  end
end

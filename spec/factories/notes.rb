FactoryBot.define do
  factory :note do
    user
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.sentence(word_count: 30)}
    note_type {['review', 'critique'].sample }
  end
end

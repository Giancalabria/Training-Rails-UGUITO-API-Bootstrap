FactoryBot.define do
  factory :note do
    user
    book
    title { Faker::Name.unique.name }
    content { Faker::Lorem.words(number: 40).join(' ') }
    note_type { %w[review critique].sample }
  end
end

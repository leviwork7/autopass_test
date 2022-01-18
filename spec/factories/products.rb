# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { Faker::Book.title }
    price { 1000 }
  end
end

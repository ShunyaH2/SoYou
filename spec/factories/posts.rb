FactoryBot.define do
  factory :post do
    body { "test" }
    occurred_on { Date.current }

    association :user
  end

  factory :empty_post, class: "Post" do
    body { "" }
    occurred_on { Date.current }

    association :user
  end
end

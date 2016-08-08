FactoryGirl.define do
  factory :micropost do
    content { 'foobar' }

    user
  end
end

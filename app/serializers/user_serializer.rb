class UserSerializer < BaseSerializer
  attributes(*User.attribute_names.map(&:to_sym))

  has_many :microposts
end

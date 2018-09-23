class Api::V1::MicropostSerializer < Api::V1::BaseSerializer
  attributes(*Micropost.attribute_names.map(&:to_sym))

  belongs_to :user, serializer: Api::V1::UserSerializer do
    generic :skip_data, true
    link :related, ->(obj,s) {s.api_v1_user_path(obj.user_id)}
  end

  def picture
    object.picture.url
  end
end

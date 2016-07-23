class MicropostSerializer < BaseSerializer
  attributes(*Micropost.attribute_names.map(&:to_sym))
end

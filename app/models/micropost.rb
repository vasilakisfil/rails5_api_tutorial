# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :text
#  picture    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_microposts_on_user_id  (user_id)
#

class Micropost < ApplicationRecord
  belongs_to :user, counter_cache: true

  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size

  private

    # Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end

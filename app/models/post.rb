class Post < ApplicationRecord
  belongs_to :user
  # order the output by most recent post first
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :image_size

  mount_uploader :image, ImageUploader

  private
    def image_size
      if image.size > 5.megabytes
        errors.add(:image, "should be less than 5MB")
      end
    end
end

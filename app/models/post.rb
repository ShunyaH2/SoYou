class Post < ApplicationRecord
  belongs_to :user

  # 投稿は複数プロフィールと紐づく
  has_many :post_profiles, dependent: :destroy
  has_many :profiles, through: :post_profiles

  validates :body, presence: true, length: { maximum: 2000 }
  validates :occurred_on, presence: true

  def short_body(length = 20)
    body.to_s.truncate(length)
  end
end

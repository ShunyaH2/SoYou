class Profile < ApplicationRecord
  belongs_to :family # 家族に必ず属する
  belongs_to :user, optional: true # 子供等はuser直結でなくてもOK
  
  # プロフィールは複数投稿と結びつく
  has_many :post_profiles, dependent: :destroy
  has_many :posts, through: :post_profiles
  validates :name, presence: true, length: { maximum: 50 }
end

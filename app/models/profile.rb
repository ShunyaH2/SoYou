class Profile < ApplicationRecord
  belongs_to :family # 家族に必ず属する
  belongs_to :user, optional: true # 子供等はuser直結でなくてもOK
  
  # プロフィールは複数投稿と結びつく
  has_many :post_profiles, dependent: :destroy
  has_many :posts, through: :post_profiles
  validates :name, presence: true, length: { maximum: 50 }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name family_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[family user posts post_profiles]
  end
end

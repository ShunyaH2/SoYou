class Post < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy

  scope :search, ->(q) {
    return all if q.blank?

  # 全角スペース→半角、複数スペースを区切りに
  terms = q.to_s.tr('　', ' ').split(/\s+/).map{ |t| "%#{sanitize_sql_like(t)}%" }

  # users を Left Join し、さらに、users.family_id = profiles.family_id で profiles を Left Join
  rel = left_joins(:user)
    .joins("LEFT JOIN profiles ON profiles.family_id = users.family_id")
  
  # 各言語について（本文 OR プロフィール名）を ANDでつなぐ
  rel.where(
    terms.map { "(posts.body LIKE ? OR profiles.name LIKE ?)" }.join(' AND '),
    *terms.flat_map { |t| [t, t] }
    )
    .distinct
  }

  # 投稿は複数プロフィールと紐づく
  has_many :post_profiles, dependent: :destroy
  has_many :profiles, through: :post_profiles

  validates :body, presence: true, length: { maximum: 2000 }
  validates :occurred_on, presence: true

  def short_body(length = 20)
    body.to_s.truncate(length)
  end
end

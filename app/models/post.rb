class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  # 投稿は複数プロフィールと紐づく
  has_many :post_profiles, dependent: :destroy
  has_many :profiles, through: :post_profiles

  validates :body, presence: true, length: { maximum: 2000 }
  validates :occurred_on, presence: true

  attr_reader :invalid_tag_names

   # ------- タグの仮想属性 -------
  def tag_names=(names)
    list = names.to_s.split(/[、,]/).map { |n|
      n.unicode_normalize(:nfkc).strip.gsub(/\s+/, ' ')
    }.reject(&:blank?).uniq.first(10)

    allowed_names = Tag.active.where(name: list).pluck(:name)
    @invalid_tag_names = list - allowed_names

    self.tags = Tag.where(name: allowed_names)

    if @invalid_tag_names.any?
      errors.add(:tag_names, "未登録または無効なタグ: #{invalid_tag_names.join('、')}")
    end
  end

  def tag_names
    tags.pluck(:name).join(", ")
  end

  # ------- Ransack 許可 -------
  def self.ransackable_associations(_ = nil)
    %w[user profiles tags]
  end
  
  def self.ransackable_attributes(_ = nil)
    %w[id body occurred_on created_at updated_at user_id]
  end
end

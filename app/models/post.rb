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

  # ------- Ransack 許可 -------
  def self.ransackable_associations(_ = nil)
    %w[user profiles tags]
  end
  
  def self.ransackable_attributes(_ = nil)
    %w[id body occurred_on created_at updated_at user_id]
  end

  after_save :auto_assign_tags

  private

  def auto_assign_tags
    unless ENV['GEMINI_API_KEY'].present?
      Rails.logger.warn "[Post#auto_assign_tags] GEMINI_API_KEY not set. Skipping AI tagging."
      return
    end
    TagGenerator.new(self).assign_tags!
  end
end

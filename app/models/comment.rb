class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :body, presence: true, length: { maximum: 1000 }

  def self.ransackable_attributes(_ = nil)
    %w[id body created_at updated_at user_id post_id]
  end

  def self.ransackable_associations(_ = nil)
    %w[user post]
  end
end

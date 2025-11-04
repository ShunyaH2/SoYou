class Tag < ApplicationRecord
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags

  validates :name, presence: true, length: { maximum: 50 },
                  uniqueness: { case_sensitive: false }
            
  scope :active, -> { where(active: true) }
  
  def self.ransackable_attributes(_ = nil)
    %w[id name active created_at updated_at]
  end

  def self.ransackable_associations(_ = nil)
    %w[posts post_tags]
  end
end

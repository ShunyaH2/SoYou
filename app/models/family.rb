class Family < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :profiles, dependent: :destroy
  validates :name, presence: true
  validates :code, presence: true, uniqueness: { case_sensitive: false },
                  format: { with: /\A[A-Z0-9]{8}\z/ }
  
  before_validation :ensure_code, on: :create

  private
  def ensure_code
    return if code.present?
    self.code = loop do
      c = SecureRandom.alphanumeric(8).upcase
      breake c unless Family.exists?(code: c)
    end
  end
end

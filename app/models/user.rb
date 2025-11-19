class User < ApplicationRecord
  attr_accessor :family_code
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # 投稿（1ユーザーに複数）
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  # 本人用プロフィール（1ユーザーに1つ）
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile, update_only: true
  # プロフィールがあればnameを呼べる
  delegate :name, to: :profile, allow_nil: true 

  # 家族（ユーザー1人に対して1家族を自動作成）
  belongs_to :family, optional: true

  def self.ransackable_attributes(_ = nil)
    %w[id email created_at family_admin status]
  end

  def self.ransackable_associations(_ = nil)
    %w[family profile]
  end

   # 論理削除用
  enum status: { active: 0, withdrawn: 1 }

  def active_for_authentication?
    super && active?
  end
  
  before_validation :assign_family_by_code, on: :create
  after_create :ensure_family_presence!

  def family_admin?
    family_admin
  end

  def family_admin_of?(family)
    family_admin? && family_id.present? && family_id == family&.id
  end

  def can_promote?(other_user)
    family_admin_of?(other_user.family)
  end

  def last_family_admin?
    family_admin? && self.class.where(family_id: family_id, family_admin: true).where.not(id: id).none?
  end

  def ensure_family_presence!
    return if family.present?

    code = loop do
      c = SecureRandom.alphanumeric(8).upcase
      break c unless Family.exists?(code: c)
    end

    fam = Family.create!(name: "#{email.split('@').first}家", code: code)
    update!(family: fam)

    # 家族に管理者がいなければ自分を昇格
    update!(family_admin: true) if fam.users.where(family_admin: true).none?
  end

  scope :family_admins, -> { where(family_admin: true) }

  private

  def assign_family_by_code
    return if family.present?
    return if family_code.blank?

    fam = Family.find_by(code: family_code)
    errors.add(:base, "不正なコードです") and return unless fam

    self.family = fam
  end
end

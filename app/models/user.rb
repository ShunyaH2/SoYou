class User < ApplicationRecord
  attr_accessor :family_code
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # 投稿（1ユーザーに複数）
  has_many :posts, dependent: :destroy

  # 本人用プロフィール（1ユーザーに1つ）
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile
  # プロフィールがあればnameを呼べる
  delegate :name, to: :profile, allow_nil: true 

  # 家族（ユーザー1人に対して1家族を自動作成）
  belongs_to :family, optional: true

   # 論理削除用
  enum status: { active: 0, withdrawn: 1 }
  
  before_validation :assign_family_by_code
  after_create :ensure_family_presence!

  private

  def assign_family_by_code
    return if family.present?
    return if family_code.blank?

    fam = Family.find_by(code: family_code)
    errors.add(:base, "不正なコードです") and return unless fam

    self.family = fam
  end

  # ユーザー作成後：familyが無ければ新規作成して自分に割当
  def ensure_family_presence!
    return if family.present?

    code = loop do
      c = SecureRandom.alphanumeric(8)
      break c unless Family.exists?(code: c)
    end

    fam = Family.create!(name: "#{email.split('@').first}家", code: code)
    update!(family: fam)
  
  
  end
end

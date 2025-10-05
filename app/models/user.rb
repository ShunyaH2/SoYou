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
  delegate :name, to: :profile, allow_nil: true # プロフィールがあればnameを呼べる

  # 家族（ユーザー1人に対して1家族を自動作成）
  has_one :family, dependent: :destroy
  has_many :profiles, through: :family

  before_validation :family_code_check

  # ユーザー作成後、自動的に family を作成するフック
  after_create :ensure_family!

   # 論理削除用
  enum status: { active: 0, withdrawn: 1 }

  # 退会済みはログイン不可にする
  def active_for_authentication?
    super && active?
  end

  # 退会アカウント用のメッセージキー
  def inactive_message
    active? ? super : :inactive_account
  end

  private

  def family_code_check
    if self.family_code.present?
      family = Family.find_by(code: self.family_code)
      errors.add(:base, "不正なコードです") unless family
    end
  end

  # 家族が無ければ作る（自動生成）
  def ensure_family!
    if self.family_code.present?
      family = Family.find_by(code: self.family_code)
      profile = self.build_profile(family: family)
      profile.save!(validate: false)
    else
      code = ""
      loop do
        code = SecureRandom.alphanumeric(8)
        same_code_family = Family.find_by(code: code)
        break unless same_code_family
      end
      family = create_family!(name:"#{email.split('@').first}家", # ユーザーのメールをもとに家族名を作成
                    code: code) #ランダムコードを発行（識別用)
      profile = self.build_profile(family: family)
      profile.save!(validate: false)
    end
  end
end

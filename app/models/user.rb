class User < ApplicationRecord
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

  # 家族が無ければ作る（自動生成）
  def ensure_family!
    return if family
    create_family!(name:"#{email.split('@').first}家", # ユーザーのメールをもとに家族名を作成
                  code: SecureRandom.alphanumeric(8)) #ランダムコードを発行（識別用）
  end
end

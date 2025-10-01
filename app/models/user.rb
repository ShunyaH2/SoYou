class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :posts, dependent: :destroy
  has_one :profile, dependent: :destroy

  # プロフィールがあればnameを呼べる
  delegate :name, to: :profile, allow_nil: true
  
   # 追加：論理削除用の状態
  enum status: { active: 0, withdrawn: 1 }

  # 退会済みはログイン不可にする
  def active_for_authentication?
    super && active?
  end

  # 退会アカウント用のメッセージキー
  def inactive_message
    active? ? super : :inactive_account
  end

  accepts_nested_attributes_for :profile
  
end

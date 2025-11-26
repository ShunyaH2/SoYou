require 'rails_helper'

RSpec.describe User, type: :model do
  #it "名前が未入力だと無効であること"

  # it "1 + 1 は ２" do
  #   num = 1 + 1
  #   expect(num).to eq 2
  # end

  # it "userに山が含まれる" do
  #   user = "山田"
  #   expect(user).to include("山")
  # end

describe "バリデーション" do
  it "emailが未入力だと無効であること" do
    #user = User.new(password: "password")
    user = FactoryBot.build(:user, email: nil)

    expect(user).to be_invalid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "重複したemailは無効であること" do
    #User.create(
    #  email: "test@test.com",
    #  password: "password"
    #)
    FactoryBot.create(:user, email: "test@test.com")
    user = FactoryBot.build(:user, email: "test@test.com")

    expect(user).to be_invalid
    expect(user.errors[:email]).to include("has already been taken")
  end

  it "password が未入力だと無効であること" do
    user = FactoryBot.build(:user, password: nil)

    expect(user).to be_invalid
    expect(user.errors[:password]).to be_present
  end
end

describe "ファミリー関連のコールバック" do
  it "ファミリーコードが未入力で保存すると、ファミリーが自動生成される" do
    user = User.new(
      email: "test@test.com",
      password: "password"
    )

    expect(user.family).to be_nil
    
    user.save!

    expect(user.family).to be_present
    expect(user.family.name).to eq "test家"
    expect(user.family.code).to be_present
  end

  it "ファミリーコードが入力された場合、コードが存在したら有効" do
    owner = User.create(
      email: "owner@test.com",
      password: "password"
    )
    code = owner.family.code

    family_user =  User.new(
      email: "member@test.com",
      password: "password",
      family_code: code
    )

    expect(family_user).to be_valid
    family_user.save!
    
    expect(family_user.family).to eq owner.family
  end

  it "ファミリーコードが入力された場合、コードが存在しなければ無効" do
    owner = User.create!(
      email: "owner@test.com",
      password: "password"
    )
    valid_code = owner.family.code
    invalid_code = valid_code[0..-2] + "X"
    
    family_user =  User.new(
      email: "member@test.com",
      password: "password",
      family_code: invalid_code
    )

    expect(family_user).to be_invalid
    expect(family_user.errors[:base]).to include("不正なコードです")
  end

  it "最初の family メンバーは family_admin になること" do
    user = User.create!(
      email: "admin@test.com",
      password: "password"
    )

    expect(user.family_admin).to be true
  end

  it "同じ familyも2人目を作っても自動では family_adminにならないこと" do
    owner = User.create!(
      email: "owner@test.com",
      password: "password"
    )

    member = User.create!(
      email: "member@test.com",
      password: "password",
      family_code: owner.family.code
    )

    expect(owner.family_admin).to be true
    expect(member.family_admin).not_to be true
  end
end

  describe "#active_for_authentication?" do
    it "status が active の場合は true を返すこと" do
      user = FactoryBot.create(:user)
      user.withdrawn!

      expect(user).not_to be_active_for_authentication
    end
  end
end

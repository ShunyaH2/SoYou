require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { FactoryBot.create(:user) }

  before do
    dummy = instance_double(TagGenerator, assign_tags!: true)
    allow(TagGenerator).to receive(:new).and_return(dummy)
  end

  describe "バリデーション" do
    it "有効なファクトリを持つこと（userを紐づければ有効）" do
      post = FactoryBot.build(:post, user: user)
      expect(post).to be_valid
    end

    it "本文が空だと無効であること" do
      post = FactoryBot.build(:post, user: user, body: "")
      expect(post).to be_invalid
      expect(post.errors[:body]).to be_present
    end

    it "本文が2000文字までは有効であること" do
      post = FactoryBot.build(:post, user: user, body: "あ" *2000)
      expect(post).to be_valid
    end

    it "本文が2001文字以上だと無効であること" do
      post = FactoryBot.build(:post, user: user, body: "あ" *2001)
      expect(post).to be_invalid
      expect(post.errors[:body]).to be_present
    end

    it "出来事の日付が空だと無効であること" do
      post = FactoryBot.build(:post, user: user, occurred_on: nil)
      expect(post).to be_invalid
      expect(post.errors[:occurred_on]).to be_present
    end

    it "ユーザーが紐づいていないと無効であること" do
      post = FactoryBot.build(:post, user: nil)
      expect(post).to be_invalid
      expect(post.errors[:user]).to include("must exist")
    end
  end

  describe "TagGeneratorの呼び出し" do
    it "保存時に TagGenerator が呼ばれること" do
      tagger = instance_double(TagGenerator, assign_tags!: true)

      expect(TagGenerator).to receive(:new)
        .with(instance_of(Post))
        .and_return(tagger)

      post = FactoryBot.build(:post)
      post.save!
    end
  end

  describe "関連オブジェクトの削除(dependent: :destroy)" do
    it "投稿を削除すると紐づくコメントも削除されること" do
      post = FactoryBot.create(:post, user: user)
      comment = Comment.create!(user: user, post: post, body: "コメントテスト")

      post.destroy

      expect(Comment.find_by(id: comment.id)).to be_nil
    end

    it "投稿を削除すると紐づく post_tags も削除されること" do
      post = FactoryBot.create(:post, user: user)
      tag = Tag.create!(name: "テストタグ")
      post_tag = PostTag.create!(post: post, tag: tag)

      post.destroy

      expect(PostTag.find_by(id: post_tag.id)).to be_nil
    end

    it "投稿を削除すると紐づく post_profiles も削除されること" do
      post  = FactoryBot.create(:post, user: user)
      profile = Profile.create!(
        user: user,
        family: user.family, 
        name: "テスト太郎", 
        birthday: Date.current
      )
      post_profile = PostProfile.create!(post: post, profile: profile)

      post.destroy
      
      expect(PostProfile.find_by(id: post_profile.id)).to be_nil
    end
  end

  describe "Ransack 設定" do
    it "ransackable_attributes に許可されたカラムだけが含まれること" do
      expect(Post.ransackable_attributes).to match_array(
        %w[id body occurred_on created_at updated_at user_id]
      )
    end

    it "ransackable_associations に許可された関連だけが含まれていること" do
      expect(Post.ransackable_associations).to match_array(
        %w[user profiles tags]
      )
    end
  end
end

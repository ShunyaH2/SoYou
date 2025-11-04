# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = User.find_or_initialize_by(email: "admin@example.com")
if admin.new_record?
  admin.password = "password123"
  admin.password_confirmation = "password123"
end
admin.admin = true
admin.save!
puts "Admin: #{admin.email} (id=#{admin.id})"

traits = %w[
  優しさ 思いやり 共感 協調性 気配り 包容力
  慎重 率直 素直 正直 誠実 責任感 まじめ
  忍耐力 我慢強さ 粘り強さ 継続力 根気 勤勉
  向上心 探求心 好奇心 創造性 発想力 独創性
  主体性 行動力 積極性 挑戦心 たくましさ
  冷静 落ち着き 朗らか 明るさ
  優柔不断 頑固 マイペース 観察力 丁寧 几帳面
  客観性 公平性 公正さ 約束を守る
  思索的 論理的 計画性 段取り力 柔軟性 適応力
  リーダーシップ 面倒見 協力的 サポート力 応援上手
]

traits.each { |name| Tag.find_or_create_by!(name: name) }
puts "Tag seeded: #{Tag.count} total"
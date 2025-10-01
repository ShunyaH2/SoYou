class Post < ApplicationRecord
  belongs_to :user

  validates :body, presence: true, length: { maximum: 2000 }
  validates :occurred_on, presence: true

  def short_body(length = 20)
    body.to_s.truncate(length)
  end
end

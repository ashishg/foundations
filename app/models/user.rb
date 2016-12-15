class User < ActiveRecord::Base
  has_many :votes
  validates :username, presence: true, uniqueness: true, format: {with: /\A[a-zA-Z0-9\.@_+\-]+\Z/}
=begin
  validates :password, presence: true, confirmation: true, length: {in: 6..64},
                       exclusion: {in: ['123456', '1234567', '12345678', 'password', 'qwerty', 'abc123', 'abcdef'], message: "is too weak"},
                       if: :password_required?
=end
end

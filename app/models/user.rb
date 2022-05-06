class User < ApplicationRecord
  before_create :generate_auth_token! 
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def generate_auth_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  def as_json(options = {})
    super(options.merge({ except: [:auth_token, :created_at, :updated_at] }))
  end

  has_many :tweets, dependent: :destroy

  # relationship for following
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  # relationship for followers
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  def follow!(tw_user)
    active_relationships.create(followed_id: tw_user.id)
  end

  def unfollow!(tw_user)
    active_relationships.find_by(followed_id: tw_user.id).destroy
  end

  def following?(tw_user)
    following.include?(tw_user)
  end

end

class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :followers, :following, :tweets
end

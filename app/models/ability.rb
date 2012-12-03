class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.role? 'admin'
      can :manage, :all
    else
      can :read, :all

      if user.persisted?
        can :create, :all
        can :update, Post, :user_id => user.id
        can :destroy, Post, :user_id => user.id
        can :update, Channel, :user_id => user.id
        can :destroy, Channel, :user_id => user.id
        can :update, User, :id => user.id
        can :destroy, User, :id => user.id
        can :post, Channel
      end
    end
  end
end

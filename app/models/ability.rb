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
        can :manage, Post, :user_id => user.id
        can :manage, Channel, :user_id => user.id
        can :manage, User, :id => user.id
        can :post, Channel, :privacy => "public"
      end
    end
  end
end

class FollowerPolicy < ApplicationPolicy
  def destroy?
    raise Pundit::NotAuthorizedError unless record.followed_id == user.id
    return Regular.new(record.follower)
  end

  class Scope < Scope
    def resolve
      return Regular.new(scope, User)
    end
  end

  class Regular < FlexiblePermissions::Base
  end
end


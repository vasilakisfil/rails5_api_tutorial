class FollowingPolicy < ApplicationPolicy
  def create?
    raise Pundit::NotAuthorizedError unless record.follower_id == user.id

    return Regular.new(record.followed)
  end

  def destroy?
    raise Pundit::NotAuthorizedError unless record.follower_id == user.id

    return Regular.new(record.followed)
  end

  class Scope < Scope
    def resolve
      return Regular.new(scope, User)
    end
  end

  class Regular < UserPolicy::Regular
  end
end

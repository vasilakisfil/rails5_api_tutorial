class FollowingPolicy < ApplicationPolicy
  def create?
    return Regular.new(record.followed)
  end

  def destroy?
    return Regular.new(record.followed)
  end

  class Scope < Scope
    def resolve
      return Regular.new(scope, User)
    end
  end

  class Regular < DefaultPermissions
  end
end


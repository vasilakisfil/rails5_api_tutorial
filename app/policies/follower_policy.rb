class FollowerPolicy < ApplicationPolicy
  def destroy?
    return Regular.new(record.follower)
  end

  class Scope < Scope
    def resolve
      return Regular.new(scope, User)
    end
  end

  class Regular < DefaultPermissions
  end
end


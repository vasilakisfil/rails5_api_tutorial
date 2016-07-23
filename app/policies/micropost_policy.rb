class MicropostPolicy < ApplicationPolicy
  def create?
    return Regular.new(record)
  end

  def show?
    return Regular.new(record)
  end

  def update?
    return Regular.new(record)
  end

  def destroy?
    return Regular.new(record)
  end

  class Scope < Scope
    def resolve
      return Regular.new(scope, User)
    end
  end

  class Regular < DefaultPermissions
  end
end


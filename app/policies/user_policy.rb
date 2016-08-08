class UserPolicy < ApplicationPolicy
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

  class Admin < DefaultPermissions
    class Fields < self::Fields
      def permitted
        super + [
          :links, :following_state, :follower_state
        ]
      end
    end

    class Includes < self::Includes
      def default
        []
      end
    end
  end

  class Regular < Admin
    class Fields < self::Fields
      def permitted
        super - [
          :activated, :activated_at, :activation_digest, :admin,
          :password_digest, :remember_digest, :reset_digest, :reset_sent_at,
          :token, :updated_at
        ]
      end
    end
  end
end

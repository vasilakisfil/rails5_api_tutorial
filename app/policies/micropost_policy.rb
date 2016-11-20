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
      return Regular.new(scope, Micropost)
    end
  end

  class Admin < FlexiblePermissions::Base
    class Fields < self::Fields
      def permitted
        super + [
          :links
        ] - [
          :picture
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
          :update_at
        ]
      end
    end
  end
end


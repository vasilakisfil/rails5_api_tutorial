module FlexiblePermissions
  module RoleMethods
    attr_reader :record, :model

    def initialize(record, model = nil)
      @record = record
      @model = model || record.class
    end

    def fields(asked = nil)
      self.class::Fields.new(asked, record, model).resolve
    end

    def includes(asked = nil)
      self.class::Includes.new(asked, record, model).resolve
    end

    def collection
      record
    end
  end

  module SparsedMethods
    attr_reader :resolve, :model, :record, :asked
    def initialize(asked, record, model)
      @model = model
      @asked = asked
      @record = record
    end

    def resolve
      return defaults if asked.blank?

      union(permitted, asked)
    end

    def permitted
      []
    end

    def defaults
      permitted
    end

    def union(permitted, asked = nil)
      return permitted unless asked.is_a?(Array)

      permitted.map(&:to_sym) & asked.map(&:to_sym)
    end

    def collection?
      record.kind_of? ActiveRecord::Relation
    end

    def resource?
      !collection?
    end
  end

  module SparsedFieldMethods
    include SparsedMethods

    def permitted
      model.attribute_names.map(&:to_sym)
    end
  end

  module SparsedIncludeMethods
    include SparsedMethods

    def permitted
      model.reflect_on_all_associations.map(&:name).map(&:to_sym)
    end
  end
end


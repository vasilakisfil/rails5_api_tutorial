module AuthorizeWithReturn
  def authorize_with_permissions(record, query=nil)
    query ||= params[:action].to_s + '?'
    @_pundit_policy_authorized = true

    policy = policy(record)
    policy.public_send(query)
  end

  def included
    super
    hide_action :authorize
  end
end

module Pundit
  prepend AuthorizeWithReturn
end

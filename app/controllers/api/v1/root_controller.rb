class Api::V1::RootController < Api::V1::BaseController

  def options
    return head :ok
  end
end

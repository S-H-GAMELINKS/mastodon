# frozen_string_literal: true

class Api::V2::InstancesController < Api::V1::InstancesController
  def show
    render json: InstancePresenter.new, serializer: REST::InstanceSerializer, root: 'instance'
  end
end

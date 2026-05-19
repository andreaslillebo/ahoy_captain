module AhoyCaptain
  module Filters
    module Properties
      class NamesController < BaseController
        def index
          render json: AhoyCaptain::Adapter.current.property_keys_relation(::Ahoy::Event).map(&:keys).map { |key| serialize(key) }
        end
      end
    end
  end
end

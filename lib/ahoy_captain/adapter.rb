require "ahoy_captain/adapter/base"
require "ahoy_captain/adapter/postgres"
require "ahoy_captain/adapter/sqlite"

module AhoyCaptain
  module Adapter
    UnsupportedAdapterError = Class.new(StandardError)

    class << self
      def current
        for_connection(::AhoyCaptain.event.connection)
      end

      def for_connection(connection)
        name = connection.adapter_name.to_s.downcase
        if name.include?("postgres")
          Postgres.new
        elsif name.include?("sqlite")
          Sqlite.new
        else
          raise UnsupportedAdapterError,
            "AhoyCaptain does not support the #{connection.adapter_name} adapter. " \
            "Supported: PostgreSQL, SQLite."
        end
      end
    end
  end
end

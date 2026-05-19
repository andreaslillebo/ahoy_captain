module AhoyCaptain
  module Adapter
    class Base
      # Builds a relation that yields one row per distinct property key on the events table.
      # Each result row responds to .keys (the key name).
      def property_keys_relation(event_klass)
        raise NotImplementedError
      end

      # SQL fragment that is truthy when the given JSON column has the given top-level key.
      def json_has_key_sql(column, key)
        raise NotImplementedError
      end

      # Default SQL for AhoyCaptain.config.event.url_column (controller#action concatenation).
      def url_column_sql(table)
        raise NotImplementedError
      end

      # Default SQL for AhoyCaptain.config.event.url_exists (controller + action keys present).
      def url_exists_sql(table)
        raise NotImplementedError
      end

      # SQL expression that extracts a bare host from a referring_domain column.
      def host_from_url(column)
        raise NotImplementedError
      end

      # SQL expression returning the duration in seconds between two timestamp columns
      # (end_expr - start_expr).
      def duration_seconds_expr(end_expr, start_expr)
        raise NotImplementedError
      end
    end
  end
end

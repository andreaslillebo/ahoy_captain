module AhoyCaptain
  module Adapter
    class Postgres < Base
      def property_keys_relation(event_klass)
        event_klass
          .select("jsonb_object_keys(properties) AS keys")
          .distinct("jsonb_object_keys(properties)")
      end

      def json_has_key_sql(column, key)
        "JSONB_EXISTS(#{column}, '#{escape(key)}')"
      end

      def url_column_sql(table)
        "CONCAT(#{table}.properties->>'controller', '#', #{table}.properties->>'action')"
      end

      def url_exists_sql(table)
        "JSONB_EXISTS(#{table}.properties, 'controller') AND JSONB_EXISTS(#{table}.properties, 'action')"
      end

      def host_from_url(column)
        "substring(#{column} from '(?:.*://)?(?:www\\.)?([^/?]*)')"
      end

      def duration_seconds_expr(end_expr, start_expr)
        "EXTRACT(EPOCH FROM (#{end_expr} - #{start_expr}))"
      end

      private

      def escape(value)
        value.to_s.gsub("'", "''")
      end
    end
  end
end

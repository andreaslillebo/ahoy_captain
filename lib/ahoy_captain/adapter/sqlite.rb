module AhoyCaptain
  module Adapter
    # SQLite >= 3.38 (json1 + ->> operator) is required.
    # Bundled with Rails 8's sqlite3 gem.
    class Sqlite < Base
      def property_keys_relation(event_klass)
        table = event_klass.table_name
        event_klass
          .from("#{table}, json_each(#{table}.properties) AS ahoy_captain_je")
          .select("DISTINCT ahoy_captain_je.key AS keys")
      end

      def json_has_key_sql(column, key)
        "json_extract(#{column}, '$.#{escape(key)}') IS NOT NULL"
      end

      def url_column_sql(table)
        "(COALESCE(#{table}.properties->>'controller','') || '#' || COALESCE(#{table}.properties->>'action',''))"
      end

      def url_exists_sql(table)
        "json_extract(#{table}.properties, '$.controller') IS NOT NULL AND " \
        "json_extract(#{table}.properties, '$.action') IS NOT NULL"
      end

      # SQLite has no built-in regex. ahoy_matey already stores referring_domain
      # as the bare host, so emit the column unchanged. PG's regex stripped any
      # leftover scheme/www prefix defensively; on SQLite we trust the value.
      def host_from_url(column)
        column.to_s
      end

      def duration_seconds_expr(end_expr, start_expr)
        "(strftime('%s', #{end_expr}) - strftime('%s', #{start_expr}))"
      end

      private

      def escape(value)
        value.to_s.gsub("'", "''")
      end
    end
  end
end

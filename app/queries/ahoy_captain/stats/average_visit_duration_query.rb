module AhoyCaptain
  module Stats
    class AverageVisitDurationQuery < BaseQuery
      def build
        max_events = event_query.select("#{AhoyCaptain.event.table_name}.visit_id, max(#{AhoyCaptain.event.table_name}.time) as created_at").group("visit_id")
        duration_seconds = AhoyCaptain::Adapter.current.duration_seconds_expr(
          "max_events.created_at",
          "#{AhoyCaptain.visit.table_name}.started_at"
        )
        visit_query.select("avg(#{duration_seconds}) as average_visit_duration")
                   .joins("LEFT JOIN (#{max_events.to_sql}) as max_events ON #{AhoyCaptain.visit.table_name}.id = max_events.visit_id")
      end

      def self.cast_type(value)
        ActiveRecord::Type.lookup(:float)
      end

      def self.cast_value(_type, value)
        return ActiveSupport::Duration.parse("P0MT0S") if value.blank?

        ActiveSupport::Duration.build(value.to_f.round)
      end
    end
  end
end

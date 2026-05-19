require 'ahoy_captain/period_collection'
require 'ahoy_captain/filters_configuration'

module AhoyCaptain
  class Configuration
    # OrderedOptions subclass that lazily fills `url_column` / `url_exists`
    # from the database adapter when they have not been explicitly set.
    # Lazy because adapter detection requires a live DB connection, which is
    # not available at configuration boot time.
    class EventOptions < ActiveSupport::OrderedOptions
      def [](key)
        value = super
        return value unless value.nil?

        case key.to_sym
        when :url_column then AhoyCaptain::Adapter.current.url_column_sql(events_table)
        when :url_exists then AhoyCaptain::Adapter.current.url_exists_sql(events_table)
        end
      end

      private

      def events_table
        AhoyCaptain.config.models[:event].parameterize.tableize
      end
    end

    attr_accessor :view_name, :theme, :realtime_interval, :disabled_widgets
    attr_reader :goals, :funnels, :cache, :ranges, :event, :models, :filters, :predicate_labels
    def initialize
      @goals = GoalCollection.new
      @funnels = FunnelCollection.new
      @theme = "dark"
      @ranges = ::AhoyCaptain::PeriodCollection.load_default
      @cache = ActiveSupport::OrderedOptions.new.tap do |option|
        option.enabled = false
        option.store = Rails.cache
        option.ttl = 1.minute
      end
      @models = ActiveSupport::OrderedOptions.new.tap do |option|
        option.event = "::Ahoy::Event"
        option.visit = "::Ahoy::Visit"
      end
      @event = EventOptions.new.tap do |option|
        option.view_name = "$view"
      end
      @filters = FiltersConfiguration.load_default
      @predicate_labels = {
        eq: 'equals',
        not_eq: 'not equals',
        cont: 'contains',
        in: 'in',
        not_in: 'not in',
      }

      @realtime_interval = 30.seconds
      @disabled_widgets = []
    end

    def goal(id, &block)
      instance = Goal.new
      instance.id = id
      instance.instance_exec(&block)
      @goals.register(instance)
    end

    def funnel(id, &block)
      instance = Funnel.new
      instance.id = id
      instance.instance_exec(&block)
      @funnels.register(instance)
    end
  end
end

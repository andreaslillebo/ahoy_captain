module AhoyCaptain
  class SourceQuery < ApplicationQuery
    def build
      host = AhoyCaptain::Adapter.current.host_from_url("referring_domain")
      visit_query
        .select("#{host} as referring_domain, count(#{host}) as count, sum(count(#{host})) OVER() as total_count")
        .where.not(referring_domain: nil)
        .group(host)
        .order(Arel.sql "count(#{host}) desc")
    end
  end
end

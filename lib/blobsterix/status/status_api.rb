module Blobsterix
  class StatusApi < AppRouterBase
    include StatusUrlHelper

    get "/status(.:format)", :status

    get "*any", :next_api
    put "*any", :next_api
    delete "*any", :next_api
    head "*any", :next_api
    post "*any", :next_api

    json_var :cache_hits, :cache_misses, :cache_errors, :cache_accesses, :connections, :cache_hit_rate, :ram_usage, :uptime

    def status
      case format
      when :json
        render_json
      when :xml
        render_xml
      else
        render "status_page"
      end
    end

    def ram_usage
      `pmap #{Process.pid} | tail -1`[10, 40].strip
    end

    def uptime
      @uptime ||= StatusInfo.uptime
    end

    def cache_hits
      @cache_hits ||= StatusInfo.cache_hit
    end

    def cache_hit_rate
      if cache_hits > 0 && cache_accesses > 0
        cache_hits.to_f / cache_accesses.to_f
      else
        1.to_f
      end
    end

    def cache_misses
      @cache_misses ||= StatusInfo.cache_miss
    end

    def cache_errors
      @cache_errors ||= StatusInfo.cache_error
    end

    def cache_accesses
      @cache_accesses ||= StatusInfo.cache_access
    end

    def connections
      @connections ||= StatusInfo.connections
    end
  end
end

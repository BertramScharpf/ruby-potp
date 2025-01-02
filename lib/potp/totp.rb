#
#  potp/totp.rb  --  TOTP class
#

require "potp/otp"


module POTP

  class TOTP < OTP

    SCHEME = "totp"

    DEFAULT_INTERVAL = 30

    attr_reader :interval

    def initialize secret, interval: nil, **kwargs
      @interval = interval || DEFAULT_INTERVAL
      super secret, **kwargs
    end

    def at time ; super (timeint time) / @interval ; end
    def now     ; at Time.now                      ; end

    def verify input, drift_ahead: nil, drift_behind: nil, after: nil, at: nil
      fin = now = timeint at||Time.now
      now -= drift_behind     if drift_behind
      fin += drift_ahead      if drift_ahead
      if after and now < after then
        now = after + @interval
      end
      now -= now % @interval
      while now < fin do
        return now if super input, now
        now += @interval
      end
      nil
    end

    def provisioning_uri **kwargs
      super **kwargs, period: (@interval unless @interval == TOTP::DEFAULT_INTERVAL)
    end

    private

    def timeint time
      case time
      when Integer then time
      when Time    then time.utc.to_i
      else              time.to_i
      end
    end

  end

end


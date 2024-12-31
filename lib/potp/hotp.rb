#
#  potp/hotp.rb  --  HOTP class
#

require "potp/otp"


module POTP

  class HOTP < OTP

    SCHEME = "hotp"

    def verify input, counter, retries: 0
      while retries >= 0 do
        return counter if super input, counter
        counter += 1
        retries -= 1
      end
    end

    def provisioning_uri counter: 0, **kwargs
      super
    end

  end

end


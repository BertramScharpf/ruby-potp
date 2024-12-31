#
#  potp/otp.rb  --  OTP class
#

require "potp/foreign/supplement"
require "openssl"
require "potp/base32"


module POTP

  class OTP

    attr_reader :secret, :digits, :digest

    DEFAULT_DIGITS = 6

    def initialize secret, digits: nil, digest: nil, **kwargs
      @secret = secret
      @digits = digits || DEFAULT_DIGITS # Google Authenticate only supports 6 currently
      @digest = digest || "sha1"         # Google Authenticate only supports SHA1 currently
    end

    def at data
      hmac = build_digest data
      code = hmac[ (hmac.last & 0x0f), 4].inject do |c,e| c <<= 8 ; c |= e end
      code &= 0x7fffffff
      s = ""
      @digits.times { code, d = code.divmod 10 ; s << d.to_s }
      s.reverse!
      s
    end

    def verify input, data
      String === input or raise ArgumentError, "`otp` has to be a String"
      time_constant_compare input, (at data)
    end

    # https://github.com/google/google-authenticator/wiki/Key-Uri-Format
    # Example additional parameter: image: "https://example.com/icon.png"
    def provisioning_uri name:, issuer: nil, **kwargs
      label = [ issuer, name||""].map { |x| x&.tr ":", "_" }
      parameters = {
        **kwargs,
        digits:    (@digits unless @digits == DEFAULT_DIGITS),
        algorithm: (@digest.upcase unless @digest.downcase == "sha1"),
        issuer:    issuer,
        secret:    @secret,
      }
      build_uri label, parameters
    end

    private

    def int_to_bytestring i, padding = 8
      i >= 0 or raise ArgumentError, "#int_to_bytestring requires a positive number"
      result = []
      while i != 0 or padding > 0 do
        c = (i & 0xff).chr
        result.unshift c
        i >>= 8
        padding -= 1
      end
      result.join
    end

    def time_constant_compare a, b
      a.notempty? and b.notempty? and a == b
    end

    def build_digest input
      d = OpenSSL::Digest.new @digest
      s = (Base32.new @secret).decode
      i = int_to_bytestring input.to_i
      (OpenSSL::HMAC.digest d, s, i).bytes
    end

    def build_uri label, parameters
      label.compact!
      label = label.map! { |s| url_encode s }.join ":"
      parameters.reject! { |_,v| v.nil? }
      parameters = parameters.keys.reverse.map { |k| "#{k}=#{url_encode parameters[ k]}" }.join "&"
      "otpauth://#{self.class::SCHEME}/#{label}?#{parameters}"
    end

    def url_encode str
      str.to_s.gsub %r/([^a-zA-Z0-9_.-])/ do |c| "%%%02X" % c.ord end
    end

  end

end


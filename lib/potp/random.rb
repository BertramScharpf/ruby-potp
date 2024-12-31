#
#  potp/random.rb  --  Generate random secrets
#

require "potp/base32"
require "securerandom"


module POTP

  class Base32

    class <<self

      # A byte length of 20 means 160 bits and results in 32 character long base32 value.
      def random byte_length = 20
        rand_bytes = SecureRandom.random_bytes byte_length
        (encode rand_bytes).data
      end

    end

  end

end


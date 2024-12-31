#
#  potp/base32.rb  --  Base32 Encoding
#

require "potp/foreign/supplement"


module POTP

  class Base32

    ORD_A, ORD_Z, ORD_a, ORD_z, ORD_2, ORD_7 = %w(A Z a z 2 7).map { |c| c.ord }
    LAP = 26
    DIFF_2 = ORD_2 - LAP

    class << self

      def encode bytes, width: nil, equals: true
        res = [""]
        scan_bufs bytes do |buf,r|
          chunk = []
          8.times {
            chunk.unshift buf & 0x1f
            buf >>= 5
          }
          loop do
            r -= 5
            break unless r > 0
            chunk.pop
          end
          chunk = chunk.map { |c| (c + (c < LAP ? ORD_A : DIFF_2)).chr }
          if equals then
            chunk.push "=" until chunk.length >= 8
          end
          res.last << chunk.join
          if width and res.last.length > width then
            res.push res.last.slice! width, 8
          end
        end
        new res.join "\n"
      end

      private

      def scan_bufs bytes
        scan_blocks bytes do |s|
          buf, r = 0, 40
          5.times {
            buf <<= 8
            if (b = s.shift) then
              buf |= b
              r -= 8
            end
          }
          yield buf, r
        end
      end

      def scan_blocks bytes
        i = 0
        loop do
          s = bytes.byteslice i, 5
          break unless s.notempty?
          yield s.unpack "C*"
          i += 5
        end
      end

    end


    class Invalid < ArgumentError ; end

    attr_reader :data

    def initialize data
      @data = data
    end

    def decode encoding: nil
      res = ""
      each_block { |buf,n|
        chunk = []
        5.times {
          chunk.unshift buf & 0xff
          buf >>= 8
        }
        until n >= 40 do
          chunk.pop
          n += 8
        end
        res << (chunk.pack "C*")
      }
      encoding = Encoding.default_external if encoding == :default
      res.force_encoding encoding if encoding
      res
    end

    private

    def each_block
      buf, n = 0, 0
      each_char do |c|
        c -= case c
          when ORD_A..ORD_Z then ORD_A
          when ORD_a..ORD_z then ORD_a
          when ORD_2..ORD_7 then DIFF_2
          else                   raise Invalid, "Character '#{c}'."
        end
        buf <<= 5
        buf |= c
        n += 5
        if n == 40 then
          yield buf, n
          buf, n = 0, 0
        end
      end
      if n.nonzero? then
        buf <<= 40 - n
        yield buf, n
      end
      nil
    end

    def each_char
      done = false
      @data.each_char { |c|
        case c
        when "="  then done = true ; next
        when "\n" then next
        else           raise Invalid, "Material after '=': '#{c}'" if done
        end
        yield c.ord
      }
    end

  end

end


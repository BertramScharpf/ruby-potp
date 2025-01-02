#
#  potp/foreign/supplement.rb  --  Addition usefull Ruby functions
#

# The purpose of this is simply to reduce dependencies.

begin
  require "supplement"
rescue LoadError
  class NilClass ; def notempty? ;                      end ; end
  class String   ; def notempty? ; self unless empty? ; end ; end
  class Array    ; def notempty? ; self unless empty? ; end ; end
  class <<Struct ; alias [] new ; end
  class String
    def starts_with? oth ; o = oth.to_str ; o.length          if start_with? o ; end
    def ends_with?   oth ; o = oth.to_str ; length - o.length if end_with?   o ; end
    alias starts_with starts_with?
    alias ends_with   ends_with?
  end
end


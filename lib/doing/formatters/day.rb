require 'chronic'

module Doing
    module Formatters
        class Day < Table
            def initialize(tasks)
                time=Time.now
                day=Chronic.parse(format_day(time) + " 12AM")
                
                super(tasks.find_all { |t| (t.start <=> day) >=0 } )
            end
        end
    end
end
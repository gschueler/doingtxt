require 'doing'
require 'doing/formatters/markdown'
module Doing
    class CLI
        def self.start
            if ARGV.size > 0 && ARGV[0]=="-rev"
            else
            end
            doing=Doing.new
            doing.display(ARGV[0])
            print Formatters::Markdown.new(doing.tasks).output
        end
    end
end
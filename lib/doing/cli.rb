require 'doing'

module Doing
    class CLI
        @@default_file=File.join(ENV['HOME'], '.doing.txt')
        def self.start
            doing=Doing.new(@@default_file)

            if ARGV.size > 0
                case ARGV[0]
                when /in?|start/
                    title=ARGV[1...ARGV.size].join(" ")
                    #print "title is #{title}"
                    if doing.startTask(title)
                        print "Started task: #{title} at #{Time.now}\n"
                    end
                when /o(ut)?|done|end/
                    if doing.endTask
                        print "Finished task: #{title} at #{Time.now}\n"
                    end
                when /a(ppend|dd)/
                    text=ARGV[1...ARGV.size].join(" ")
                    if doing.append(text)
                        
                    end
                when /text/
                    doing.display 'markdown'
                end
            else
                doing.display 'table'
            end

        end
    end
end
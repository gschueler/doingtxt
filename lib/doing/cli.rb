require 'doing'

module Doing
    class CLI
        @@default_file=File.join(ENV['HOME'], '.doing.txt')
        def self.start
            doing=Doing.new(@@default_file)

            if ARGV.size > 0
                case ARGV[0]
                when /^(in?|start)$/
                    title=ARGV[1...ARGV.size].join(" ")
                    #print "title is #{title}"
                    if doing.startTask(title)
                        print "Started task: #{title} at #{Time.now}\n"
                    end
                when /^(o(ut)?|done|end)$/
                    if doing.endTask
                        print "Finished task: #{title} at #{Time.now}\n"
                    end
                when /^a(ppend|dd)$/
                    text=ARGV[1...ARGV.size].join(" ")
                    if doing.append(text)
                        
                    end
                when /^t(ext)?$/
                    doing.display 'markdown'
                when /^e(dit)?$/
                    # open in $EDITOR
                    exec ENV['EDITOR'], @@default_file if ENV['EDITOR']
                    print "$EDITOR is not defined.\nCurrent file: %s\n" % @@default_file
                when /^m(eta)?$/
                    # Add metadata to the latest entry
                    key=nil
                    ARGV[1...ARGV.size].each { |arg| 
                        s = StringScanner.new(arg)
                        if em=s.scan(/^(.+)[=:](.+)$/)
                            if !doing.addMeta(s[1],s[2]) 
                                break
                            end
                        elsif em=s.scan(/^(.+)[=:]\s*$/)
                            key=s[1]
                        elsif key
                            if !doing.addMeta(key,arg) 
                                break
                            end
                        end
                    }
                when /^r(esume)?$/
                    # resume previous task if finished
                    doing.resumeTask
                end
            else
                doing.display 'table'
            end

        end
    end
end
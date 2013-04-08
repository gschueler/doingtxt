require 'doing'

module Doing
    class CLI
        @@default_file_name='.doing'
        @@default_file=File.join(ENV['HOME'], "#{@@default_file_name}.txt")
        @@config_file=File.join(ENV['HOME'], '.doing.config')
        def self.config
            # write new config file if it doesn't exist
            config=Doing.new(@@config_file) if File.exist?(@@config_file)
            if !File.exist?(@@config_file)
                File.open(@@config_file, "w") { |io|  
                }
                config=Doing.new(@@config_file)
                config.startTask("Configuration")
                config.endTask
            end
            config
        end
        def self.sheet(file)
            if !File.exist?(file)
                File.open(file, "w") { |io|  
                }
            end
            Doing.new(file)
        end
        def self.start
            file=@@default_file
            file_key=nil

            # hack until using yaml or something: use markdown metadata
            config=self.config
            if config && config.tasks && config.tasks[0]
                file_key=config.tasks[0].meta["file_key"]
                file_key.strip! if file_key
                if file_key && file_key!=''
                    file=File.join(ENV['HOME'], "#{@@default_file_name}.#{file_key}.txt")
                end
            end
            doing=self.sheet(file)

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
                when /^s(witch)?$/
                    # switch to another worksheet, or 'default' to mean default
                    key=ARGV[1]
                    key="" if key=="default"
                    config.addMeta('file_key',key) 
                    print "Switched to Worksheet: %s\n" % (key!="" ? key : "Default")
                when /^c(onfig)?$/
                    ARGV[1...ARGV.size].each { |arg| 
                        s = StringScanner.new(arg)
                        if em=s.scan(/^(.+)[=:](.+)$/)
                            if !config.addMeta(s[1],s[2]) 
                                break
                            end
                        elsif em=s.scan(/^(.+)[=:]\s*$/)
                            key=s[1]
                        elsif key
                            if !config.addMeta(key,arg) 
                                break
                            end
                        end
                    }
                end
            else
                if file_key
                    print "Worksheet: #{file_key}\n"
                end
                doing.display 'table'
            end

        end
    end
end
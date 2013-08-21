require 'doing'

module Doing
    class CLI
        @@default_file_name='doing'
        @@default_dir=File.join(ENV['HOME'],'.doing')
        @@default_file=File.join(@@default_dir, "#{@@default_file_name}.txt")
        @@config_file=File.join(@@default_dir, '.doing.config')
        attr_accessor :data_dir
        def self.config
            # create config dir if it doesn't exist
            if !File.directory?(@@default_dir)
                Dir.mkdir(@@default_dir)
            end

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
                print "Starting new file: #{file}\n"
                File.open(file, "w") { |io|  
                }
            end
            Doing.new(file)
        end
        def self.parseMetaArgs
            vals = {}
            key=nil
            ARGV[1...ARGV.size].each { |arg| 
                s = StringScanner.new(arg)
                if !key && em=s.scan(/^(.+?)[=:](.+)$/)
                    vals[s[1]]=s[2]
                elsif em=s.scan(/^(.+?)[=:]\s*$/)
                    key=s[1]
                elsif key
                    vals[key]=arg
                end
            }
            vals
        end
        def self.start
            file=@@default_file
            file_key=nil
            file_dir=nil

            # hack until using yaml or something: use markdown metadata
            config=self.config
            if config && config.tasks && config.tasks[0]
                file_dir=config.tasks[0].meta["file_dir"]
                if !file_dir || file_dir==''
                    file_dir=@@default_dir
                end
                file_key=config.tasks[0].meta["file_key"]
                file_key.strip! if file_key
                if file_key && file_key!=''
                    file=File.join(file_dir, "#{@@default_file_name}.#{file_key}.txt")
                end
            end
            doing=self.sheet(file)

            if ARGV.size > 0
                case ARGV[0]
                when /^(in?|start)$/
                    title=ARGV[1...ARGV.size].join(" ")
                    #print "title is #{title}"
                    if doing.startTask(title)
                        print "Started task: #{doing.tasks[-1].title} at #{doing.tasks[-1].start}\n"
                    end
                when /^(o(ut)?|done|end)$/
                    at=Time.now.to_s
                    text=ARGV[1...ARGV.size].join(" ")
                    parsed=doing.parseTitle(text) #look for @time
                    if parsed[:meta]['start']
                        at=parsed[:meta]['start']
                    end
                    if doing.endTask(at)
                        lasttitle=doing.tasks[-1].title
                        print "Finished task #{lasttitle} at #{at}\n"
                    end
                when /^(a(ppend|dd)|log)$/
                    text=ARGV[1...ARGV.size].join(" ")
                    if doing.append(text)
                        doing.display 'status'
                    end
                when /^t(ext)?$/
                    doing.display 'markdown'
                when /^stat(us)?$/
                    doing.display 'status'
                when /^(to)?day$/
                    doing.display 'day'
                when /^e(dit)?$/
                    # open in $EDITOR
                    exec ENV['EDITOR'], file if ENV['EDITOR']
                    exec ARGV[1],file if ARGV.size > 1
                    print "$EDITOR is not defined.\nCurrent file: %s\n" % file
                when /^m(eta)?$/
                    # Add metadata to the latest entry
                    meta=self.parseMetaArgs
                    meta.each_key { |key|  
                        if !doing.addMeta(key,meta[key]) 
                            break
                        end
                    }
                    doing.display 'status'
                    
                when /^r(esume)?$/
                    # resume previous task if finished
                    index=-1
                    if ARGV.size > 1
                        index = ARGV[1].to_i
                    end
                    doing.resumeTask index
                    doing.display 'status'
                when /^split$/
                    # finish previous task and start a new one right now
                    title=ARGV[1...ARGV.size].join(" ")
                    at=Time.now.to_s
                    parsed=doing.parseTitle(title) #look for @time
                    if parsed[:meta]['start']
                        at=parsed[:meta]['start']
                    end
                    if doing.endTask(at)
                        lasttitle=doing.tasks[-1].title
                        print "Finished task #{lasttitle} at #{at}\n"
                        #print "title is #{title}"
                        if doing.startTask(title)
                            print "Started task: #{title} at #{at}\n"
                        end
                    end
                when /^f(ilter|ind)$/
                    # finish previous task and start a new one right now
                    title=ARGV[1...ARGV.size].join(" ")
                    after=nil
                    parsed=doing.parseTitle(title) #look for @time
                    if parsed[:meta]['start_time']
                        after=parsed[:meta]['start_time']
                    end
                    proj=nil
                    if parsed[:meta]['project']
                        proj=parsed[:meta]['project']
                    end
                    doing.filter(nil,after,proj,parsed[:text],'table')
                when /^f(ile)?$/
                    # switch to another file, or 'default' to mean default
                    key=ARGV[1]
                    key="" if key=="default"
                    config.addMeta('file_key',key) 
                    print "Switched to Worksheet: %s\n" % (key!="" ? key : "Default")
                when /^c(onfig)?$/
                    
                    meta=self.parseMetaArgs
                    meta.each_key { |key|  
                        if !config.addMeta(key,meta[key]) 
                            break
                        end
                    }
                when /^archive$/
                    # Archive all logs before the filtered time into a file named from the filter
                    before=nil
                    parsed=doing.parseTitleTokens(ARGV[1...ARGV.size]) #look for @time
                    if parsed[:meta]['start_time']
                        before=parsed[:meta]['start_time']
                    end
                    dname = ARGV[1..ARGV.size].find { |key| key.start_with?"@"}
                    if !before
                        print "Unable to determine archive date from: %s\n" % dname
                        return
                    end
                    
                    fname=dname
                    if file_key
                        fname = "#{file_key}.#{dname}"
                    end
                    newfile=File.join(file_dir, "#{@@default_file_name}.#{fname}.txt")
                    
                    tasks=doing.filterTasks(before)
                    if tasks.size
                        
                        doing.writeTo(tasks,newfile)
                        
                        print "Archiving tasks before %s\n" % [before]
                        print "Archived %s tasks to: %s\n" % [tasks.size, newfile]

                        #truncate current taskset
                        doing.filterTo(nil,before)
                        
                        print "Truncated worksheet %s\n" % [file_key]
                    else
                        print "No tasks matching filter: %s\n" % [dname]
                    end

                else
                    print "doing: Unrecognized action #{ARGV[0]}\n"
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
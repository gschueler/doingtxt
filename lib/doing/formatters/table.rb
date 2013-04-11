module Doing
    module Formatters
        class Table
            @@format="%-10s %-10s %-10s %-10s %-10s\n"
            attr_reader :output
            def format_day(time)
                time.strftime("%a %b %d")
            end
            def format_time(time)
                time.strftime("%I:%M%p") if time
            end
            def format_duration(start,final)
                final=Time.now unless final
                format_duration_secs(final.to_i-start.to_i)
            end
            def format_duration_secs(i)
                "%02d:%02d:%02d" % [
                    i/3600,
                    (i%3600)/60,
                    i%60
                ]
            end
            def task_out (lvl,task)
                d=format_day(task.start)
                if d!=@lastday
                    @lastday=d
                else
                    d=""
                end
                @output << @@format % [
                    d,
                    format_time(task.start),
                    format_time(task.end),
                    format_duration_secs(task.duration),
                    task.title
                ]
                @totaltime+=task.duration
                
                task.tasks.each { |t|
                    self.task_out(lvl+1,t)
                }
            end
            def initialize(tasks)
                @totaltime=0
                @daytime=0
                @output=[]
                multiDay=false
                @output << @@format % %w{Day Start End Duration Task}
                tasks.each do |task|
                    curday=@lastday
                    task_out(1,task)
                    if curday!=@lastday && curday
                        t=@output[-1]
                        @output[-1] = @@format % ["","","",format_duration_secs(@daytime),""]
                        @output << t
                        @daytime=0
                        multiDay=true
                    end
                    @daytime+=task.duration
                end
                @output<< @@format % ["","","",format_duration_secs(@daytime),""] if multiDay
                @output << "\n"

                @output << @@format % ["Total","","",format_duration_secs(@totaltime),""]

            end
        end
    end
end
module Doing
    module Formatters
        class Table
            @@format="%-10s %-10s %-10s %-10s %-10s\n"
            attr_reader :output
            def format_day(time)
                d=time.strftime("%a %b %d")
                if d!=@lastday
                    @lastday=d
                else
                    ""
                end
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
                # @output<<"#"*lvl
                # @output<<" #{task.title}\n"
                @output << @@format % [
                    format_day(task.start),
                    format_time(task.start),
                    format_time(task.end),
                    format_duration(task.start,task.end),
                    task.title
                ]
                @totaltime+=(task.end.to_i-task.start.to_i) if task.end
                @totaltime+=(Time.now.to_i-task.start.to_i) unless task.end
                
                task.tasks.each { |t|
                    self.task_out(lvl+1,t)
                }
            end
            def initialize(tasks)
                @totaltime=0
                @output=[]
                @output << @@format % %w{Day Start End Duration Task}
                tasks.each do |task|
                    task_out(1,task)
                end
                @output << "\n"

                @output << @@format % ["Total","","",format_duration_secs(@totaltime),""]

            end
        end
    end
end
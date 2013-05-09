module Doing
    module Formatters
        class Status
            attr_reader :output
            def task_out (task)
                if !task.lines.nil?
                    # @output<<"---\n"
                    @output<<task.lines.join("\n")
                    @output<<"\n"
                end
            end
            def initialize(tasks)
                @output=[]
                if tasks.size < 1
                    @output<<"No tasks\n"
                    return
                end
                if tasks[-1].end.nil?
                    @output<<"Currently working on: #{tasks[-1].title}\n"
                else
                    @output<<"Last worked on: #{tasks[-1].title}\n"
                end
                title=tasks[-1].title
                #look for previous logs for same task
                found=tasks[0..-2].find_all { |e| e.title==title }
                if found.size > 0
                    found.each do |i|
                        task_out(i)
                    end
                end
                if tasks[-1].lines.size>0 
                    task_out(tasks[-1])
                end
            end
        end
    end
end
module Doing
    module Formatters
        class Status
            attr_reader :output
            def task_out (task)
                if !task.lines.nil?
                    @output<<"---\n"
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
                task_out(tasks[-1])
            end
        end
    end
end
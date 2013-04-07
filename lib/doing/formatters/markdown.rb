module Doing
    module Formatters
        class Markdown
            attr_reader :output
            def task_out (lvl,task)
                @output<<"#"*lvl
                @output<<" #{task.title}\n"

                if task.meta.size
                    @output<<"\n"
                    task.meta.each do |k,v|
                        @output<<"#{k}\n"
                        @output<<":  #{v}\n"
                    end
                    @output<<"\n"
                end
                if task.lines.size > 0
                    @output<<task.lines.join("\n")
                    @output<<"\n"
                end
                task.tasks.each { |t|
                    self.task_out(lvl+1,t)
                }
            end
            def initialize(tasks)
                @output=[]
                tasks.each do |task|
                    task_out(1,task)
                end
            end
            def format(io)
            end
        end
    end
end
require 'rubygems'
require 'strscan'
require 'chronic'
require 'doing/formatters/markdown'
require 'doing/formatters/table'

# @author Greg Schueler
module Doing


class Task
    attr_accessor :title
    attr_accessor :tasks
    attr_accessor :lines
    attr_accessor :meta
    attr_accessor :parent
    attr_accessor :start
    attr_accessor :end
    def initialize(title)
        @title=title
        @tasks=[]
        @lines=[]
        @meta={}
        @parent=nil
    end

    def addTask(task)
        self.tasks<<task
        task.parent=self
    end
    def addMeta(key,value)
        @meta[key]=value
        case key
            when /^(start|begin|time|at|in)$/i
                self.start=Chronic.parse(value)
            when /^(end|done|finish(ed)?|completed?|out)$/i
                self.end=Chronic.parse(value)
        end

    end
end

class Doing
    attr_accessor :tasks
    attr_accessor :current
    def parse(io)
        item=nil#{:entries=>[],:lines=>[], :meta=>{}}
        entry=nil
        lastline=nil
        @current=nil
        io.each do |line|
            s = StringScanner.new(line)
            if em=s.scan(/#+\s+(.+)$/)
                # an item
                if item 
                    @tasks << item
                    item=nil#{:lines=>[], :meta=>{}}
                end
                item= Task.new(s[1])#[:task]=s[1]
                @current=item
            elsif em=s.scan(/##\s+(.+)$/)
                # entry
                entry = Task.new(s[1])
                # entry[:title]=s[1]
                @current=entry
            elsif em=s.scan(/\s{0,2}[:~]\s+(.+)$/) && lastline
                # definition
                # if lastline
                    @current.addMeta(lastline,s[1])
                    lastline=nil
                # end
            else
                # text line
                if lastline && lastline.size >0
                    # append line to current item
                    @current.lines<<lastline
                end
                lastline=line.strip
            end
        end
        # text line
        if lastline && lastline.size >0
            # append line to current item
            @current.lines<<lastline
        end
        #cleanup
        if item #&& item.tasks.size
            if entry && entry.lines.size
                item.addTask(entry)
                entry=nil#{:lines=>[], :meta=>{}}
            end
            @tasks << item
            item=nil#{:lines=>[], :meta=>{}}
        end
    end
    def initialize(file)
        @tasks=[]
        @file=file
        self.parse(File.open(file))
    end
    def display(format)
        #print "tasks: %d" % @tasks.size
        case format
        when 'markdown'
            print Formatters::Markdown.new(@tasks).output
        else
            print Formatters::Table.new(@tasks).output
        end
    end
    def write
        File.open(@file, "w") { |io|  
            io.write Formatters::Markdown.new(@tasks).output
        }
    end
    def startTask(title,at=nil)
        task = Task.new(title)
        task.addMeta('start',at ? at : Time.now.to_s)
        
        # check if current task is open
        if tasks.size > 0 && !tasks[-1].end
            print "Already doing something: #{tasks[-1].title}\n"
            return false
        end

        @tasks<<task
        self.display
        self.write
        return true
    end
    def endTask(at=nil)
        task=tasks[-1]
        # check if current task is open
        if task.end
            print "Not doing anything\n"
            return false
        end
        task.addMeta('end',at ? at : Time.now.to_s)

        self.display
        self.write
        return true
    end

    def append(text,index=-1)
        task=@tasks.size ? @tasks[index] : nil
        if !task
            print "No task found\n"
            return false
        end
        task.lines<<text
        self.display
        self.write
        return true
    end
end
end


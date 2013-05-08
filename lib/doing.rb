require 'rubygems'
require 'strscan'
require 'chronic'
require 'doing/formatters/markdown'
require 'doing/formatters/table'
require 'doing/formatters/status'

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
    attr_accessor :project
    def initialize(title)
        @title=title
        @tasks=[]
        @lines=[]
        @meta={}
        @parent=nil
        @reparse_end=nil
    end

    def duration
        duration=(self.end.to_i-self.start.to_i) if self.end
        duration=(Time.now.to_i-self.start.to_i) unless self.end
        duration
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
                if @reparse_end
                    self.end=Chronic.parse(@meta[@reparse_end],:now => self.start)
                    @reparse_end=nil
                end
            when /^(end|done|finish(ed)?|completed?|out)$/i
                if self.start
                    self.end=Chronic.parse(value,:now => self.start)
                else
                    @reparse_end=key
                    self.end=Chronic.parse(value)
                end
            when /^(title|task)$/i
                self.title=value
                @meta.delete(key)
        end

    end
end

class Doing
    attr_accessor :tasks
    def parse(io)
        item=nil
        entry=nil
        lastline=nil
        current=nil
        header=false
        io.each do |line|
            s = StringScanner.new(line)
            if !lastline.nil?
                current.lines<<lastline
                lastline=nil
            end
            if em=s.scan(/#\s+(.+)$/)
                # an item
                @tasks << item if item
                item= Task.new(s[1])
                current=item
                header=true
            elsif em=s.scan(/^#{3}#*\s*$/) && current.lines[-1]
                # an item
                @tasks << item if item
                item= Task.new(current.lines.pop)
                current=item
                header=true
            elsif em=s.scan(/\s{0,2}[:~]\s+(.+)$/) && current.lines[-1]
                current.addMeta(current.lines.pop,s[1])
                lastline=nil
                header=true
            else
                tline=line.strip
                if !header || tline!=""
                    lastline=tline
                end
                header=false
            end
        end
        if !lastline.nil?
            current.lines<<lastline
        end
        if item
            if entry && entry.lines.size
                item.addTask(entry)
            end
            @tasks << item
        end
    end
    def initialize(file)
        @tasks=[]
        @file=file
        self.parse(File.open(file))
    end
    def display(format=nil)
        #print "tasks: %d" % @tasks.size
        case format
        when 'markdown'
            print Formatters::Markdown.new(@tasks).output
        when 'status'
            print Formatters::Status.new(@tasks).output
        else
            print Formatters::Table.new(@tasks).output
        end
    end
    def write
        File.open(@file, "w") { |io|  
            io.write Formatters::Markdown.new(@tasks).output
        }
    end
    def parseTitle(title)
        tokens=title.split
        meta={}
        newtitle=[]
        tokens.each do |tok|
            if tok.start_with?"+"
                meta['project']=tok.slice(1..-1)
                newtitle<<tok
            elsif tok.start_with?"@"
                meta['start']=Chronic.parse(tok.slice(1..-1)).to_s
            else
                newtitle<<tok
            end
        end
        return {:title=>newtitle.join(" "),:meta=>meta}
    end
    def startTask(title,at=nil)
        parsed=self.parseTitle(title)
        task = Task.new(parsed[:title])
        task.addMeta('start',at ? at : Time.now.to_s)
        parsed[:meta].each do |k,v|
            task.addMeta(k,v)
        end
        
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
        time=Time.now.strftime("%I:%M%p")
        task.lines<<''
        task.lines<<'## At '+time
        task.lines<<''
        task.lines<<text
        self.display
        self.write
        return true
    end

    #
    # Add a metadata value to the last entry
    # 
    def addMeta(key,value,index=-1)
        task=@tasks.size ? @tasks[index] : nil
        if !task
            print "No task found\n"
            return false
        end
        task.addMeta(key,value)
        self.display
        self.write
        return true
    end
    #
    # Resume a task by starting a new task with the title of a previous one
    # 
    def resumeTask(index=-1)
        task=@tasks.size ? @tasks[index] : nil
        if !task
            print "No task found\n"
            return false
        end
        self.startTask(task.title)
    end
end
end


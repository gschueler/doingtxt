require 'strscan'

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
            when "start","begin"
                self.start=value
            when "end","done",/finish(ed)?/,/completed?/
                self.end=value
        end

    end
end

class Doing
    attr_accessor :tasks
    def parse(io)
        items=[]
        item=nil#{:entries=>[],:lines=>[], :meta=>{}}
        entry=nil
        lastline=nil
        curitem=nil
        io.each do |line|
            s = StringScanner.new(line)
            if em=s.scan(/#\s+(.+)$/)
                # an item
                if item && item.tasks.size > 0
                    if entry && entry.lines.size > 0
                        item.addTask(entry)
                        entry=nil#{:lines=>[], :meta=>{}}
                    end
                    items << item
                    item=nil#{:lines=>[], :meta=>{}}
                end
                item= Task.new(s[1])#[:task]=s[1]
                curitem=item
            elsif em=s.scan(/##\s+(.+)$/)
                # entry
                entry = Task.new(s[1])
                # entry[:title]=s[1]
                curitem=entry
            elsif em=s.scan(/\s{0,2}[:~]\s(.+)$/) && lastline
                # definition
                # if lastline
                    curitem.addMeta(lastline,s[1])
                    lastline=nil
                # end
            else
                # text line
                if lastline && lastline.size >0
                    # append line to current item
                    curitem.lines<<lastline
                end
                lastline=line.strip
            end
        end
        # text line
        if lastline && lastline.size >0
            # append line to current item
            curitem.lines<<lastline
        end
        #cleanup
        if item #&& item.tasks.size
            if entry && entry.lines.size
                item.addTask(entry)
                entry=nil#{:lines=>[], :meta=>{}}
            end
            items << item
            item=nil#{:lines=>[], :meta=>{}}
        end

        @tasks=items
    end
    def display(file)
        self.parse(File.open(file))
        print self.tasks.inspect
    end
end
end


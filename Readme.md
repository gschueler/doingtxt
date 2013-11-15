# Doing.txt

Time and task tracking in [Markdown][] format, inspired by [todo.txt][] and [Timetrap][].

[Markdown]: http://daringfireball.net/projects/markdown/ 
[todo.txt]: http://www.todotxt.com/
[Timetrap]: https://github.com/samg/timetrap

Allows you to do time tracking of what you are doing, and records it in a Markdown formatted text file.

Using a simple text format allows you to with other text-based tools, like nvAlt, Dropbox, etc.

**NOTE: This is still an experiment, but I've been using it constantly for quite a while now.**  I would recommend that if you use this to track important things, you make sure to use Dropbox or something which gives you an easy way to roll back changes if something goes wrong with your log file.

Goals:

* Most of the features of Timetrap, via commandline interface
  *  Track time of tasks
  *  Organize tasks in projects
  *  Summarize time spent on different tasks, or by date
* Simple text format with natural-language time/date
* Store my files in Dropbox, using nvAlt and Simplenote (iOS) to do any on-the-go changes.
* Learn some Ruby ;)

**NOTE: i've stopped using Simplenote synch, and there are some problems with nvAlt, notably that nvAlt can overwrite a change you made externally because it thinks it needs to synch something.** This is a bummer, but i've only seen it happen a few times.  I'm still using nvAlt with doing.txt.

## Install

build

    gem build doing.gemspec

install

    gem install doing-0.0.1.gem

## Usage

Start work:

    doing start My task

Add a note to the task:
    
    doing add My note

Finish work:

    doing done

View tasks and durations (this is the default if you don't specify a subcommand):

    doing display

Edit the text file using `$EDITOR`:

    doing edit

## Projects

Use a `+word` in a task to indicate projects:

    doing start +projectA get started

You can use that project to filter tasks when listing.

## @time

Use `@time` to start/stop a task at a certain time.

    doing start +projectA starting @8am

    doing done @12pm

If you need to indicate a different day, I usually use `@year-mm-dd,time`

    doing done @2013-11-14,6pm

TODO: @time should allow spaces

## Taking notes

Add notes to the current task using `add`, `append` or `log`:

    doing log currently yak shaving.

This will simply add a sub header with the date and time, and include your text.  Since it is under the h1 for the task, it will be included when you display notes for this task.

All notes will accrue under the same task heading, so if you keep adding notes while working on the same task name, you can view all your notes for that task using:

    doing status

## resume

Resume the last task:

    doing resume

TODO: should support @time

## split

End the current task and start a new task.

    doing split laundry @9am

Without specifying `@time`, uses the current time.

## Format

The default file is `~/.doing.txt`, and the format is Markdown, borrowing some semantics from [Pandoc](http://www.johnmacfarlane.net/pandoc/README.html#definition-lists)'s Definition Lists.  Definition
Lists are used to attach metadata to the task, including the start and end times, but you can
use them for any metadata (tags, etc).  The only caveat is that Doing will move all definition
list items to be above any other text content, so treat them only as metadata.

    # A Header defines a task
    
    Start
    :  April 7 2013, 12pm
    End
    :  1:30pm
    Data Key
    :  Data value

    Any normal text within a header section is considered "notes" for the task.

    Start and End times for the task can be defined simply by declaring the start/end
    definitions.

Synonyms for "Start" and "End" are: "begin","time","at" and "finish[ed]","complete[d]","done" respectively.

## Display formats

Doing writes the data file in the Markdown format, and displays the entries on the commandline in a table format inspired by Timetrap.

You can view a summary of the current day by doing:

    doing day

## Todo

* √ Use the metadata support for searching, tagging, etc.
    * use `doing filter/find [text]` to filter tasks with that text
    * use +project to filter the project
    * use @time to filter tasks after the given time
* √ Edit entries via commandline
  * use `doing edit vi` to edit the file with vi
* dynamically load formatters
* √ CLI opts, so that we can do "--at time" 
  * use `@time` syntax
* Run a local webapp that can edit/display the time entries?
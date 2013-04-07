# Doing.txt

Time and task tracking in [Markdown][] format, inspired by [todo.txt][] and [Timetrap][].

[Markdown]: http://daringfireball.net/projects/markdown/ 
[todo.txt]: http://www.todotxt.com/
[Timetrap]: https://github.com/samg/timetrap

## Install

    gem install doing

## Usage

Start work:

    doing start My task

Add a note to the task:
    
    doing add My note

Finish work:

    doing done

View tasks and durations:

    doing display

## Format

The default file is `~/.doing.txt`, and the format is Markdown, borrowing some semantics from [Pandoc](http://www.johnmacfarlane.net/pandoc/README.html#definition-lists)'s Definition Lists.

    # A Header defines a task

    Any normal text within a header section is considered "notes" for the task.

    You can add metadata with the Definition format from Pandoc.

    Some Metadata Key
    :  Data value

    Start and End times for the task can be defined simply by declaring those definitions:

    Start
    :  April 7 2013, 12pm
    End
    :  1:30pm

    Synonyms for "Start" and "End" are: "begin","time","at" and "finish[ed]","complete[d]","done" respectively.

The formatting should be simple enough that you can integrate this text file with other text-based tools, like nvAlt, Dropbox, etc.  However if you use the `doing` commandline then the format will be handled for you.

## Display formats

Doing writes the data file in the Markdown format, and displays the entries on the commandline in a table format inspired by Timetrap.

## Todo

* Use the metadata support for searching, tagging, etc.
* Edit entries via commandline
* dynamically load formatters
* CLI opts, so that we can do "--at time" 
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

View tasks and durations (this is the default if you don't specify a subcommand):

    doing display

Edit the text file using `$EDITOR`:

    doing edit

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

The formatting should be simple enough that you can integrate this text file with other text-based tools, like nvAlt, Dropbox, etc.

## Display formats

Doing writes the data file in the Markdown format, and displays the entries on the commandline in a table format inspired by Timetrap.

## Todo

* Use the metadata support for searching, tagging, etc.
* Edit entries via commandline
* dynamically load formatters
* CLI opts, so that we can do "--at time" 
README

HyperCal Version 3 Alpha 2

This is a rather large revision over previous versions
of HyperCal.  The main changes are that the code will
now actually be readable (novel concept) and the HTML
will be contained in template files, rather than inline
in the CGI code.

In addition to these changes, the structure of the 
data file will change to accomodate better programming
practices, and there will be no attempt to make this at
all compatible with previous versions.  I might, at some
later date, try to write a routine that converts the
old data files to the new format, but that is waaaay 
down on my list of priorities, right under dusting in 
the attic.

HyperCal is written in Perl 5, and makes use of a motley 
collection of modules.  An attempt has been made to make 
this thing run under Win32 as well as under real 
operating systems, so in cases I have chosen the method
that works under Win32 rather than the sensible way.
This will of course change in the future, when all
sensible people are using Gurusamy Sarathay's port of 
Perl.  We can all dream, can't we?

HyperCal is a production of RCBowen.com Perl Scripting.
HyperCal is distributed freely, and you are encouraged to
hack on the code as much as you like.  If you do something
really cool with it, I'd like to know about it, and would
also appreciate seeing your source code.

At some point, there is likely to be another version of
the product that lives on top of a real database - Access
for Win32, and mSQL for Unix systems.  That version will 
probably not be free, but will be more robust and faster, 
by virtue of using a real database.  Stay tuned.

Rich Bowen
RCBowen@RCBowen.com
www.rcbowen.com
December 22, 1997



Data file format

Fields in the data file are separated by $delimiter,
which defaults to '~~', but can be set to other stuff
if you prefer, for some reason.  Good candidates are 
'\0' and combinations that are not likely to occur in
event descriptions.

$record = join $delimiter, ($datetime,
							$endtime,
							$annual,
							$description,
							$type,
							$recurringid,
							$id
							);

Not Yet Implemented (or Things To Do)

The following things have not yet been put into the code,
or are still broken.

Recurring events - as in HyperCal 2.x, you will be able to
schedule events that occur event week, or every day, etc, 
for a finite period of time.  Eg., every day for 4 days.
This has not yet been put in.  Annual events are events 
that occur every year forever, and these are handled 
differently.  Obviously, we would not want to have a 
separate event in the datebook for every occurance of an
annual event between now and the apocolypse.

Announcements - as in HyperCal 2.x, you will be able to 
post an announcement that appears on the month-view of
HyperCal.  This just has not yet been written for the new
file format.

Month-at-a-glance - View all events for a month on one page

Search - Search for events that match a particular keyword

Email notification - perhaps my most requested feature - 
the ability to be notified by email about upcoming events.
Perhaps you will register for particular events, so that you
don't get email on everything. Perhaps you will register
for a particular type of event.  Event types have not yet
been implemented either.

Edit an event - due to the ghastly file format I used to use,
it was a huge pain to try to edit an existing event.  This 
should be substantially less painful now.
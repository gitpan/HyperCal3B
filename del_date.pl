#!/usr/bin/perl
##############################################################
#   File:  del_date.pl                                        
#   Author:  Rich Bowen - rbowen@rcbowen.com                  
#   Purpose:  Allows you to delete an event from a particular 
#   	day on the calendar                                   
#   Date:  Dec 27, 1997                                       
##############################################################
require "init.pl";

form_parse();
if ($FORM{routine} eq "del")	{
	&delete_event
	} else {
	&display_form
}

########

sub display_form	{
PrintHeader();

&details;
PrintTemplate("del_date");
}

sub details	{
#  Get arguments
$date=$ENV{'QUERY_STRING'};
($month,$day,$year)=split(/&/,$date);
&body_tag($month);
$details{month} = $month;
$details{day} = $day;
$details{year} = $year;
$details{month_text} = &month_txt($month);
$details{url} = $baseurl . $del_date;

# What is the "time" of this day?
$perl_month = $month -1;
$perl_year = $year - 1900;
$day_time = timelocal(0,0,0,$day,$perl_month,$perl_year);
$day_end_time = $day_time + (60*60*24);

# Get appointments for that day
open (EVENTS, "$datebook");
@events=<EVENTS>;
chomp @events;

for (@events)	{
	EventSplit($_);
	if ($Event{datetime} >= $day_time && $Event{datetime} < $day_end_time)	{ 
		push (@candidates,$_)
	} elsif ($Event{annual}) {  #  Check for annual events also
		($eventsec,$eventmin,$eventhour,
		$eventday,$eventmonth,$eventyear,
		$eventwday,$eventyday,$eventisdst) = localtime($Event{datetime});
		if ($eventday == $day
			 && $eventmonth == $perl_month  )	{
				push (@candidates, $_)
		}	
	}
}
#  End for.  @candidates contains all the events for this day

for (@candidates)	{
	EventSplit($_);
	$details{events} .= 
		"<input type=checkbox name=\"EVENT_$Event{id}\">
		       $Event{description}<br>\n";
}

}  #  End sub details


sub delete_event	{

#  Get those events from the form
for (keys %FORM)	{
	if (s/^EVENT_//)	{
		push (@to_be_deleted, $_);
	}
}

#  Delete those events from the event file
open (EVENTS, "$datebook");
@events = <EVENTS>;
close EVENTS;
chomp(@events);

for $id (@to_be_deleted)	{
#  Note that you have to use an index here ($id) because
#  grep does wierd things to $_, and so using $_ can have
#  unexpected results.
	@events = grep !/($delimiter)($id)$/, @events
}

open (EVENTS, ">$datebook");
for (@events)	{
	print EVENTS "$_\n";
	}
close EVENTS;

#  Send them on their merry way
#  For some reason, if I just print a redirect, the system
#  has not yet let go of the date file, and we get a "no data"
#  error message.  This way gives a little more time for 
#  the system to get its act together.
#
#	Yeah, I know it is strange.  If you don't like it, change it.
#####
PrintHeader();
print <<EndPage;
<html>
<head>
<META HTTP-EQUIV="Refresh" CONTENT="0; URL=$base_url$disp_day?$FORM{month}&$FORM{day}&$FORM{year}">
</head>

<body text="000000" bgcolor="FFFFFF">

If your browser does not support redirection, select the following link:
<a href="$base_url$disp_day?$FORM{month}&$FORM{day}&$FORM{year}">Events for $FORM{month}/$FORM{day}/$FORM{year}</a>

</body>
</html>
EndPage

}  #  End sub

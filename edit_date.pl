#!/usr/bin/perl
#
#####################################################################
#   Edit an existing event.                                          
#   This script is also in two parts - the first part, display_form, 
#   will display a form with the current event details in it.  The   
#   second part, edit_event, will take the contents of the form      
#   and modify the details of the event in the date file.            
#                                                                    
#   Rich Bowen                                                       
#   RCBowen.com                                                      
#   Dec 29, 1997                                                     
#####################################################################
require "init.pl";

form_parse();

if ($FORM{routine} eq "edit_event")	{
	&edit_event
} else {
	&display_form
}


########################

sub display_form	{
PrintHeader();
&details;
PrintTemplate('edit_date');
}

sub details	{

#  Get the event
open (EVENTS, "$datebook");
for $event (<EVENTS>)	{
	$EVENT = $event;  #  The variable goes away at the end of the loop
					  #  I'll have to look into that and see if it is
					  #  supposed to, or if I am doing something wierd.
	last if ($event =~ /($delimiter)($FORM{id})$/);
	$EVENT = "NOT FOUND";
}  #  End for
close EVENTS;

if ($EVENT eq "NOT FOUND")	{
	&error_print("EVENT NOT FOUND");
}
EventSplit($EVENT);

$details{description} = $Event{description};
$details{base_url} = $base_url;
$details{edit_date} = $edit_date;
$details{old} = $old;
$details{id} = $FORM{id};

if ($Event{annual})	{
	$details{annual} = "CHECKED"
}

($sec,$details{min},$details{hour},$details{day},
	$details{month},$details{year},$wday,$yday,$isdst) = 
	localtime($Event{datetime});
$details{month}++;
$details{year} += 1900;
$details{min} = sprintf "%.2d", $details{min};

#  Get the right am/pm stuff on the time
if ($details{hour} == 12)	{
	$detail{pm} = "CHECKED"
} elsif ($details{hour} > 12)	{
	$details{hour} -= 12;
	$detail{pm} = "CHECKED"
} else {  #  time is am
	$details{am} = "CHECKED"
}  #  End if..else

($sec,$details{endmin},$details{endhour},$day,
	$month,$year,$wday,$yday,$isdst) = 
	localtime($Event{endtime});
$details{endmin} = sprintf "%.2d", $details{endmin};
#  Get the right am/pm stuff on the time
if ($details{endhour} == 12)	{
	$detail{endpm} = "CHECKED"
} elsif ($details{hour} > 12)	{
	$details{endhour} -= 12;
	$detail{endpm} = "CHECKED"
} else {  #  time is am
	$details{endam} = "CHECKED"
}  #  End if..else


body_tag($details{month});

} #  End sub details

###################
#   Sub edit_event 
###################
sub edit_event	{
$perl_month = $FORM{month}-1;
$perl_year = $FORM{year}-1900;

# Strip returns from description field to make it one continuous string.
$FORM{desc} =~ s/\n/<br>/g;

# Get id number
$id = $FORM{id};

#	Rewrite time
&convert_time($FORM{'hour'},$FORM{'min'},$FORM{'ampm'});
$begin = timelocal(0,$MINS,$HOUR,$FORM{day},$perl_month,$perl_year);

&convert_time($FORM{'hour_done'},$FORM{'min_done'},$FORM{'ampm_done'});
$end = timelocal(0,$MINS,$HOUR,$FORM{day},$perl_month,$perl_year);

#  Is this an annual event?
if ($FORM{annual})	{
	$annual = 1
	} else {
	$annual = 0
	}

#  Add the new appointment to the database.
$newappt= join $delimiter, 
		($begin, $end, $annual,
		$FORM{desc}, $EVENT_TYPE,
		$RECURRING_ID, $id);

#  Remove the current version of this date
open (DATES, "$datebook");
@dates = <DATES>;
close DATES;
chomp @dates;

@dates = grep !/($delimiter)($id)$/, @dates;

#  Put the new version on there
push @dates, $newappt;

#  Write database back to disk file.
open (DATES,">$datebook") 
	|| &error_print ("Was unable to open the datebook file for writing.");
foreach $date (@dates) {
	print DATES "$date\n"
	}
close DATES;

#  Send them on their merry way
print "Location: $base_url$disp_day?$FORM{month}&$FORM{day}&$FORM{year}\n\n";
 
} #  End sub edit_event
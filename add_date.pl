#!/usr/bin/perl
#
#	Add Date
#
#	Prints html form for input of new appointment.  Sends the
#   form input to part_2 for processing.
#	Richard Bowen, 12/14/95
#	modified 12/26/1997
#	rbowen@rcbowen.com
#_____________________________________________________
require "init.pl";
&form_parse;

#  Read in date from QUERY_STRING
$date=$ENV{'QUERY_STRING'};
($month,$day,$year)=split(/&/,$date);

#  If the data came in from a POST
if ($year eq "")	{
	$month = $FORM{month};
	$day = $FORM{day};
	$year = $FORM{year};
	$routine = $FORM{routine};
	}

$perl_month = $month-1;
$perl_year = $year-1900;

#
#	Determine which part of the script is being called
#__________________________________

if ($routine eq "add_date") {&add_date}
else { &display_form };


#  Display Form
#
#	Prints html form and sends results to part 2
sub display_form	{
PrintHeader();
&details_part1; #  Get details for printing the page
PrintTemplate('add_date');
}		#  End of part 1


####################
sub details_part1 {

$details{month_text} = &month_txt($month);
$details{year} = $year;
$details{day} = $day;
$details{month} = $month;

&body_tag($month);

$details{base_url} = $base_url;
$details{add_date} = $add_date;
$details{old} = $old;
}  

sub add_date	{
#	Receives the post data from add_form and adds the information
#  to the database.  Format of database is currently:
# Get data from form post.
#  Variables are:
#  hour, min, ampm, desc, freq, perp
#  hour_done, min_done, ampm_done, days, weeks, months
#  Annual

# Strip returns from description field to make it one continuous string.
$FORM{'desc'} =~ s/\n/<br>/g;

# Get id number
$id = GetId($hypercal_id);

#	Rewrite time
&convert_time($FORM{'hour'},$FORM{'min'},$FORM{'ampm'});
$begin = timelocal(0,$MINS,$HOUR,$day,$perl_month,$perl_year);

&convert_time($FORM{'hour_done'},$FORM{'min_done'},$FORM{'ampm_done'});
$end = timelocal(0,$MINS,$HOUR,$day,$perl_month,$perl_year);

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
push @new_appointments, $newappt;

#  Write database back to disk file.
open (DATES,">>$datebook") 
	|| &error_print ("Was unable to open the datebook file for writing.");
foreach $date (@new_appointments) {
	print DATES "$date\n"
	}
close DATES;

#  Send them on their merry way
print "Location: $base_url$disp_day?$month&$day&$year\n\n";
 
}	# End of part_2
#!/usr/bin/perl
#  Display Day.  Reads in database and prints appointments for the
#  selected day.  Allows option of adding new appointment.
#
require "init.pl";
PrintHeader();

&details;
PrintTemplate('display');

##############################################

sub details	{

#   Read date from QUERY_STRING
$info=$ENV{'QUERY_STRING'};
($month,$day,$year)=split(/&/,$info);

$perl_month = $month -1;
$perl_year = $year-1900;

$details{day} = $day;
$details{year} = $year;

#  page color, link color, etc
&body_tag($month);

#  Read in database.
open (DATES, "$datebook");
@dates=<DATES>;
close DATES;

# What is the "time" of this day?
$day_time = timelocal(0,0,0,$day,$perl_month,$perl_year);
$day_end_time = $day_time + (60*60*24);

#  Checks database for listings of that day.

for $date (@dates)	{
	EventSplit($date);
	if (&event_is_today)	{
		push (@todays_events, $date);
		}
} #  End for dates

$howmany = @todays_events;
if ($howmany > 0)	{
	for $events (sort @todays_events)	{
		$details{appointments} .= "<tr>\n";  
		$details{appointments} .= "<td>";
		EventSplit($events);

		($eventsec,$eventmin,$eventhour,
		$eventday,$eventmonth,$eventyear,
		$eventwday,$eventyday,$eventisdst) = localtime($Event{datetime});

		($endsec,$endmin,$endhour,
		$endday,$endmonth,$endyear,
		$endwday,$endyday,$endisdst) = localtime($Event{endtime});

		if ($eventhour==0 and $eventmin==0 and $endhour==0 and $endmin==0) {
			$details{appointments} .= "(All day)";
		} else {
			$EventTime = MakeTime($eventhour,$eventmin);
			$details{appointments} .= $EventTime;
			if ($endhour != 0 || $endmin != 0) {
				$EndTime = MakeTime($endhour,$endmin);
				$details{appointments} .= " - $EndTime"
			}
		}  #  End else
		$details{appointments} .= <<EndDetail;

		</td><td>$Event{description}  <small>[
		 <a href="$edit_date?id=$Event{id}">Edit event</a> ]</small>
		</td></tr>
EndDetail
		
	}  #  End for
}  else  {  #  There were no events for this day
	$details{appointments} = 
	  "<tr><th colspan=2 align=center>** No Events **<br>";
}

$details{add} = "$base_url$add_date?$month&$day&$year";
$details{delete} = "$base_url$del_date?$month&$day&$year";
$details{calendar} = "$base_url$hypercal?$month&$year";
			
}  #  End sub details

sub event_is_today	{
	if ($Event{datetime} >= $day_time &&
			$Event{datetime} < $day_end_time) {
		return 1;
		}
	elsif ($Event{annual})	{

		($eventsec,$eventmin,$eventhour,
		$eventday,$eventmonth,$eventyear,
		$eventwday,$eventyday,$eventisdst) = localtime($Event{datetime});

		if ($eventday == $day && ($eventmonth+1) == $month)	{
		return 1;
		}
	}

return 0;
}

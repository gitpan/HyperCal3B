#!/usr/bin/perl
#	HyperCal   by   Richard Bowen
#  A HTML datebook.  
#  This part draws the calendar and links it to the other scripts.
#  Can be called as http://URL/hypercal, or with arguments
#  as http://URL/hypercal?month&year
require "init.pl"; ## Load variables and shared routines

#  Reads arguments.  If no arguments, it will default to current month.
$args=$ENV{QUERY_STRING}; 

# ______________________________
#
#	The main part here - This is the part that prints the
#  calendar as an HTML table, and links each day to listings of
#  appointments for that day.
#
# _______________________________

#  Print the HTML page
PrintHeader();
&details;  #  Get some more details
PrintTemplate('hypercal');

###############################
#  End of main program


sub details	{
#  Determine some of the details to be printed on the calendar

# Determine what "today" is.
($sec,$min,$hour,$today_day,$today_month,$today_year,$today_wday,$yday,$isdst)
           =localtime(time);
$today_month ++;
$today_year += 1900; 

#  Get the month, year, from the command line
($this_month,$this_year)=split(/&/,$args);
$this_month =~ s/^month=//;
$this_year =~ s/^year=//;

#  Need some error checking ...
if ($FORM{month} eq ""){$FORM{month}=1};
if ($FORM{year} eq""){$FORM{year}=1901};
if ($FORM{month}>12) {$FORM{month}=12};
if ($FORM{month}<1) {$FORM{month}=1};
if ($FORM{year}<1) {$FORM{year}=1};
if ($FORM{year}>9999) {$FORM{year}=9999};

if ($args eq "") {	#  Defaults to current date if none specified.
	$this_month = $today_month;
	$this_year = $today_year;
}  #  Endif

$perl_year = $this_year - 1900;
$perl_month = $this_month - 1;

$details{year} = $this_year;
$details{month_text} = &month_txt($this_month);

#  page color, link color, etc
&body_tag($this_month);

#	Read datebook into memory
#
open (DATES, $datebook);
@datebook=<DATES> ;
close DATES;

#  What's the last day of the month?
#	I love this piece of code here!  I find out what the
#	first day of next month is, subtract a few seconds, and
#	then find out what day that is.
$__next_month = $perl_month+1;
$__next_year = $perl_year;
if ($__next_month == 12) {
	$__next_month =0;
	$__next_year = $perl_year+1
}
$firstday_nextmonth = timelocal(0,0,0,1,$__next_month,$__next_year);
$last_day_in_month = (localtime($firstday_nextmonth-2))[3];

#  What's the first day in the month (weekday)
$firstday_time = timelocal(0,0,0,1,$perl_month,$perl_year);
$firstday = (localtime($firstday_time))[6];

############################################################
#   Since we are looking at just one month, it would        
#    make sense at this point to take a few microseconds to 
#    pull out just the events for this month, hmmmm?
#  This will save time later        
############################################################

for (@datebook)	{
	EventSplit($_);

	if ($Event{annual} || (($Event{datetime} >= $firstday_time) && 
				($Event{datetime} < $firstday_nextmonth)) )	{
		push @thismonth_datebook, $_
		} #  End if
	}  #  End for
@datebook = @thismonth_datebook;


#  Print some blank cells for the space before the first
#  day of the month
######################
$details{calendar} .= "<tr><td colspan=$firstday></td>\n" 
			unless ($firstday == 0);

$week_day = $firstday;
$now = time;

#  Loop through all the days in the month
for ($date_place = 1; $date_place <= $last_day_in_month; $date_place++)	{
	#  Print that day's stuff

	#  Is is a sunday?  Begin a new row
	if ($week_day == 0) {
		$details{calendar} .= "<tr> "
		}  #  End if sunday

	# What is the "time" of this day?
	$day_time = timelocal(0,0,0,$date_place,$perl_month,$perl_year);
	$day_end_time = $day_time + (60*60*24);

	$details{calendar} .= "<td align=center";

	#  Highlight today
	if ($now >= $day_time and $now <=$day_end_time and $highlight ne "none")	{
		$details{calendar} .= " bgcolor=$highlight"
		}
	$details{calendar} .= ">\n";

	#  OK, now the time consuming part - what happens this day?
	$event_count = 0;
	for (@datebook)	{
		EventSplit($_);

		#  How about annual events?
		if ($Event{annual}) 	{
			my ($_sec,$_min,$_hour,$_day,$_mon,$_year,$_wday,$_yday,$_isdst)
				= localtime($Event{datetime});
			if ($_day == $date_place && $_mon == $perl_month)	{
				$event_count++
				}
			}  else	{  # The rest of the events
			if ($Event{datetime} >= $day_time and
				 $Event{datetime} < $day_end_time) {
					$event_count++
				}  #  End if
			} #  End else 
		}  #  End for datebook

	$details{calendar} .= "<a href=\"$base_url$disp_day?$this_month&$date_place&$this_year\"> $date_place </a>";
	if ($event_count >0) {
		$details{calendar} .= "<br><small>($event_count)</small>";
		}
	$details{calendar} .= "</td>\n";
	
	#  Is is a Saturday?  That's the end of the row.
	if ($week_day == 6) {
		$details{calendar} .= "</tr>\n"
		}  #  End if saturday

	$week_day ++;
	if ($week_day == 7) {$week_day = 0};  #  Start the week over

	}  # End for date_place - repeated for each day in the month


# Announcements for the month
open (ANNO, "$announce");
@announce=<ANNO>;
close ANNO;
$any_announce = "no";

for $announces (@announce)	{
	AnnounceSplit($announces);
	if ($Announce{month} eq $this_month && 
		($Announce{year} eq $this_year || $Announce{year} eq "xxxx") )   {
		if ($any_announce eq "no")  {
			$details{announcements} = "<tr><td align=center colspan=7>"
			}
		$details{announcements} .= "<center><b>$Announce{announcement}</b></center>";
   		$any_announce="yes";
   		}  #  end if
	}  #  End for

#  Goto form

$details{goto} = <<EndForm;

<form method=GET action=$base_url$hypercal>
<input type=submit value="Jump"> to 
<input name="month" size=2> /
<input name="year" size=4 value="$this_year">
</form></center>

EndForm

#  Link to other months

########################################################################
#   Someone had the cool idea that we link to the nearest few months -  
#   that is, have links to "January", "February", etc.  Might do        
#   this later.                                                         
########################################################################

$details{month_view} = $base_url . $month_view 
				. "?month=$this_month&year=$this_year";

$last_year=$this_year;
$last_month=($this_month-1);
if ($last_month == 0) 
	{$last_month=12;
	 $last_year=($this_year-1)
	 }
$details{prev_month} ="$base_url$hypercal?$last_month&$last_year";

$next_year=$this_year;
$next_month=($this_month+1);
if ($next_month == 13) 
	{$next_month=1;
	 $next_year=($this_year+1)
	 }
$details{next_month} = "$base_url$hypercal?$next_month&$next_year";

$details{current} = "$base_url$hypercal";

#  Links to edit announcements

$details{edit_announcements} = 
	"<a href=\"$base_url$add_announce?month=$this_month&year=$this_year\">Add announcements for this month</a>";

if ($any_announce eq "yes")	{
	$details{edit_announcements} .= <<EndDetail; 
| <a href="$base_url$del_announce?month=$this_month&year=$this_year">Delete
             announcements for this month</a>
| <a href="$base_url$edit_announce?month=$this_month&year=$this_year">Edit
             announcements for this month</a>

EndDetail
	}  #  End if


}  #  End sub details


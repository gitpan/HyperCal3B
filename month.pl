#!/usr/bin/perl
#  Displays a month's worth of days.
require "init.pl";

PrintHeader();

&details;
PrintTemplate("month_view");

#######################

sub details	{
form_parse();

if ($FORM{year} eq "")  {
    ($sec,$min,$hour,$day,$FORM{month},$FORM{year},$w,$y,$i) =
            localtime(time);
	$FORM{month}++;
	$FORM{year} += 1900;
}


&month_txt("$FORM{month}");
body_tag($FORM{month});
$details{month} = $FORM{month};
$details{year} = $FORM{year};
$details{hypercal} = $base_url . $hypercal;

$perl_month = $FORM{month}-1;
$perl_year = $FORM{year} - 1900;

#  Read in database.
$any="no";     #  Flag which determines if appts were found.
open (DATES, "$datebook");
@dates=<DATES>;
close DATES;

for $date (sort(@dates))	{
	EventSplit($date);
	($esec,$emin,$ehour,$eday,$emonth,$eyear,$ewday,$eyday,$eisdst)
				 = localtime($Event{datetime});

#  Condition here:  If the event occurs in the given month AND
#  either this is the correct year, or it's annual, then ...
	if (  $emonth == $perl_month && 
		 	( $eyear == $perl_year || $Event{annual} ))	{

		# Figure out the duration

		($endsec,$endmin,$endhour,
		$endday,$endmonth,$endyear,
		$endwday,$endyday,$endisdst) = localtime($Event{endtime});

		if ($ehour==0 and $emin==0 and $endhour==0 and $endmin==0) {
			$duration = "(All day)";
		} else {
			$EventTime = MakeTime($ehour,$emin);
			$duration = $EventTime;
			if ($endhour != 0 || $endmin != 0) {
				$EndTime = MakeTime($endhour,$endmin);
				$duration .= " - $EndTime"
			}
		}  #  End else
			

		#######################

		$MonthEvents{$eday} .= <<EndDetail;

<tr><td>$duration</td>
<td>$Event{description}</td></tr>

EndDetail
		}  #  End if

}  #  End for

for (sort (keys %MonthEvents))	{
	$details{events} .= <<EndDetail;

<tr><th colspan=2 align=left>$_</th></tr>
$MonthEvents{$_}


EndDetail

}  #  End for

} #  End sub details
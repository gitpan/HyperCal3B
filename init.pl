#########################################################################
#  Variables
#  aka Constants and routines
#
#	Customize this for your site
#   If you don't know what a particular variable means, chances are you don't 
#   need to change it, but check this entire file carefully.
#   Remember to escape special characters such as \@ and \# 
#########################################################################
$details{version}="3.00 Alpha 4";
$server_name = "localhost";
$delimiter = "~~";

# Names of the various program files
#  Some sites only allow cgi's with a .cgi extension
#  so you might need to change your file names

# URL of the directory in which these files live
$base_url="/hypercal/";

#  Location of the hypercal templates - you may need to specify full path
$templates = "e:/rcbowen.com/hypercal/templates";
$display_html = "$templates/display.html";
$add_date_html = "$templates/add_date.html";

# eg might need to be
# $add_date="add_date.cgi";
$add_date="add_date.pl";
$del_date="del_date.pl";
$edit_date="edit_date.pl";
$disp_day="disp_day.pl";
$add_announce="add_announce.pl";
$del_announce="del_announce.pl";
$edit_announce="edit_announce.pl";
$month_view="month.pl";
$hypercal="hypercal.pl";

# Other files
#  You probably don't want to change this stuff

$datebook="datebook";
$hypercal_id="hypercal_id";
$announce="announce";
$announce_id="announce_id";

####################################
# variables 

#  Number of days to keep past dates
$old=370;

# Person to contact with problems
# Your info goes here - don't make this me, please
$admin="Admin Guru";
$admin_mail="admin\@yoursite.com";

# Title of the calendar.
$details{title}="HyperCal Version $details{version}";

$highlight="red";  # What color should "today" be highlighted in?

#  This array contains the locations of images for the various
#  months.  The format is
#  [url_for_icon,url_for_background,bgcolor,text,link,visited link]
#  This array must contain 12 elements. Any field where you have 
#  no preference, indicate by 'none'
@month_images=(
	['/images/months/january.gif','none','333399','none','FFFF00','55FF8B'],
	['/images/months/february.gif','none','none','none','none','none'],
	['/images/months/march.gif','none','none','none','none','none'],
	['/images/months/april.gif','none','none','none','none','none'],
	['/images/months/may.gif','none','none','none','none','none'],
	['/images/months/june.gif','none','none','none','none','none'],
	['/images/months/july.gif','none','none','none','none','none'],
	['none','none','none','none','none','none'],
	['none','none','FFFFFF','000000','none','none'],
	['/images/months/october.gif','none','000000','FFFF00','00DD00','9168D7'],
	['/images/months/november.gif','none','FFFFFF','000033','none','none'],
	['/images/months/december.gif','none','DDDDFF','FF3333','none','none']
	);

##Load the time routines, set some date variables
require "timelocal.pl";
@months=('December', 'January', 'February',
		 'March', 'April', 'May', 'June',
		 'July', 'August', 'September',
		 'October', 'November', 'December');

###########################################################
#   	Below here are routines for the programs to use.   
#   	Don't modify them.  You should have fixed all      
#   	the variables above this point.                    
###########################################################

sub PrintHeader	{print "content-type: text/html \n\n"}

sub form_parse  {
	if ($ENV{REQUEST_METHOD} eq "GET")	{
		$buffer = $ENV{QUERY_STRING}
	} else	{ #  Data was POSTed
		read (STDIN, $buffer, $ENV{'CONTENT_LENGTH'})
	}
	@pairs = split(/&/, $buffer);

	foreach $pair (@pairs) {
    	($name, $value) = split(/=/, $pair);
    	$value =~ tr/+/ /;
    	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    	$value =~ s/~!/ ~!/g;
    	$FORM{$name} = $value;
	}     # End of foreach
}	#  End of sub


sub month_txt   {  # converts number to month text
my $month = shift;
return ( ('ERROR','January','February','March',
			'April','May','June','July',
			'August','September','October',
			'November','December')[$month] );
                }

sub body_tag	{
my $month = shift;

$details{month_text} = &month_txt($month);

my @fields=('image','background','bgcolor','text','link','vlink');

for (0..5)	{
	$details{$fields[$_]} = 
		" $fields[$_] = $month_images[$month-1][$_] "
			unless ($month_images[$month-1][$_] eq "none");
		}  #  End for
$details{month_image} = "<img src=\"$month_images[$month-1][0]\">"
		 unless ($month_images[$month-1][0] eq "none");
}  #  End sub body_tag

sub error_print	{
PrintHeader();
my $error = shift;
print "<b>$error</b><br>";
exit(0);
}

sub PrintTemplate	{
my $filename = shift;
my $template = $templates . "/" . $filename . ".html";
open (TEMPLATE, $template);
for (<TEMPLATE>)	{
	s/%%%(.*?)%%%/$details{$1}/g;
	print;
	}
}

sub EventSplit	{
#  Splits an event record into the global variable %Event
#  Perhaps this is not a great idea.  Revisit later
	$_ = shift;
	chomp;
	($Event{datetime},
	 $Event{endtime},
	 $Event{annual},
	 $Event{description},
	 $Event{type},
	 $Event{recurringid},
	 $Event{id} ) = split (/$delimiter/);
}

sub AnnounceSplit	{
#  Splits an announcement record into the global variable %Announce
#  Perhaps this is not a great idea.  Revisit later
	$_ = shift;
	chomp;
	($Announce{month},
	 $Announce{year},
	 $Announce{announcement},
	 $Announce{id} ) = split (/$delimiter/);
}

sub GetId	{
my $idfile = shift;
open (ID, "$idfile") 
       || &error_print("Was unable to open the ID file for reading");
my $id=<ID>;
close ID;
$id++;
if ($id>=999999) {$id=1};
open (NEWID,">$idfile")  
      || &error_print ("Was unable to open the ID file ($idfile) for writing");
print NEWID $id;
close NEWID;
return $id;
}

sub MakeTime	{
#  Takes an hour and a minute value as params.
#  Returns a "time" value in am/pm form.
my ($hour,$min) = @_;
my $am = "am";
my $MakeTime = "";

$min = sprintf "%.2d", $min;

if ($hour == 12)	{
	$am = "pm"
} elsif ($hour >= 12)	{
	$am = "pm";
	$hour -= 12;
} else	{
#  Time was am.  Leave it alone
}
$MakeTime = $hour . ":" . $min . " " . $am;
return $MakeTime;
}

#
#	Sub 24time
#  Rewrites time into 24hr format.
#
sub convert_time	{
$HOUR=shift;
$MINS=shift;
$merid=shift;
if ($merid eq "pm") {
 $HOUR+=12;
 if ($HOUR==24) {$HOUR=12}
		}
if ($HOUR==12 && $merid eq "am"){$HOUR=24};
if ($HOUR>24){$HOUR=23};
if ($MINS>59){$MINS=59};
$HOUR=sprintf "%02.00f",$HOUR;
$MINS=sprintf "%02.00f",$MINS;
}


#########################################################
# Do not change this, Do not put anything below this.
# File must return "true" value at termination
1;
##########################################################

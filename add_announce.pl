#!/usr/bin/perl
##########################################################
#   Add an announcement                                   
#   Announcements will be displayed on the bottom of the  
#   calendar - or wherever you put the %%%announce%%% tag 
#   Announcements can be for one month, or annual         
#                                                         
#   Rich Bowen                                            
#   RCBowen.com                                           
#   Dec 29, 1997                                          
#                                                         
##########################################################
require 'init.pl';

form_parse();
if ($FORM{routine} eq "add_announce")	{
	&add_announce
}  else  {
	&display_form
}

sub display_form	{
PrintHeader();
&details;
PrintTemplate("add_announce"); 
}  # End sub display_form

sub details	{

body_tag("$FORM{month}");
$details{year} = $FORM{year};
$details{month} = $FORM{month};

$details{url} = "$base_url$add_announce";
}  #  End sub details

sub add_announce	{
if ($FORM{annual})	{
	$year = "xxxx"
}  else  {
	$year = $FORM{year}
}

$id = GetId($announce_id);
$FORM{announce} =~ s/\n/<br>/g;

$announcement = join $delimiter, ($FORM{month},
								  $year,
								  $FORM{announce},
								  $id
								 );

open (ANNOUNCE, ">>$announce");
print ANNOUNCE "$announcement\n";
close ANNOUNCE;

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
<META HTTP-EQUIV="Refresh" CONTENT="0; URL=$base_url$hypercal?$FORM{month}&$FORM{year}">
</head>

<body text="000000" bgcolor="FFFFFF">

If your browser does not support redirection, select the following link:
<a href="$base_url$disp_day?$FORM{month}&$FORM{year}">Calendar for $FORM{month} $FORM{year}</a>

</body>
</html>
EndPage
}
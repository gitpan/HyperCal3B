#!/usr/bin/perl
#
##############################################
#   file: edit_announce.pl                    
#   Author: Rich Bowen                        
#   Date: December 29, 1997                   
#                                             
#   Edit announcements for a particular month 
##############################################
require "init.pl";
form_parse();

if ($FORM{routine} eq "edit_announce")	{
	&edit_announce
} elsif ($FORM{id})	{ #  Invoked with an announcement id#
	&display_form
} else	{
	&list_announce
}  #  End if..else

sub list_announce	{
#  List all the announcements for this month

PrintHeader();
&details_list;
PrintTemplate("list_announce");
}

sub details_list	{

open (ANNOUNCE, "$announce");
@announce = <ANNOUNCE>;
close ANNOUNCE;

@candidates = grep /^($FORM{month})($delimiter)/, @announce;

for (@candidates)	{
	AnnounceSplit($_);
	$details{announce} .= <<EndDetail;

<li><a href="$base_url$edit_announce?id=$Announce{id}&year=$FORM{year}">$Announce{announcement}</a><br>
EndDetail

body_tag($FORM{month});
$details{year} = $FORM{year};
}  #  End for

} #  End sub details

sub display_form	{
$details{year} = $FORM{year};

#  Get the announcement details
open (ANNOUNCE, "$announce");
@announce = (<ANNOUNCE>);
close ANNOUNCE;

@announce = grep /($delimiter)($FORM{id})$/, @announce;
AnnounceSplit($announce[0]);
body_tag($Announce{month});
$details{month} = $Announce{month};

$details{id} = $FORM{id};
$details{announcement} = $Announce{announcement};
$details{url} = $base_url . $edit_announce;
if ($Announce{year} eq "xxxx")	{
	$details{annual} = "CHECKED";
}  #  End if

PrintHeader();
PrintTemplate("edit_announce");

}  #  End sub display_form

sub edit_announce	{

#  Get rid of the current version
open (ANNOUNCE, "$announce");
@announce = <ANNOUNCE>;
close ANNOUNCE;
chomp @announce;

@announce = grep !/($delimiter)($FORM{id})$/, @announce;

#  Build the correct new one
if ($FORM{annual})	{
	$year = "xxxx"
}
$new_announce = join $delimiter, ($FORM{month},
								  $year,
								  $FORM{announcement},
								  $FORM{id}
								 );
push @announce, $new_announce;

open (ANNOUNCE, ">$announce");
for (@announce)	{
	print ANNOUNCE "$_\n";
}
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
<a href="$base_url$hypercal?$FORM{month}&$FORM{year}">Calendar for $FORM{month}/$FORM{year}</a>

</body>
</html>
EndPage
}
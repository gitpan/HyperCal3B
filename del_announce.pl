#!/usr/bin/perl
##############################################################
#   File:  del_announce.pl                                        
#   Author:  Rich Bowen - rbowen@rcbowen.com                  
#   Purpose:  Allows you to delete an announcement from a particular 
#   	month on the calendar                                   
#   Date:  Dec 29, 1997                                       
##############################################################
require "init.pl";

form_parse();
if ($FORM{routine} eq "del")	{
	&delete_announce
	} else {
	&display_form
}

########

sub display_form	{
PrintHeader();

&details;
PrintTemplate("del_announce");
}

sub details	{
#  Get arguments
form_parse();
&body_tag($FORM{month});
$details{month} = $FORM{month};
$details{year} = $FORM{year};
$details{url} = $baseurl . $del_announce;

# Get appointments for that day
open (ANNOUNCE, "$announce");
@announce=<ANNOUNCE>;
chomp @announce;

@candidates = grep /^($FORM{month})($delimiter)/, @announce;

for (@candidates)	{
	AnnounceSplit($_);
	$details{announce} .= 
		"<input type=checkbox name=\"ANNOUNCE_$Announce{id}\">
		       $Announce{announcement}<br>\n";
}

}  #  End sub details


sub delete_announce	{

#  Get those events from the form
for (keys %FORM)	{
	if (s/^ANNOUNCE_//)	{
		push (@to_be_deleted, $_);
	}
}

#  Delete those events from the event file
open (ANNOUNCE, "$announce");
@announce = <ANNOUNCE>;
close ANNOUNCE;
chomp(@announce);

for $id (@to_be_deleted)	{
#  Note that you have to use an index here ($id) because
#  grep does wierd things to $_, and so using $_ can have
#  unexpected results.
	@announce = grep !/($delimiter)($id)$/, @announce
}

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

}  #  End sub

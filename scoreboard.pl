#!/usr/bin/perl
use warnings;
use POSIX;
print "****First Innings of first team****\n";
scorecard("inn1_1.txt");
print "\n****First Innings of second team****\n";
scorecard("inn2_1.txt");
print "\n****Second Innings of first team****\n";
scorecard("inn1_2.txt");
print "\n****Second Innings of second team****\n";
scorecard("inn2_2.txt");

sub scorecard{
my $line=0,$count=0,$extra_runs=0,$extra_balls=0,$fours=0,$sixes=0,$wicket=0,$total_runs=0,$wickets_taken=0,$maiden_flag=0;
my $maiden_overs=0,$extra_flag=0,$balls_played=0,$lb=0,$w=0,$nb=0,$b=0,$runs_given=0,@bowler_names=(),@batsman_names=();
$count=0;
$extra_runs=0;
$extra_balls=0;
$fours=0;
$sixes=0;
$total_runs=0;
$wickets_taken=0;
my %batsman=(),%bowler=(),%overs=(),%out=(),%extras=(),%fours=(),%sixes=(),%wickets_taken=(),%maiden_overs=(),%balls_played=(),%runs_given=();
my @fall_of_wickets=(),$over=0,$out_count=0;
$maiden_flag=1;
open FILE, $_[0] or die "Cannot open file!";
sub determine_action
{
		my $action=$_[0],$temp=0,$bowler_name=$_[1],$batsman_name=$_[2];
		if($action=~/FOUR/)
		{
			$maiden_flag=0;
			$temp+=4;
			$fours{$batsman_name}+=1;
			$balls_played{$batsman_name}=0 unless exists $balls_played{$batsman_name};
			$balls_played{$batsman_name}+=1;
			if($action!~/\(no ball\)/)
			{
				$count++;
			}
		}
		elsif($action=~/(\d)\s(run|runs)/)
		{
			$temp+=$1;
			$maiden_flag=0;
			if($action!~/\(no ball\)/)
			{
				$count++;
				$balls_played{$batsman_name}=0 unless exists $balls_played{$batsman_name};
				$balls_played{$batsman_name}+=1;
			}
		}
		elsif($action=~/no run/)
		{
			$balls_played{$batsman_name}=0 unless exists $balls_played{$batsman_name};
			$balls_played{$batsman_name}+=1;
			$count++;
		}
		if($action=~/SIX/)
		{
			$temp+=6;
			$sixes{$batsman_name}+=1;
			$maiden_flag=0;
			if($action!~/\(no ball\)/)
			{
				$count++;
				$balls_played{$batsman_name}=0 unless exists $balls_played{$batsman_name};
				$balls_played{$batsman_name}+=1;
			}
		}
		if($action=~m/(\d)\sleg\s(bye|byes)/)
		{
			$extra_runs+=$1;
			$lb+=$1;
			if($action!~/\(no ball\)/)
			{
				$count++;
				$balls_played{$batsman_name}=0 unless exists $balls_played{$batsman_name};
				$balls_played{$batsman_name}+=1;
			}
		}
		if($action=~/(\d)\s(bye|byes)/)
		{
			$extra_runs+=$1;
			$maiden_flag=0;
			$b+=$1;
			if($action!~/\(no ball\)/)
			{
				$count++;
			}
		}
		if($action=~/no ball/)
		{
			if($action=~/(\d)\sno\s(ball|balls)/)
			{
				$extra_balls+=$1;
				$nb+=$1;
				$extra_runs+=$1;
				$extras{$bowler_name}=0 unless exists $extras{$bowler_name};
				$extras{$bowler_name}+=1;
				$maiden_flag=0;
				if($over=~/^(\d*)\.6/)
				{	
					$extra_flag=1;
				}
				$balls_played{$batsman_name}=0 unless exists $balls_played{$batsman_name};
				$balls_played{$batsman_name}+=1;	
			}
			else
			{
				$extra_balls+=1;
				$nb+=1;
				$extra_runs+=1;
				$extras{$bowler_name}=0 unless exists $extras{$bowler_name};
				$extras{$bowler_name}+=1;
				$maiden_flag=0;
				if($over=~/^(\d*)\.6/)
				{	
					$extra_flag=1;
				}
				
				$balls_played{$batsman_name}=0 unless exists $balls_played{$batsman_name};
				$balls_played{$batsman_name}+=1;
			}
		}
		if($action=~/(\d) wide|wides/)
		{
			if($action=~/(\d)\swides/)
			{
				$extra_balls+=$1;
				$extra_runs+=$1;
				$extras{$bowler_name}=0 unless exists $extras{$bowler_name};
				$extras{$bowler_name}+=1;
				$maiden_flag=0;
				if($over=~/^(\d*)\.6/)
				{	
					$extra_flag=1;
				}
				$w+=$1;
			}
			else
			{
				$extra_balls+=$1;
				$extra_runs+=$1;
				$extras{$bowler_name}=0 unless exists $extras{$bowler_name};
				$extras{$bowler_name}+=$1;
				$maiden_flag=0;
				if($over=~/^(\d*)\.6/)
				{	
					$extra_flag=1;
				}
				$w+=$1;
			}
		}
		#if($x=~/, (.*?), (\w*)/)
		#{
		#	if($2=~/OUT/)
		#	{
		#		$wickets_taken{$bowler_name}=0 unless exists $wickets_taken{$bowler_name};
		#		$wickets_taken{$bowler_name}+=1;
		#		$balls_played{$batsman_name}=0 unless exists $balls_played{$batsman_name};
		#		$balls_played{$batsman_name}+=1;
		#		return $temp.-1;
		#	}
		#}
		if($action=~/OUT/)
		{
			$wickets_taken{$bowler_name}=0 unless exists $wickets_taken{$bowler_name};

			$wickets_taken{$bowler_name}+=1;
			$balls_played{$batsman_name}=0 unless exists $balls_played{$batsman_name};
			$balls_played{$batsman_name}+=1;
			if($temp!=0)
			{
				$maiden_flag=0;
			}
			$count++;
			return -1;
		}
		return $temp;
}
sub calc_overs
{
	my $c=0;
	while(($key,$value)=each %bowler)
	{
		if($key ~~ %extras)
		{
			$c+=($bowler{$key}-$extras{$key});
		}
		else
		{
			$c+=$bowler{$key};
		}
	}
	if($c%6 eq 0)
	{
		return ($c/6);
	}
	else
	{
		$s=floor($c/6).".".($c%6);
		return $s;
	}
}

my $flag=0;

while($line=readline(FILE))
{
	if($line=~m/(^(\d)*.[0-6]\n)/ && ($line !~m/ *\.*am/ || $line!~m/ *\.*/pm))
	{
		$over=$1;
		if($over=~/^(\d*)\.6/)
		{
			$flag=1;
		}
		$line=readline(FILE);
		#if($line=~/([A-Z][a-z]*\s)to ([A-Z]*[a-z]*\s*[A-Z]*[a-z]*), (.*?),/)
		#if($line=~/([A-Z-]*[a-z-]*\s*[A-Z-]*[a-z-]*)to ([A-Z-]*[a-z-]*\s*[A-Z-]*[a-z-]*), (.*?),/)
		if($line=~/([A-Z-]*[a-z-\s*]*\s*[A-Z-]*[a-z-\s*]*)to ([A-Z-]*[a-z-\s*]*\s*[A-Z-]*[a-z-\s*]*),\s(.*?)(,|\n)/)
		{
			if(!exists $bowler{$1})
			{
				$bowler{$1}=0;
				push(@bowler_names,$1);
			}
			if(!exists $batsman{$2})
			{ 
				$batsman{$2}=0;
				push(@batsman_names,$2);
			}
			my $act=$3;
			$bowler{$1}+=1;
			$result=determine_action($act,$1,$2,$line);
			if($result!=-1)
			{
				$batsman{$2}+=$result;
				$runs_given{$1}=0 unless exists $runs_given{$1};
				$runs_given{$1}+=$result;
			}
			if($result eq -1)
			{
				$out{$2}=$1;
				$total_runs=0;
				while(($key,$value)=each %batsman)
				{
					$total_runs+=$batsman{$key};
				}
				$out_count++;
				push(@fall_of_wickets,$out_count,"-",$total_runs+$extra_runs,"(",$2,",",$over,"ov)");
			}
			if($count eq 6)
			{	
				if($maiden_flag eq 1)
				{
					$flag=0;
					$maiden_flag=1;
					$maiden_overs{$1}=0 unless exists $maiden_overs{$1};
					$maiden_overs{$1}+=1;
					$count=0;
				}
				else
				{
					$maiden_flag=1;
					$flag=0;
					$count=0;
				}
			}
		}		
	}
}
print "Batsman\t\t\t\tR\tB\t4's\t6's\tSR\n";
$total_runs=0;
foreach(@batsman_names)
{
	$total_runs+=$batsman{$_};
	if($_ ~~ %fours)
	{
		$fours=$fours{$_};
	}
	if($_ ~~ %balls_played)
	{
		$balls_played=$balls_played{$_};
	}
	if($_ ~~ %sixes)
	{
		$sixes=$sixes{$_};
	}
	if($_ ~~ %out)
	{
		$wicket=$out{$_};
		print "$_\t\t\t$batsman{$_}\t$balls_played\t$fours\t$sixes\t",($batsman{$_}/$balls_played)*100,"\t\twicket by $wicket\n";
	}
	else
	{
		print "$_\t\t\t$batsman{$_}\t$balls_played\t$fours\t$sixes\t",($batsman{$_}/$balls_played)*100,"\tNOT OUT\n";
	}
	$fours=0;
	$sixes=0;
	$balls_played=0;
}
print "\nExtras\t($lb lb,$w w,$nb nb,$b b)\t$extra_runs\n\n";
$total_overs=calc_overs();
if((scalar (keys %out)) eq 10)
{
	print "\nTotal\t","(all out",";",$total_overs,"overs)","\t",($total_runs+$extra_runs),"\t(",($total_runs+$extra_runs)/$total_overs,"runs per over)\n";	
	
}
else
{
	print "\nTotal\t","(",scalar (keys %out)," wickets",";",$total_overs,"overs)","\t",($total_runs+$extra_runs),"\t(",($total_runs+$extra_runs)/$total_overs,"runs per over)\n";
}
print "\nFall of wickets:";
for(my $i=0;$i<scalar @fall_of_wickets;$i++)
{
	print $fall_of_wickets[$i];
}
print "\n\nBowler\t\t\tO\tM\tR\tW\tEcon\n";
foreach(@bowler_names)
{
	if($_ ~~ %wickets_taken)
	{
		$wickets_taken=$wickets_taken{$_};
	}
	if($_ ~~ %maiden_overs)
	{
		$maiden_overs=$maiden_overs{$_};
	}
	if($_ ~~ %runs_given)
	{
		$runs_given=$runs_given{$_};
	}
	if($_ ~~ %extras)
	{
		my $e=$extras{$_};
		if(($bowler{$_}-$e)%6 != 0)
		{
			my $eco=($runs_given+$e)/((floor(($bowler{$_}-$e)/6)).".".(($bowler{$_}-$e)%6));
			print $_,"\t\t\t",floor(($bowler{$_}-$e)/6),".",($bowler{$_}-$e)%6,"\t$maiden_overs\t",$runs_given+$e,"\t$wickets_taken\t$eco\t($e extras)\t\n";
		}
		else
		{
			my $l=($bowler{$_}-$e)/6;
			my $eco=($runs_given+$e)/$l;
			
			print $_,"\t\t\t",($bowler{$_}-$e)/6,"\t$maiden_overs\t",$runs_given+$e,"\t$wickets_taken\t$eco\t($e extras)\t\n";
		}
	}
	else
	{
		if(($bowler{$_})%6 != 0)
		{
			my $eco=$runs_given/((floor(($bowler{$_})/6)).".".(($bowler{$_})%6));
			print $_,"\t\t\t",floor(($bowler{$_})/6),".",($bowler{$_})%6,"\t$maiden_overs\t$runs_given\t$wickets_taken\t$eco\n";
		}
		else
		{
			my $l=($bowler{$_})/6;
			my $eco=$runs_given/$l;
			print $_,"\t\t\t",($bowler{$_})/6,"\t$maiden_overs\t$runs_given\t$wickets_taken\t$eco\n";
		}
		
	}
	$maiden_overs=0;
	$wickets_taken=0;		
}
close FILE;
}#end scorecard;


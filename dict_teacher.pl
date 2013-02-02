#!/usr/bin/perl
### Written at 2009 by ewilded
### This is a simple perl dictionary manager written to raise up vocabulary learning effectiveness.
### The first goal was to easily manage list of words with their translations, that's however a function each dictionary offers.
### The main reason of writing this was the need of automation of carrying out the tests.
### Another feature is the sequence in which program chooses words for next tests; it sorts all words by the score from previous tests in ascending order.
### Then it picks up number (adjusted at run time) of words from the beginning of the list and performs a test. During the test it calculates score (answer to each question has to match to at least one synonym). After saving the current state (dictionary + scores) it upgrades all words that took part in the test with their new scores, so every time the test is made, words with lowest scores, therefore least learned words are picked up in the first place.
### There is also 'rand' type, which just picks up words randomly, without smart score sorting.

### Next idea: how about adjusting this (making another version?) with so called remembering/forgetting curve?

use Switch;
my $dictfile='en-pl.txt';
my @words=();
my @exam_words=();
my $exam_mode='smart'; ## or 'rand'
sub make_test 
{
	 @exam_words=();
	 my $count=$_[0];
	 $exam_mode=$_[1] if($_[1]=~/^(smart|rand)$/);
	 if($count<=0) 
	 {
	 	 print "Invalid number of words supplied!\n";
	 	 return;
	 } 
	 if($#words<$count) 
	 {	
  		print "To few words in dictionary to generate $count word test, assigning $count.\n";
  		$count=$#words;
	 }
 	if($exam_mode eq 'smart') 
 	{
		 	my $exam_words_cnt=0;
		 	for($curr_rate=0;$exam_words_cnt<$count;$curr_rate++)
 			{
 	 			foreach $w(@words) 
 	 			{ 
 	 	 			if($w=~/:$curr_rate\n*$/ and $exam_words_cnt<$count) 
 	 	 			{ 	 	 			 
 	 	 				push(@exam_words,$w);
 	 	 				$exam_words_cnt++;
 	 					print "$exam_word_cnt\t";
 	 	 			}     
	 			}
			}
 	}
 	else 
 	{
 		NEW_WORD: for($i=0;$i<$count;$i++) 
 		{
	 	 	$index=rand $#words;
		 	 for($j=0;$j<$i;$j++) ## remove duplicates
 			 {
 	  			redo NEW_WORD if($exam_words[$j] eq $words[$index]); ## already picked up
 	 		}
 	 		print "$i\t";
 	 		push(@exam_words,$words[$index]);
 		}
 	}
 	## Let's carry out the test.
 	my $correct_count=0;
 	my $rate=0;
 	foreach $wrd(@exam_words) 
 	{
 		 @q=split(':',$wrd,3);
 		 $cnt=@q;
 		 chomp($q[2]);
 		 $rate=$q[2];  
 		 $rate=0 if(!$rate);
   	 print "\n$q[0]?\t";
  		 $answer=<STDIN>;
  		 chomp($answer);
  		 $answer=~s/\,/ /g; ## Won z przecinkami
   	 $answer=~s/\s+/ /g;
  		 @ans_parts=split(' ',$answer);
  		 chomp($q[1]);
  		 $q[1]=~s/,/ /g;
  		 $q[1]=~s/\s+/ /g;
  	 	 @correct_parts=split(' ',$q[1]);
  	 	 print "[Poprawne odpowiedzi: @correct_parts]";
  	 	 $found=0;
  		 goto our_break if($answer eq '');
  		 $found=1;
		foreach $ans_part(@ans_parts) 
  	 	{
		   foreach $corr_part(@correct_parts) 
   		{
  				if($ans_part eq $corr_part) 
  				{
  		 			$found=1;
  		 			goto our_break;
  				}
  				$found=0;
		   }
  		}
  		our_break:
  		if(!$found) 
  		{
  			  print "[Wrong!]\n";
  			  break;
  		}
  		else
  		{
			print "[Correct!]\n";
			$correct_count++;
			$found=1;
  	 		$old_rate=$rate;
  	 		$rate++;
  	 		foreach $w(@words) 
  	 		{	
  	  			if($w eq $wrd) 
  	  			{
  	   			$w=undef;
  	   			$tmp=$wrd;
  	   			$tmp=~s/:$old_rate/:$rate/;
  	   			push(@words,$tmp);
  	   			break; 
  	  			}
  	 		} 
  		 	break;
  		}
	}
 	print "You have answered correctly on $correct_count from $count questions.\n";
}
sub load_dictionary
{
	 if($_[0]) 
	 {
	  	$dictfile=$_[0];
	  	chomp($dictfile);
	  	print "New dictfile: $dictfile\n";
	 }
	 open(FILE,"<$dictfile");
	 $c=0;
	 while(<FILE>) 
	 {
		  push(@words,$_);
		  $c++;
	 }
 	print "Read $c words from $dictfile.\n";
 	close(FILE);
}
sub save_dictionary
{
 	if($_[0]) 
 	{
 		 $dictfile=$_[0];
 		 print "New dictfile: $dictfile\n";
 	}	
 	if(!@words)
 	{
 		 print "Do you really want to save an empty wordlist into $dictfile? (Y/N)\n";
 		 $answer=<STDIN>;
 		 chomp($answer);
  		return if($answer=~/^n$/i); 
 	}
 	open(FILE,">$dictfile");
 	$c=0;
 	foreach $line(@words)
 	{
  		if($line) 
  		{
  			$line=~s/\n/:0\n/ if(!($line=~/:\d+$/)); 
  			print FILE $line;
  			$c++;
  		}
 	}
 	print "Written $c words into $dictfile\n";
 	close(FILE);
}
sub rand_line 
{
	 print $words[rand $#words];
}
sub match_line 
{
	 $string=$_[0];
	 print "Search results:\n";
	 foreach $line(@words) 
	 {
		  print $line if($line=~/$string/);
	 }
}
sub search_for_line 
{
 	$s=$_[0];
 	$debug=$_[1];
 	return if(!$s);
 	foreach $line(@words) 
 	{
 		 $tmp=$line;
 		 chomp($tmp);  
 		 $tmp=~s/:\d+$//; ### Wywalenie koncowego rejta
 		 if($tmp eq $s) 
 		 {
 		  print "Found!\n" if($debug);
 		  return 1;
 		 }
 	}   
 	print "Not found!\n" if($debug);
 	return 0;
}
sub add_line 
{
	 $l=$_[0];
	 if(!&search_for_line($l)) 
	 {
	 	push(@words,"$l:0\n");
	 	print "Added $l to dictionary!\n";
	 }
	 else 
	 {
  		print "Word already exists in dictonary.\n"; 
 	 }
}
sub del_line 
{
	$string=$_[0];
	foreach $line(@words) 
	{
	  $tmp=$line;
	  chomp($tmp);
	  $tmp=~s/:\d+$//;
	  $line=undef if($tmp eq $string);
 	}
 	return 0; 
}
sub list_words 
{
	 print "@words\n";
}
sub help_me 
{
 print "[commands: add,del,save,search,match,list,load,save,rand,make_test number,quit]\n";
}
### load,save,rand,search,match,add,del

while($a=<STDIN>) 
{
 $a=~/(\w+)\s+(.*)/;
 $command=$1;
 $params=$2;
 switch($command) 
 {
	  case 'quit' { &save_dictionary(); print "Goodbye!\n"; exit 0;  }; ## quit = save & exit
	  case 'load' { print "Loading $dictfile...\n"; &load_dictionary($params); };
	  case 'save' { print "Saving $dictfile...\n"; &save_dictionary($params); };
	  case 'rand' { &rand_line(); };
	  case 'match' { &match_line($params); };
	  case 'list'	{ print "[List of current known words]\n"; &list_words(); };
	  case 'search' { &search_for_line($params,1); };
	  case 'add' { &add_line($params); };
	  case 'del' { &del_line($params); };
	  case 'make_test' { &make_test($params); };
	  default : { &help_me; };
 }
}
#!/SOME_PATH/perl

# pdelevor 5-18-2014
# status: in progress
# Description: for DROP_FOLDER messages on error, retrieve log messages which contain matching attributes of DROP_FOLDER message 
# Purpose: Assist in debugging DROP_FOLDER error messages

sub init;
sub main;
use Cwd; 
push @INC, "/SOME_PATH/SERVER";
require 'DROP_FOLDER_to_logdir_map.pm';

use lib "usr/SOME_PATH/perl5";
use lib "usr/SOME_PATH/auto";
use lib "/SOME_PATH/perl5";
use lib "usr/SOME_PATH/x86_64-linux-thread-multi";
use lib "usr/SOME_PATH/auto";
use lib "/SOME_PATH/x86_64-linux-thread-multi";
use lib "/SOME_PATH/Simple";
use lib "/SOME_PATH/XML";
use lib "/SOME_PATH/SAX";
use lib "/SOME_PATH/PurePerl";
use lib "/SOME_PATH/Reader";
use lib "/SOME_PATH/Simple";
use lib "/SOME_PATH/Simple";
use lib "/SOME_PATH/XML";
use lib "/SOME_PATH/perl5";

use File::Spec::Functions;
use File::Copy;
use Cwd 'chdir';
use XML::Simple; # qw(:strict);
use Data::Dumper;
use Getopt::Long;
use IO::File;


my @DROP_FOLDER_errordirs;
my $error_dir = "";
my $DROP_FOLDER_name = "";
my $identifier = "";
my $factory_env = "gold";
my $DROP_FOLDER_root = "/SOME_PATH/DROP_FOLDER";
my $attribute_data;

#print caller(2)[0], "\n";
my $name;
$|++;

sub init{
        print 'In function: ', (caller(0))[3], "\n"; 
	&get_DROP_FOLDER_dirnames;

}

sub get_error_dirs{
	my $dirlist = shift;
	my @dirs_with_errors;
	foreach $dir ( @{$dirlist} ){
		my $error_files = $DROP_FOLDER_root . "/SOME_PATH*";
		my @matches = glob $error_files;	
		push @dirs_with_errors, $dir if $#matches > -1; 
	}
	return \@dirs_with_errors;

}

sub get_DROP_FOLDER_dirnames{
        print 'In function: ', (caller(0))[3], "\n"; 
	# root path
	opendir D, $DROP_FOLDER_root;

	my @dirs;
	foreach $dir ( readdir(D) ){
		#print "$dir\n";
		next if $dir eq "." || $dir eq "..";
		next if $dir =~ /SOME_PATH; 
		push @dirs, $dir if -d "${DROP_FOLDER_root}/$dir";
	}	
	print "Done getting DROP_FOLDER dirnames\n";

	# only get the list of DROP_FOLDERes with messages in the incoming/error dir
	my $dirs_with_error_msgs = get_error_dirs( \@dirs );

	#@DROP_FOLDER_errordirs = sort { $a cmp $b } @dirs;	
	@DROP_FOLDER_errordirs = sort { $a cmp $b } @{$dirs_with_error_msgs}; 
	return;
}

sub DROP_FOLDER_menu{
        print 'In function: ', (caller(0))[3], "\n"; 
	# present menu
	my $index=0;
	my $menu_index = 1; 
	my $menu_total = 0;
	foreach $dir ( @DROP_FOLDER_errordirs ){
		print "${menu_index}. $dir\n";
		$menu_index++;
	}
	$menu_total = $menu_index - 1;
	print "\n";
	print "Choice: ( 1 - $menu_total ): ";
	my $choice = <STDIN>;
	chomp $choice;
	print "Choice is $choice ( $DROP_FOLDER_errordirs[ ($choice - 1) ] )\n";
	print "Press enter to continue:";
	my $continue = <STDIN>;
	$DROP_FOLDER_name = $DROP_FOLDER_errordirs[ ($choice - 1) ] ;
	# return choice and set
	

}

sub get_array_data {

}

sub get_hash_data{
	my $key = shift;
	my $href = shift;
	my $attribute_selections;
	my $new_key;
	my $id = 0;
	$test_key = $key;
	print "key: $key ref: " . ref( $href ) . "\n";

	if ( ref( $href  ) eq 'HASH' ){
		my $h = $href;
		foreach $k ( keys %{$h} ){
		    get_hash_data( $k, $h->{$k} );
		}
	} elsif ( ref( $href  ) eq 'ARRAY' ){
		my $array = $href;
		foreach $item ( @{$array} ){
			if ( ref( $item ) eq 'HASH' ){
				foreach $k ( keys %{$item} ){
				    get_hash_data( $k, $item->{$k} );
				}
			}
		}	
	} elsif ( ref ( $href ) eq '' ) {
		# got it
		# create the hash entries and return it
		# check each entry, either add to hash, or unwind it if it's a ref 
		# add to return_data	
		
		print "Key: $key value: $href\n";
		$new_key = $key; 
		while ( defined $attribute_data->{$new_key} ){
			$new_key = $key . "_" . $id;
			$id++;
		}
		next if $key eq "type";
		print "Add key: $new_key, data: " . $href . "\n";
		if ( ( grep /SOME_PATH, values( %{$attribute_data} )) > 0  ){
			next;
		}
		$attribute_data->{$new_key} = $href;
	} else {
		print "Unknown ref type: " . ref( $href ) . "\n";
	}

	return 0; 
}

sub get_DROP_FOLDER_errorfiles{
        print 'In function: ', (caller(0))[3], "\n"; 
	if ( get_log_count() < 1 ) {
		print "No logfiles found for selected DROP_FOLDER\n";
		exit 0;
	}
	my @errorfiles;
	$error_dir = "/SOME_PATH/error";

	if ( -d $error_dir ){
		opendir D, $error_dir; 
		@errorfiles = readdir D;
	}
	
	# parse with XML
	my $data_hash;
	foreach $file ( @errorfiles ){

		my @info = stat( $error_dir . "/" . $file );
		# get mtime, add name & mtime to hash

		next if $file eq "." || $file eq "..";
		next if $file =~ /SOME_PATH; 
		print "Parsing with XML parser:/SOME_PATH/n";
		my $simple = XML::Simple->new();
		$config = $simple->XMLin("${error_dir}/$file");
		print Dumper($config); # this prints out parsed xml

		my @root_keys = keys %{$config};

		# traverse xml paths
		my $hash = $config;
		# check each key whether pointer to ref or not

		my $attribute_hash;

		foreach $key ( @root_keys ){
			get_hash_data( $key, $hash );
			# associate returned data with file
			#$attribute_hash->{$key} = $attribute_data; 
		}

		$data_hash{'filename'} = $file;
		$data_hash{'file_mtime'} = $info[9];
		$data_hash{'DROP_FOLDER_name'} = $DROP_FOLDER_name; 
		$data_hash{'attributes'} = $attribute_data;
		# determine search element; ORDER, catid, filepath, etc
		# then call get_errors_from_logs
		print "Get errors from logs\n";


		my @menu_keys =  keys %{$attribute_data};

		my $count = 1;
		foreach $key ( @menu_keys ){ 
			print $count++ . ". " . $attribute_data->{$key} . "\n";
		}

		print "Select values to use for searching: ";
		my $choices = <STDIN>;
		chomp $choices;
		foreach $choice ( split /SOME_PATH, $choices ){
			$choice--;
			$attribute_selections->{ $menu_keys[$choice] } =  $attribute_data->{ $menu_keys[$choice] };	
		}

		$data_hash{'attributes'} = $attribute_selections;
		get_errors_from_logs( \%data_hash );
		print "Press return to continue to next file/record: ";
		my $pause = <STDIN>;
		$attribute_data = undef;
		$attribute_selections = undef;
	        $data_hash = undef;
	}


}

sub get_log_count{

        print 'In function: ', (caller(0))[3], "\n"; 
	my $log_map = DROP_FOLDER_to_logdir_map();
	my $log_dir = $log_map->{$DROP_FOLDER_name};
	my @logfiles = glob($log_dir);

	# create list of logfiles containing search strings
	for ( @logfiles ) { 
		pop @logfiles, $_ if ! -f $_; 
	}

	return $#logfiles;
}

sub get_errors_from_logs{
	my @sorted_logs;
	my $search_hash = shift;
        print 'In function: ', (caller(0))[3], "\n"; 
	my $log_map = DROP_FOLDER_to_logdir_map();
	my $log_dir = $log_map->{$DROP_FOLDER_name};
	my @logfiles = glob($log_dir);

	# create list of logfiles containing search strings

	my %log_hash;
	for ( @logfiles ) { 
		pop @logfiles, $_ if ! -f $_; 
	}

	return if $#logfiles < 1;

	foreach $logfile ( @logfiles ){

		my @info = stat( $logfile );
		# get mtime, add name & mtime to hash
		$log_hash{$logfile} = $info[9];
		
	}
	# sort by mtime and save
	foreach $key ( sort { $log_hash{$b} <=> $log_hash{$a} } ( keys ( %log_hash ))) {
		push @sorted_logs, $key;
	}
	print "Done sorting logs\n";

	# for each sorted log, get messages containing attribute strings	

	my %search_hash = $search_hash->{'attributes'};
	
	foreach $log ( @sorted_logs ){

		# skip if out of mtime range of error message
		my $error_msg_mtime = $search_hash->{'file_mtime'};
		my $log_file_mtime = $log_hash{$log};

		my $diff;
		if (  $error_msg_mtime > $log_file_mtime ){ 
			$diff = $error_msg_mtime - $log_file_mtime;
		} else {

			$diff = $log_file_mtime - $error_msg_mtime;
		}

		if ( $diff > ( 60 * 60 * 24 ) ){
			print "Log $log is out of range: " . scalar localtime($error_msg_mtime) . " : " . scalar localtime( $log_file_mtime) . "\n";
		} else {
		
			print "Searching $log for matches\n";
			if ( ! open L, $log ){
				print "Unable to open $log: $!\n";
				next;
			}
			my $attrs = $search_hash->{'attributes'};
			my @search_strings = values( %{$attrs} );
			my @matches;
			while (<L>){
				foreach $s ( @search_strings ){ 
					print $_ if $_ =~ /SOME_PATH; 
				}
			}	
			print "Done searching $log\n";
		}
	}	

}

sub main {
        print 'In function: ', (caller(0))[3], "\n"; 
	&DROP_FOLDER_menu;
	&get_DROP_FOLDER_errorfiles;
	
}

&init;
&main;


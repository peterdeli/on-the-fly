#!/usr/bin/perl
#####################################
# Name: getThreadInfo.pl
# Author: pdelevor
# Descr: Map tomcat log entries to thread dumps
# Inputs: arg1: catalina.out arg2: (ex) services.log arg3: output file
# Version: 0.2
#####################################


use Getopt::Long;
use IO::File;
require "/home/user/bin/catalina_time_convert.pm";

# catalina.out
# open F, $ARGV[0];
# services.log ( or other )
# open G, $ARGV[1];
# open H, ">$ARGV[2]";

# search for thread dumps in catalina
# Start:
#2011-12-21 18:57:57
#Full thread dump Java HotSpot(TM) 64-Bit Server VM (20.1-b02 mixed mode):

# End:
#  object space 5242880K, 99% used [0x0000000600000000,0x000000073e9dbc90,0x0000000740000000)
#

my $search = "Full thread dump";
my $end = "object space";
my $prev_line = "";
my $lastline = "";
my %ThreadDumps;
my $first_time = "true";
my $start_collect = "false";
my @data;
my $current_ts;
my @tomcat_restarts;
my $restart_search = "Server startup in";

my $catalina_out;
my $logfile;
my $classSearchString;
my $outputFile;

sub help;

sub help{

	print <<EOF;
	Usage: $0 <options>
	Options:
	-catalina <catalina.out>
	-log <instance.log>
	-class <classname>
	-out <outputfile name>
EOF

}

help() && exit if $#ARGV < 3;

my $opt_result = GetOptions( 
	"catalina=s" => \$catalina_out,
	"log=s" => \$logfile,
	"class=s" => \$classSearchString,
	"out=s" => \$outputFile,
);

$catalina_out="catalina.out" if ! defined $catalina_out;
$logfile="services.log" if ! defined $logfile;
$class_name = "ID_SOME_WEB_COMPONENT" if ! defined $classSearchString;
$outputFile="out" if ! defined $outputFile;


exit if ( ! -e $catalina_out || ! -e $logfile );

open F, $catalina_out;
open G, $logfile;
open H, ">$outputFile";

print "Parsing $catalina_out\n";

while ( <F> ){
	chomp $_;
	if ( $_ =~ /$restart_search/ ){
		my $restart_time = catalina_time_convert( "startup", $prev_line );
		push @tomcat_restarts, $restart_time ;
	}
	if ( $_ =~ /$search/ ){ 
		$start_collect = "true";
		# 2. start new collect
		push @data, $prev_line;
		$current_ts = $prev_line;
	}

	if ( $_ eq "" && $prev_line =~ /$end/ ){ 
		# 1. save previous collect
		my @thread_dump_copy = ();
		for( @data ){
			push @thread_dump_copy, $_ . "\n";
		}
		$ThreadDumps{ $current_ts } = \@thread_dump_copy;
		$start_collect = "false";
		@data = ();
	}
	push @data, $_ if $start_collect eq "true";
	$prev_line=$_;
}
	

print "Done collecting thread dumps in $catalina_out;\n";

# get all lines containing "http-"
# egrep -i 'http-|RequestSOME_IDSOME_WEB_COMPONENTFilter' /tmp/out6 

my $thread_key = "threadDump";
my $id_key = "ids";
my $class_name = "SOME_IDSOME_WEB_COMPONENT";
my @http_ids;

print "Creating data structures\n";

while ( ($key, $data_ref) = each %ThreadDumps ){
	my %data;
	my @ids ;
	my $start_matching = "false";
	my $http_id;
	my @thread_info ;
	my @http_thread_dumps;
	my $save_thread_info = "false";

	# skip if doesn't contain the class type
	next if scalar(grep $class_name, @{$data_ref}) < 1;

	foreach $line ( @{$data_ref} ){

		if ( $line =~ m/"http-.*tid=.*/ && $start_matching eq "false" ){
			my @http_ids = grep /http-/, split /\s+/, $line; 
			$http_id = $http_ids[0];
			$http_id =~ s/"//g; 
			$start_matching = "false" if $http_id =~ m/[A-Z]/;
			# while we don't find another line matching tid=
			$start_matching = "true";
			push @thread_info, $line;
			my $result =  grep /${http_id}$/, @ids; 
			push @ids, $http_id if $result == 0; 
			next;
		}
		if ( $line eq "\n" && $start_matching eq "true" ){

			# end of collect
			$start_matching = "false";

			# save if contains string
			if  ( scalar(grep /$class_name/, @thread_info) < 1 ){
				# doesn't contain SOME_WEB_COMPONENT string, don't add to hash
				# clear array and go on
				@thread_info = ();
				next;
			}

			push @http_ids, $http_id if ( scalar ( grep /^${http_id}$/, @http_ids )) < 1;

			my @thread_dump_copy = ();
			for( @thread_info ){
				push @thread_dump_copy, $_; 
			}

			$data{$http_id} = \@thread_dump_copy;
			@thread_info = ();


		}
		push @thread_info, $line if $start_matching eq "true";
		$prev_line = $line;
	}

	# re-associate id array with thread dump key
	$ThreadDumps{ $key } = \%data;
}

print "Id's collected from $catalina_out\n";
# We now have a collection of thread id's associated with a thread dump
# ThreadDumps{ <timestamp> } -> hash{ http id's } -> thread dump info 

my %matches;
$|=1;
my $ctr = 0;
my $mod = 5000; 
my $lctr = 0;
print "Parsing $logfile\n";
print scalar localtime, "\n";
my $prev_id;

# Expensive loop depending on size of <G>


while ( <G> ){
	my $line = $_;
	foreach $id ( @http_ids ){

		if ( $line =~ m/.*\[$id\].*/ ){
			$matches{$id} = $line;
		} 

	}
	$prev_id = $id;
	$ctr++;
	if ( $ctr > $mod && ( $ctr % $mod ) == 0 ){
		print "$ctr lines parsed ..\n"; 
		$mod += 5000;
	}
}

print "\nDone\n";
print "$ctr lines parsed\n";
print scalar localtime, "\n";
close G;

# get http_ids from ThreadDumps hash, change key/value(@) ref of each hash value to be hash with thread dump/log entries

#  for each collection of http_ids, 
#  1. get thread dump date 
#  2. get tomcat restarts
#  @tomcat_restarts

# establish restart ranges for @tomcat_restarts
# for each tomcat restart,
#     if thread dump date is before restart, use only log entries before restart
#     if thread dump date is after restart, use only log entries after restart

# tomcat restarts
# 08:00
# 10:00
# 13:00

# thread dumps
# 09:00
# 11:00
# 14:00

# log entries #1
# after 09:00, before first restart after 09:00

# log entries #2
# after 11:00, before first restart after 11:00 

# key = datestamp, ref = hash of key/array values
open INFO, ">$outputFile";
while ( ($key, $data_ref) = each %ThreadDumps ){


	# key = thread dump date
	# get earliest restart after thread dump date
	# 1. convert thread dump date to milliseconds
	# 2. for each log entry
	#	1. convert date to milliseconds
	#	2. add to hash if 
	#		date value > thread value &&  date value < restart value
	my @matches;
	my @sorted_matches;
	my $lowest_tomcat_restart_stamp;
	my $thread_dump_ms = catalina_time_convert( "thread_dump", $key );
	for ( @tomcat_restarts ){
		if ( $_ > $thread_dump_ms ){ 
			print INFO "Match: tomcat restart > thread dump  $_  > $thread_dump_ms  ( " . scalar localtime( $_ ) . " >  " . $key . " )\n"; 
			print "Match: tomcat restart > thread dump  $_  > $thread_dump_ms  ( " . scalar localtime( $_ ) . " >  " . $key . " )\n"; 
			push @matches, $_; 
		}
	}
	if ( $#matches > 0 ){
		@sorted_matches = sort{ $a <=> $b } @matches;
	}
	# lowest tomcat restart timestamp that is greater than the thread dump date
	$lowest_tomcat_restart_stamp = $sorted_matches[0];	

	my %data;
	foreach $id ( keys %{$data_ref} ){
		# key = http_id, value = thread dump array
		# array
		next if ( grep /$id/, keys %matches ) < 1;

		my $thread_dump = $data_ref->{$id};
		my $log_entries = $matches{$id};
		my %data_hash;



		if ( $#sorted_matches > -1 ){

			my ( $log_date, @tmp ) = split( /,/, $log_entries );
			my $log_stamp = catalina_time_convert( "thread_dump", $log_date );


			if ( $log_stamp <  $lowest_tomcat_restart_stamp ){
				print "Adding $log_entries to data_hash\n";
				$data_hash{ $logfile } = $log_entries;
				# thread dump
				$data_hash{ $catalina_out } = $thread_dump;
				# re-associate
				$data{ $id } =  \%data_hash;
			} else {
				print "Skipping log entry: $log_entries",
				"Thread dump date: $key ( $thread_dump_ms )\n",
				"Log entry date: $log_date ( $log_stamp )\n",
				"Earliest tomcat restart date, after thread dump date: ", scalar localtime($lowest_tomcat_restart_stamp), " ( $lowest_tomcat_restart_stamp )\n";
			}

		} else {
			# log matches
			print "Adding $log_entries to data_hash\n";
			$data_hash{ $logfile } = $log_entries;
			# thread dump
			$data_hash{ $catalina_out } = $thread_dump;
			# re-associate
			$data{ $id } =  \%data_hash;
		}


	}
	$ThreadDumps{ $key } =  \%data;
}
close INFO;

print "Done\n";

# Display



while ( ( $key1, $val1 ) = each %ThreadDumps ){

	# $ThreadDumps{ $key } =  \%data;

	# key = timestamp of thread dump
	# Ex. 2011-12-21 18:57:57


	print "Thread dump date: $key1\n";
	print H "Thread dump date: $key1\n\n";
	print H "-" x 50, "\n";
	print "ids:\n";

	# each key here is the http-id linking the thread dump and log request 
	# Ex. "http-8082-20"

	while ( ( $key2, $val2 )  = each %{$val1} ){
		# id -> hash of thread dump/log entry
		print "$key2 ";
		print H "id: $key2\n";
		my $thread_ref;
		my $log_ref;

		# Each key here is the file
		# catalina_out = catalina.out, logfile = <instance>.log

		while ( ( $key3, $val3 )  = each %{$val2} ){
			if ( $key3 eq $catalina_out ){
				$thread_ref = $val3;
			}
			if ( $key3 eq $logfile ){
				$log_ref = $val3;
			}
		}

		# Write the log entry, then thread dump

		print H "Log entry from $logfile for id $key2:\n\n";
		print H $log_ref, "\n";
		#print H "-" x 50, "\n";
		print H "Thread dump from $catalina_out for id $key2 ($key1):\n\n";
		print H @{$thread_ref};
		#print H "-" x 50, "\n";
		print H "\n\n";
		print H "-" x 50, "\n\n";
		#print "Press return for next record\n";
		#my $this = <STDIN>;
	}
	print "\n\n";
}
close H;


#my ( $date_time_type, $req_id, $dummy1, $http_id, $dummy2, $class_name, $host_port_httptype, $size_mimetype, $svc_name ) =
#split /[\[\]]/, $x 

# match ids to requests in logs
# 2012-01-04 00:20:23,385 INFO  [HEX_THREAD_ID] [http-8082-1] [util.RequestSOME_IDSOME_WEB_COMPONENTFilter] - .com:8082 POST [9008 bytes application/x-java-serialized-object] /services/http/Catalog

#2012-01-05 23:01:31,212 ERROR [HEX_THREAD_ID] [http-8082--88] [util.SOME_COORD_COMPONENTUtils] - java.lang.Exception: Bounding box coordinate is not parsable:616564.1504617966

# date time type [request_id] [http-id] [class-name] - host request-type [size mime-type] directory
# split on [ or ]
# @z = split /[\[\]]/, $x
#   DB<9> x @z
# 0  '2012-01-04 00:20:23,385 INFO  '
# 1  'SOME_HEX_ID'
# 2  ' '
# 3  'http-8082-1'
# 4  ' '
# 5  'util.RequestSOME_IDSOME_WEB_COMPONENTFilter'
# 6  ' - SOME_SERVER
:8082 POST '
# 7  '9008 bytes application/x-java-serialized-object'
# 8  ' /services/http/Catalog'



# "http-8082-80" daemon prio=10 tid=0x000000005422d000 nid=0x55a6 waiting for monitor entry [0x0000000048cea000]
#    java.lang.Thread.State: BLOCKED (on object monitor)
#         at org.apache.log4j.Category.callAppenders(Category.java:204)
#         - waiting to lock <0x00000006000c98e0> (a org.apache.log4j.Logger)
#         at org.apache.log4j.Category.forcedLog(Category.java:391)
#         at org.apache.log4j.Category.info(Category.java:666)
#         at com.SOME_DOMIAN.util.RequestSOME_IDSOME_WEB_COMPONENTFilter.SOME_METHOD(RequestSOME_IDSOME_WEB_COMPONENTFilter.java:92)
#         at com.SOME_DOMIAN.util.RequestSOME_IDSOME_WEB_COMPONENTFilter.SOME_METHOD(RequestSOME_IDSOME_WEB_COMPONENTFilter.java:205)
#         at java.lang.Thread.run(Thread.java:662)
# 
# 

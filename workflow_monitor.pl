#!SOME_PATH/perl

# autoflush
$|++;

sub init;
sub get_errorfiles;
sub parse_files;
sub move_files;

use lib "SOME_PATH/x86_64-linux-thread-multi";
use lib "SOME_PATH/x86_64-linux-thread-multi";
use lib "SOME_PATH/x86_64-linux-thread-multi";
use lib "SOME_PATH5.8.8";
use lib "SOME_PATH5.8.8";
use lib "SOME_PATH5.8.8";
use lib "SOME_PATH/site_perl";
use lib "SOME_PATH/vendor_perl";
use lib "SOME_PATH/my_lib";

require "catalina_time_convert.pm";
require "parse_OGC_log.pm"; # $file, $data_ref

use File::Spec::Functions;
use File::Copy;
use Cwd 'chdir';
use XML::Simple; # qw(:strict);
use Data::Dumper;
use Getopt::Long;
use IO::File;

my @stack_strings;
my $date_str;
my $targetdir;
my $logdir;
my $log_regex='jboss-OGCworkflow-SERVER0[12].DOMAIN.com-1.log';
my $errordir;
my $opt_result;


my $greplen;
my $requestMode_key;
my $ORDER_id_key;
my $ORDER_line_key;
my $catid_key;

my $ORDER_content_key;
my $ORDER_length;
my $lineno_length;
my $valid_ORDER;
my $search_str1;
my $search_str2;
my $ORDER ;

sub banner {
my $title=" Workflow Monitor";
print<<EOF;

$title

TARGET FOLDER: $targetdir
 ERROR FOLDER: $errordir
 ATTIC FOLDER: $atticdir
   LOG FOLDER: $logdir

EOF

}

sub init{

    $date_str=`date '+%Y%m'`;
    chomp $date_str;

    $atticdir="SOME_PATH/dupProductRequest${date_str}";
    if ( ! -d $atticdir ){
        mkdir -p $atticdir
    }
    $logdir="SOME_PATHWorkflow";
    $errordir="SOME_PATH/error";
    $targetdir="SOME_PATH/target";
    

    $opt_result = GetOptions(
        "target=s" => \$targetdir,
        "log=s" => \$logdir,
        "error=s" => \$errordir
    );
    chdir $errordir;
    push @stack_strings,
    ".DB_KEYWORD",
    ".SOME_WINDOW_METRIC",
    "com.DOMAIN.Workflow.util.ExceptionLog.SOMEException",
    "com.DOMAIN.Workflow.util.ExceptionLog.SOMEException",
    "com.DOMAIN.Workflow.PROCESSORServices.SOME_Service",
    "com.DOMAIN.Workflow.SOME_Request",
    "com.DOMAIN.Workflow.SOME_Request",
    "com.DOMAIN.Workflow.DB.processRequest",
    "com.DOMAIN.Workflow.DB.onMessage";

    $greplen=20;
    $request_key="requestMode";
    $ORDER_id_key="ORDER";
    $ORDER_line_key="lineNumber";
    $id_key="SOMEID";

    $ORDER_content_key="content";
    $ORDER_length=12; # ORDER is substr(0-8)
    $lineno_length=2; # substr(10-12)
    $valid_ORDER="false";
    $search_str1="Service ProductRequest error processing message";
    $search_str2=quotemeta("WorkflowException: error in SOME_SERVICE (Cause: ORA-00001: unique constraint (.SOME_ID");
    $ORDER = "";
}


sub get_errorfiles{

    my $dir = shift;
    opendir DIR, $dir;
    my $file_list = shift;

    print "Searching for error files\n",
          "Error folder: $dirSOME_PATH/n";

    while ( my $file = readdir DIR ){
         #$file = catfile( $logdir, $file ); 
      next if $file =~ SOME_PATH;
      push @{$file_list}, $file; 
    }
    closedir DIR;
    if ( $#${file_list} < 0 ){
      print "No files to process\n";
      exit;
    } else {
      print "Found ", ( $#${file_list} + 1 ), " error files in:SOME_PATH/n";
    }

}
sub get_error_data{

    my $href = shift;
    my $return_data = shift;
    my $data = $href->{data};
    my $ORDER = $href->{ORDER};
    my $lineno = $href->{line};
    my $ORDER_key = $href->{ORDER_label};
    my $lineno_key = $href->{lineno_label};
    my $s1 = $href->{search1};
    my $s2 = $href->{search2}; 

    #loop over data, get msg array
    #entry{ date } = $ldate;
    #entry{ time } = $ltime;
    #entry{ type } = $ltype;
    #entry{ class } = $lclass;
    #entry{ thread } = $lthread;
    #entry{ msg } = \@lmsg;


    foreach $data_item ( @{$data} ){
        my $ORDER_test="false";
        my $lineno_test="false";
        my $search1_test="false";
        my $search2_test="false";
        my $validation = "true";

        my $msg = $data_item->{msg};
        # ORDER, line#, search1/2    
        foreach $str ( grep SOME_PATH, @{$msg} ){
            if ( $str =~ SOME_PATH ){
                $ORDER_test = "true";
                last;
            }
        }
        foreach $str ( grep SOME_PATH, @{$msg} ){
            if ( $str =~ SOME_PATH ){
                $lineno_test = "true";
                last;
            }
        }
        foreach $str ( grep SOME_PATH, @{$msg} ){
            if ( $str =~ SOME_PATH ){
                $search1_test = "true";
                last;
            }
        }
        foreach $str ( grep SOME_PATH, @{$msg} ){
            if ( $str =~ SOME_PATH ){
                $search2_test = "true";
                last;
            }
        }
        foreach $test ( $ORDER_test, $lineno_test, $search1_test, $search2_test, ){
            if ($test eq "false"){
                $validation = "false"; 
                last; 
            }
        }

        # validate stack trace records
        my $trace_test = "false";
        foreach $trace ( @stack_strings ){
            if ( (grep SOME_PATH, @{$msg}) > 0 ){
                $trace_test = "true"; 
                #print "Matched\n";
                next;
            } else {
                $trace_test = "false"; 
                #print "No match\n";
                last;
            }
        }
                #@stack_strings = grep { $_ ne $stack_line } @stack_strings;

        if ( $validation eq "true" && $trace_test eq "true" ){
            # add to collection
            push @{$return_data}, $data_item;
        }
    }

}
sub parse_files {

    my $file_ref = shift;

    foreach $file ( @${file_ref} ){
        print "=" x 50;
        print "SOME_PATH/n";
        print "Parsing with XML parser:\n",
                  "File: $file\n";
                  "Directory: $errordir\n";
        my $simple = XML::Simple->new();
        my $config = $simple->XMLin($file);
        print Dumper($config); # this prints out parsed xml

        my @top_keys = keys %{$config};
        my @ORDER_results = $config->{'tns:ExternalReferenceId'};
        next && print "No ORDER found in $file" if $#ORDER_results < 0;

          # return array of hashes
        foreach $href ( @ORDER_results ){
            print "Validating ORDER in $file..\n";
            # identifiertype -> 'ORDER'
            # content -> ORDER
            if ( $href->{identifiertype} eq $ORDER_id_key ){
              # validate ORDER
              $ORDER=$href->{content};
              if ( length( $ORDER ) == $ORDER_length ){
            print "Found ORDER: $ORDER\n";
            $valid_ORDER="true";
              } else {
            print "ORDER $ORDER invalid\n";
            next;
              }
            }
          }

        ############### get log files  ######################


           if ( $valid_ORDER eq "true" ){

              my @log_files;
              # get list of log files 
              opendir LOGDIR, $logdir;
              while ( my $file = readdir LOGDIR ){
                next if $file =~ SOME_PATH;
                #if ( $file =~ mSOME_PATH )
                if ( $file =~ mSOME_PATH ){
                  $file = catfile( $logdir, $file ); 
                  push @log_files, $file ;
                }
                # match str1 and str2 and ORDER in logfile
              }
              closedir LOGDIR;

        ############### parse log files  ######################

              my $no_match="false";
              my %attic_moves;
              my %target_moves;
              $attic_moves{$file}=0;
              $target_moves{$file}=0;
              foreach $log_file( @log_files ){
                my @data;
                my %props;
                parse_OGC_log( $log_file, \@data, $ORDER );
                # get msg arrays that contain ORDER and error strings
                # each array element is a hash
                $props{data} = \@data;
                $props{ORDER} = $ORDER; 
                $props{ORDER_label} = $ORDER_id_key; 
                $props{lineno_label} = $ORDER_line_key;
                $props{line} = $lineno_id; 
                $props{search1} = $search_str1;
                $props{search2} = $search_str2;
                my @error_data;
                get_error_data( SOME_PATH/@error_data ); 
                my $error_count = ( $#error_data + 1 );

                print "Checking matches for ORDER: $ORDER\n",
                "Log file: $log_file\n";

                if ( $error_count > 0 ){
                       $attic_moves{$file}+=1; 
                       print ">>> $error_count error entries matched. <<<SOME_PATH/n";
                } else {
                    $target_moves{$file}+=1;
                    print ">>> $error_count error entries matched. <<<SOME_PATH/n";
                    print "Check log entries for errors and determine whether to contact SUPPOrt or re-submit to target folder\n";
                }
                print "View ", ( $#data + 1 ), " log entrySOME_PATH/n]";
                flush STDOUT;
                my $ans = <STDIN>;
                chomp $ans;
                if ( $ans eq "y" ){ 
                    my $index = 1;
                    my $count = ( $#data + 1 );
        
                    foreach $entry ( @data ){    
                        print "====================SOME_PATH/n";
                        # log entry is hash->{msg}
                        my @keys = keys %{$entry};
                        #entry{ date } = $ldate;
                        #entry{ time } = $ltime;
                        #entry{ type } = $ltype;
                        #entry{ class } = $lclass;
                        #entry{ thread } = $lthread;
                        #entry{ msg } = \@lmsg;
                        print "Date: $entry->{date}\n";
                        print "Time: $entry->{time}\n";
                        print "Type: $entry->{type}\n";
                        print "Class: $entry->{class}\n";
                        print "Thread: $entry->{thread}\n";
                        my $msg = $entry->{msg};
                        print "Log data:\n";
                        print join "\n", @{$msg};
                    
                        if ( $index < $count ){
                            print "Press return for next entry ..";
                            flush STDOUT;
                            my $ans = <STDIN>;
                        }
                        $index++;
                    }
                    print "====================SOME_PATH/n";
                }

            
            } # end foreach $log_file
            print "$attic_moves{$file} log files match errors\n", 
                  "ACTION: Move file\n",
                  "SRC DIR: $errordir\n",
                  "SRC FILE: $file\n",
                  "to:\n",
                  "DEST DIR: $atticdir\n" if $attic_moves{$file} > 0;
                
            print "$target_moves{$file} log files match errors\n",
                  "ACTION: Move file\n",
                  "SRC DIR: $errordir\n",
                  "SRC FILE: $file\n",
                  "to:\n",
                  "DEST DIR: $targetdir\n" if $target_moves{$file} > 0;
            print "Completed checking log files\n";


           } else {
              print "No valid ORDER found in $file\n";
           }
           print "Press return to check the next error file\n";
           my $next = <STDIN>;
    } # end foreach $file

}

############## MAIN ##################

sub main{

init;
banner;
my @error_files;
get_errorfiles( $errordir, \@error_files );
parse_files( \@error_files );
#move_files;

}

&main;


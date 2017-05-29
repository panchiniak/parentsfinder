package Text::ParentsFinder;

use File::Path qw( make_path );
use Cwd 'abs_path';
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);

use warnings;
use strict;
use utf8;
use 5.010;

#perl -f ParentFinder.pm --categories [FILE_NAME] --orphans [FILE_NAME] --verbose --no-file

my $current_path = abs_path(__FILE__);
my $current_file_name = __FILE__;

my $base_file_name;
my $data_file_name;
my $project_name;

my $verbose_mode;
my $no_file;

GetOptions(
    'categories|c=s' => \$base_file_name,
    'orphans|o=s' => \$data_file_name,
    'project-name|p=s' => \$project_name,
    'verbose|v' => \$verbose_mode,
    'no-file|n' => \$no_file,
) or die "Usage: $0 --categories [FILE_NAME] --orphans [FILE_NAME] --project-name [PROJECT_NAME] --verbose --no-file\n";

for ($current_path){
  s/$current_file_name/projects\/$project_name/;
}

#print $current_path . "\n";

open (FH_B, "< $current_path/$base_file_name") or die "Can't open for read: $!";
my @base_lines = <FH_B>;
my $base_file_count = $.;
open (FH_T, "< $current_path/$data_file_name") or die "Can't open for read: $!";
my @data_lines = <FH_T>;
my $data_file_count = $.;

my $timestamp = localtime(time);
for ($timestamp){
    s/^.+ (1)//;
    s/:/-/g;
    s/ /-/g;
}

my $files_directory = "$current_path/files";

if ( !-d $files_directory ) {
    make_path $files_directory or die "Failed to create path: $files_directory";
}

open (our $outfile, "> $current_path/files/$project_name-$timestamp.csv") or die "Can't open for write: $!";

my $line_index = 0;
foreach my $base_line (@base_lines){
    my $base_line_father_source = $base_line;
    my $base_line_child_source = $base_line;
    for ($base_line_father_source){
        s/,.+//;
    }
    for ($base_line_child_source){
        s/^(.*?),//;
        s/"//g;
    }
    my $data_line_index = 1;
    foreach my $data_line (@data_lines){
        for($data_line){
            s/^,//;
            s/"//g;
        }
        if ($data_line eq $base_line_child_source){

            for($base_line_father_source){
                s/\n//;
            }
            for ($data_line){
                s/\n//;
            }
            if ($verbose_mode){
                print "$data_line_index,$base_line_father_source,\"$data_line\"\n";
            }

            if (!$no_file){
               print $outfile "$data_line_index,$base_line_father_source,\"$data_line\"\n";
            }


        }
        $data_line_index++;
    }
  $line_index++;
}

__END__

=head1 Parents Finder
Generates CSV attributing a parent for each child from data and table of categories files.

=head1 SYNOPSIS
Usage perl -f ParentsFinder.pm --categories [FILE_NAME] --orphans [FILE_NAME] --verbose --no-file
Options:
  categories            csv file containing pairs: <parent>,<child>
  orphans               simple list of orphans, one per line
  verbose               prints output to STDOUT
  no-file               prints output only for STDOU
=head1 DESCRIPTION
ParentFinder iterates orphaned children from data file (orphans) for each parent according to mapping given on
categories.
CSV file generated contains pairs: <reference line number>,<data line number>,<parent>,<child>.
=head1 AUTHOR
Rodrigo Panchiniak Fernandes
=head1 CAVEAT
Orphans and mapped children need to match each other.
=cut

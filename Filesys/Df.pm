package Filesys::Df;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require 5.003;
use Filesys::Statvfs;
use Carp;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(df);
$VERSION = '0.43';

sub df {
my ($dir, $block_size)=@_;
my ($per, $user_used, $user_blocks);
my ($fper, $user_fused, $user_files);
my $h_ref={};
my $result=0;

	($dir) ||
		(croak "Usage: df\(\$dir\) or df\(\$dir\, \$block_size)");

	(-d $dir) ||
		(return());

	$block_size=1024 unless($block_size); 

        my ($bsize, $frsize, $blocks, $bfree,
        $bavail, $files, $ffree, $favail)=statvfs($dir);

	return if(! defined($blocks));

	####Return info in 1k blocks or specified size
        if($block_size > $frsize) {
                $result=$block_size/$frsize;
                $blocks=$blocks/$result;
                $bfree=$bfree/$result;
                $bavail=$bavail/$result;
        }

        elsif($block_size < $frsize) {
                $result=$frsize/$block_size;
                $blocks=$blocks*$result;
                $bfree=$bfree*$result;
                $bavail=$bavail*$result;
        }

        my $used=$blocks-$bfree;
	####There is a reserved amount for the su
        if($bfree != $bavail) {
                my $diff=$bfree-$bavail;
                $user_blocks=$blocks-$diff;
                $user_used=$user_blocks-$bavail;
		if($bavail >= 0) {
                	$per=$user_used/$user_blocks;
		}

		####over 100%
		else {
			my $tmp_bavail=$bavail;
			$tmp_bavail*=-1; 
                	$per=$tmp_bavail/$user_blocks;
		}
        }
	
	####su and user amount are the same
        else {
                $per=$used/$blocks;
		$user_blocks=$blocks;
		$user_used=$used;
        }

	#### round 
        $per*=100;
        $per+=.5;

	#### over 100%
	$per+=100 if($bfree != $bavail && $bavail < 0);

	#### Inodes
        my $fused=$files-$ffree;
	if($files >= 0) {	
	 	####There is a reserved amount for the su
        	if($ffree != $favail) {
                	my $diff=$ffree-$favail;
                	$user_files=$files-$diff;
                	$user_fused=$user_files-$favail;
			if($favail >= 0) {
               			$fper=$user_fused/$user_files;
			}

			## Over 100%
			else {
                		my $tmp_favail=$favail;
                		$tmp_favail*=-1;
                		$fper=$tmp_favail/$user_files;
			}
		}

        	####su and user amount are the same
		else {
                	$fper=$fused/$files;
			$user_files=$files;
			$user_fused=$fused;
		}

		#### round 
        	$fper*=100;
        	$fper+=.5;

		#### over 100%
		$fper+=100 if($ffree != $favail && $favail < 0);
        }

	####Probably an NFS mount no inode info
	else {
		$fper=-1;
		$fused=-1;
		$user_fused=-1;
		$user_files=-1;
	}

        ($h_ref->{PER})=($per=~/(\d+)\./);
        $h_ref->{SU_BLOCKS}=$blocks;
        $h_ref->{SU_BAVAIL}=$bfree;
        $h_ref->{SU_USED}=$used;
        $h_ref->{USER_BLOCKS}=$user_blocks;
        $h_ref->{USER_USED}=$user_used;
        $h_ref->{USER_BAVAIL}=$bavail;
        $h_ref->{BLOCKS}=$blocks;
        $h_ref->{BAVAIL}=$bavail;
        $h_ref->{BFREE}=$bfree;
        $h_ref->{USED}=$used;

        ($h_ref->{FPER})=($fper=~/(\d+)\./);
        $h_ref->{SU_FILES}=$files;
        $h_ref->{SU_FAVAIL}=$ffree;
        $h_ref->{SU_FUSED}=$fused;
        $h_ref->{USER_FILES}=$user_files;
        $h_ref->{USER_FAVAIL}=$favail;
        $h_ref->{USER_FUSED}=$user_fused;
        $h_ref->{FILES}=$files;
        $h_ref->{FFREE}=$ffree;
        $h_ref->{FAVAIL}=$favail;
        $h_ref->{FUSED}=$fused;
        return($h_ref);
}

1;

__END__

=head1 NAME

Filesys::Df - Perl extension for obtaining file system stats.

=head1 SYNOPSIS

  use Filesys::Df;
  $ref=df('/tmp');
  print"Percent Full: $ref->{PER}\n";
  print"Superuser Blocks: $ref->{BLOCKS}\n";
  print"Superuser Blocks Used: $ref->{USED}\n";
  print"Superuser Blocks Available: $ref->{BFREE}\n";
  print"User Blocks: $ref->{USER_BLOCKS}\n";
  print"User Blocks Used: $ref->{USER_USED}\n";
  print"User Blocks Available: $ref->{BAVAIL}\n";


=head1 DESCRIPTION

This module will produce information on a file system for both the normal 
disk space and the amount reserved for the superuser.
It contains one function df(), which takes a directory
as the first argument and an optional second argument
which will let you specify the block size for the output.
Note that the inode values are not changed by the block size
argument. The return value is a refrence to a hash. 

The keys of intrest in this hash are:

PER
Percent used. This is based on what the non-superuser will have available.

SU_BLOCKS or BLOCKS
Total number of blocks on the file system.

USER_BLOCKS 
Total number of blocks for non-superuser.

SU_USED or USED 
Total number of used blocks by superuser.

USER_USED
Total number of used blocks by non-superuser.

SU_BAVAIL or BFREE
Total number of avaliable blocks to superuser.

USER_BAVAIL or BAVAIL
Total number of avaliable blocks to non-superuser.

FPER
Percent of inodes available to the non-superuser.

SU_FILES or FILES
Total inodes in file system.

USER_FILES
Total inodes for the non-superuser.

SU_FUSED or FUSED
Total number of inodes used.

USER_FUSED
Total number of inodes used by non-superuser.

SU_FAVAIL or FFREE
Inodes available in file system.

USER_FAVAIL or FAVAIL
Inodes available to non-superuser.

Most 'df' applications will print out the SU_BLOCKS or USER_BLOCKS,
USER_BAVAIL, SU_USED, and the percent full. So you will probably end
up using these values the most.

If the file system does not contain a diffrential in space for
the superuser then the USER_ keys will contain the same
values as the SU_ keys.

If there was an error df() will return undef 
and $! will have been set.

Requirements:
Your system must contain statvfs(). 
You must be running perl.5003 or higher.

Note:
The way the percent full is measured is based on what the
HP-UX application 'bdf' returns.  The 'bdf' application 
seems to round a bit different than 'df' does but I like
'bdf' so that is what I based the percentages on.

=head1 AUTHOR

Ian Guthrie
IGuthrie@aol.com

=head1 SEE ALSO

statvfs(2), df(1M), bdf(1M)

perl(1).

=cut

package Filesys::Df;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require 5.003;
use Filesys::Statvfs;
use Carp;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(df);
$VERSION = '0.30';

sub df {
my $dir=shift;
my $block_size=shift;
my $result=0;
my %fs_struct=();
my ($per, $user_used, $user_blocks);

	($dir) ||
		(croak "Usage: df\(\$dir\) or df\(\$dir\, \$block_size)");

	(-d $dir) ||
		(return());

	$block_size=1024 unless($block_size); 

        my ($bsize, $frsize, $blocks, $bfree,
        $bavail, $files, $ffree, $favail)=statvfs($dir);

	return if(! defined($blocks));

	####Return info in 1k blocks
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
	####

        my $used=$blocks-$bfree;
	####There is a reserved amount for the su
        if($bfree != $bavail && $bavail >= 0) {
                my $diff=$bfree-$bavail;
                $user_blocks=$blocks-$diff;
                $user_used=$user_blocks-$bavail;
                $per=$user_used/$user_blocks;
        }
	####
	
	####over 100%
	elsif($bfree != $bavail && $bavail < 0) {
        	my $diff=$bfree-$bavail;
		$user_blocks=$blocks-$diff;
                $user_used=$user_blocks-$bavail;
		my $tmp_bavail=$bavail;
		$tmp_bavail*=-1; 
                $per=$tmp_bavail/$user_blocks;
	}
	####

	####su and user amount are the same
        else {
                $per=$used/$blocks;
        }
	####
	my $su_bavail=$blocks-$used;

	#### round 
        $per*=100;
        $per+=.5;
	$per+=100 if($bfree != $bavail && $bavail < 0);
	####

        ($fs_struct{PER})=split(/\./,$per);
        $fs_struct{SU_BLOCKS}=$blocks;
        $fs_struct{SU_USED}=$used;
        $fs_struct{SU_BAVAIL}=$su_bavail;
        $fs_struct{BLOCKS}=$blocks;
        $fs_struct{USED}=$used;
        $fs_struct{BAVAIL}=$bavail;
        $fs_struct{USER_USED}=$user_used;
        $fs_struct{USER_BLOCKS}=$user_blocks;
        $fs_struct{USER_BAVAIL}=$bavail;
        return(\%fs_struct);
}

1;

__END__

=head1 NAME

Filesys::Df - Perl extension for obtaining file system stats.

=head1 SYNOPSIS

  use Filesys::Df;
  $ref=df('/tmp');
  print"Percent Full: $ref->{PER}\n";
  print"Super User Blocks: $ref->{SU_BLOCKS}\n";
  print"Super User Blocks Used: $ref->{SU_USED}\n";
  print"Super User Blocks Available: $ref->{SU_BAVAIL}\n";
  print"User Blocks: $ref->{USER_BLOCKS}\n";
  print"User Blocks Used: $ref->{USER_USED}\n";
  print"User Blocks Available: $ref->{USER_BAVAIL}\n";


=head1 DESCRIPTION

This module will produce info on a filesystem for both the normal 
disk space and the amount reserved for the super-user.
It contains one function df(), which takes a directory
as the first argument and an optional second argument
which will let you specify the block size for the output. 
The return value is a refrence to a hash. 

The keys of intrest in this hash are:

PER         Percent used. This is based on what the normal user will have available.

SU_BLOCKS   Total number of blocks (Available to super-user).

SU_USED     Total number of used blocks (Available to super-user).

SU_BAVAIL   Total number of avaliable blocks (Available to super-user).

USED_BLOCKS Total number of blocks (Available non super-user).

USER_USED   Total number of used blocks (Available to non super-user).

USER_BAVAIL Total number of avaliable blocks (Available to non super-user).

Most df applications will print out the SU_BLOCKS or USER_BLOCKS,
USER_BAVAIL, SU_USED, and the percent full. So you will probably end
up using these values the most.

If the file system does not contain a diffrential in space for
the super-user then you can use the non user specific keys:
BLOCKS, USED, and BAVAIL. Also the USER_ keys will contain the same
values as the SU_ keys.

If there was an error df() will return undef.

Requirements:
Your system must contain statvfs(). 
You must be running perl.5003 or higher.

=head1 AUTHOR

Ian Guthrie
IGuthrie@aol.com

=head1 SEE ALSO

statvfs(2), df(1M), bdf(1M)

perl(1).

=cut

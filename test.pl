# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
require 5.003;
use Filesys::Statvfs;
use Filesys::Df;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my $dir='/';
my @result=Filesys::Statvfs::statvfs($dir);
(! defined @result) &&
	(die"not ok 2\nstatvfs\(\) call failed for \"$dir\" $!\n") ||
	(print"ok 2\n");

my $a_ref=df($dir);
(! defined($a_ref)) &&
	(die"not ok 3\ndf\(\) call failed: $!\n") ||
	(print"ok 3\n");

print"All tests successful!\n\n";
print"statvfs() call was successful. Results for directory: \"$dir\"\n";
my($bsize, $frsize, $blocks, $bfree, $bavail,
$files, $ffree, $favail, $fsid, $basetype, $flag,
$namemax, $fstr)=@result;

print"bsize=$bsize frsize=$frsize blocks=$blocks\n";
print"bfree=$bfree bavail=$bavail files=$files\n";
print"ffree=$ffree favail=$favail fsid=$fsid\n";
print"basetype=$basetype flag=$flag namemax=$namemax\n";
print"fstr=$fstr\n\n";


print"The df() call was successful.  Results of df() call for \"$dir\" in 1024k blocks\n";
print"Percent Full $a_ref->{PER}%\n";
print"Total Blocks $a_ref->{BLOCKS}\n";
print"Total Blocks Used $a_ref->{USED}\n";
print"Total Blocks Available $a_ref->{BFREE}\n";
print"Total Blocks Available To Non-SU $a_ref->{BAVAIL}\n";
print"Inode Percent Full $a_ref->{FPER}%\n";
print"Total Inodes $a_ref->{FILES}\n";
print"Total Inodes Used $a_ref->{FUSED}\n";
print"Total Inodes Free $a_ref->{FFREE}\n";

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Filesys::Statvfs;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
my $dir='/';
my @result=Filesys::Statvfs::statvfs($dir);
if(! defined @result) {
	print"error:$!\n";
	print"statvfs() call failed for \"$dir\" \n";
}

else {
	print"statvfs() call succeded for directory: \"$dir\".\n";
	my($bsize, $frsize, $blocks, $bfree, $bavail,
        $files, $ffree, $favail, $fsid, $basetype, $flag,
        $namemax, $fstr)=@result;

	print"bsize=$bsize\n";
	print"frsize=$frsize\n";
	print"blocks=$blocks\n";
	print"bfree=$bfree\n";
	print"bavail=$bavail\n";
	print"files=$files\n";
	print"ffree=$ffree\n";
	print"favail=$favail\n";
	print"fsid=$fsid\n";
	print"basetype=$basetype\n";
	print"flag=$flag\n";
	print"namemax=$namemax\n";
	print"fstr=$fstr\n";
}

package
    MacVersion;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(osx_version);

sub osx_version {
    my $os_version = qx(system_profiler SPSoftwareDataType);
    if($os_version =~ /System Version:(?: Mac)? OS X (?:Server )?(10\.\d+)/) {
        return $1;
    } else {
        $os_version =~ s/^/> /gm;

        die <<"END_DIE";
Could not parse version string!
Please file a bug report on CPAN, and include the following
in the description:

$os_version
END_DIE

        exit 1;
    }

}

1;

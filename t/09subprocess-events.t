use strict;
use warnings;
use autodie;

use IO::Select;
use File::Path qw(remove_tree);
use File::Temp;
use Mac::FSEvents;

use Test::More tests => 2;

sub touch_file {
    my ( $filename ) = @_;

    my $fh;
    open $fh, '>', $filename;
    close $fh;

    return;
}

sub subprocess (&) {
    my ( $action ) = @_;

    my $pid = fork;

    if($pid) {
        waitpid $pid, 0;
    } else {
        eval {
            $action->();
        };
        exit 0;
    }
}

my $LATENCY = 0.5;
my $TIMEOUT = 1.0;

my $dir = File::Temp->newdir;

my $fs = Mac::FSEvents->new({
    path    => $dir->dirname,
    latency => $LATENCY,
});
my $fh  = $fs->watch;
my $sel = IO::Select->new($fh);

# our subprocess will call DESTROY on the Mac::FSEvents object!
my $pid = fork;
unless($pid) {
    exit 0;
}
waitpid $pid, 0;

touch_file "$dir/foo.txt";

my $has_events = $sel->can_read($TIMEOUT);
ok $has_events;

my @events = $fs->read_events;
is scalar(@events), 1;

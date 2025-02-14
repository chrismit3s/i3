#!perl
# vim:ts=4:sw=4:expandtab
#
# Please read the following documents before working on tests:
# • https://build.i3wm.org/docs/testsuite.html
#   (or docs/testsuite)
#
# • https://build.i3wm.org/docs/lib-i3test.html
#   (alternatively: perldoc ./testcases/lib/i3test.pm)
#
# • https://build.i3wm.org/docs/ipc.html
#   (or docs/ipc)
#
# • http://onyxneon.com/books/modern_perl/modern_perl_a4.pdf
#   (unless you are already familiar with Perl)
#
# Tests for using environment variables in the config.
use i3test i3_autostart => 0;

sub get_marks {
    return i3(get_socket_path())->get_marks->recv;
}

my $config = <<EOT;
# i3 config file (v4)
#font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1

set_from_env \$mark mark none
for_window [class=worksforme] mark \$mark

set_from_env \$othermark doesnotexist none
for_window [class=doesnotworkforme] mark \$othermark

EOT

$ENV{'mark'} = 'works';
delete $ENV{'doesnotworkforme'};

my $pid = launch_with_config($config);

open_window(wm_class => 'worksforme');
sync_with_i3;
is_deeply(get_marks(), [ 'works' ], 'the environment variable has loaded correctly');

cmd 'kill';

open_window(wm_class => 'doesnotworkforme');
sync_with_i3;
is_deeply(get_marks(), [ 'none' ], 'the environment variable fallback was used');

exit_gracefully($pid);

done_testing;

use strict;

use Test::More;
plan tests => 18;

use DateTime;

# default - DateTime::Exception->throw
{
    eval { DateTime->new( month => 1 ) };
    my $e = $@;

    ok( $e, "missing params to new" );
    ok( ref $e, "default should be exception object" );
    isa_ok( $e, "DateTime::Exception" );
    like( $e->error, qr/Attribute .+ required/ );
}

# custom die
{
    DateTime->ErrorHandler( sub { die "Boom!\n" } );
    eval { DateTime->new( month => 1 ) };
    my $e = $@;

    ok( $e, "missing params to new" );
    is( $e, "Boom!\n" );
}

# plain die
{
    DateTime->ErrorHandler(0);
    DateTime->RaiseError(1);
    eval { DateTime->new( month => 1 ) };
    my $e = $@;

    ok( $e, "missing params to new" );
    ok( ! ref $e, "RaiseError should not cause exception" );
    like( $e, qr/Attribute .+ required/ );
}

# just a warning
{
    DateTime->ErrorHandler(0);
    DateTime->RaiseError(0);
    DateTime->PrintError(1);
    my $warned = '';
    local $SIG{__WARN__} = sub { $warned .= join '', @_ };
    eval { DateTime->new( month => 1 ) };
    my $e = $@;

    ok( ! $e, "missing params to new - no death" );
    like( $warned, qr/Attribute .+ required/ );
}

# combo
{
    DateTime->ErrorHandler(0);
    DateTime->RaiseError(1);
    DateTime->PrintError(1);
    my $warned = '';
    local $SIG{__WARN__} = sub { $warned .= join '', @_ };
    eval { DateTime->new( month => 1 ) };
    my $e = $@;

    ok( $e, "missing params to new" );
    ok( ! ref $e, "RaiseError should not cause exception" );
    like( $e, qr/Attribute .+ required/ );

    like( $warned, qr/Attribute .+ required/ );
}

# another combo - ErrorHandler overrides RaiseError
{
    DateTime->ErrorHandler( sub { die "Boom!\n" } );
    DateTime->RaiseError(1);
    DateTime->PrintError(1);
    my $warned = '';
    local $SIG{__WARN__} = sub { $warned .= join '', @_ };
    eval { DateTime->new( month => 1 ) };
    my $e = $@;

    ok( $e, "missing params to new" );
    is( $e, "Boom!\n" );

    like( $warned, qr/Attribute .+ required/ );
}


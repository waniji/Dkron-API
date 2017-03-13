package Dkron::API::Error;
use strict;
use overload '""' => sub { $_[0]->error };

sub throw {
    my ($class, @args) = @_;
    die $class->new(@args);
}

sub rethrow {
    die $_[0];
}

sub new {
    my ($class, %args) = @_;
    bless \%args, $class;
}

sub error {
    "Error: " . ($_[0]->{error} || ref $_[0]);
}

package Dkron::API::Error::MissingRequiredParameter;
use parent 'Dkron::API::Error';

package Dkron::API::Error::UnknownOption;
use parent 'Dkron::API::Error';

1;

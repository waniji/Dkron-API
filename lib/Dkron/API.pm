package Dkron::API;
use 5.008001;
use strict;
use warnings;

use Furl;
use JSON::XS qw/decode_json/;

our $VERSION = "0.01";

sub new {
    my ($class, %args) = @_;

    bless {
        host => $args{host},
        port => $args{port},
    }
}

sub ua {
    my $self = shift;
    $self->{ua} //= Furl->new(timeout => 3);
}

sub base_url {
    my $self = shift;
    $self->{base_url} //= sprintf("http://%s:%s/v1/", $self->{host}, $self->{port});
}

sub get_jobs {
    my $self = shift;
    my $res = $self->ua->get($self->base_url . "jobs");
    decode_json $res->content;
}


1;
__END__

=encoding utf-8

=head1 NAME

Dkron::API - It's new $module

=head1 SYNOPSIS

    use Dkron::API;

=head1 DESCRIPTION

Dkron::API is ...

=head1 LICENSE

Copyright (C) Makoto Sasaki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Makoto Sasaki E<lt>E<gt>

=cut


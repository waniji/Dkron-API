package Dkron::API::CLI;
use strict;
use warnings;
use Getopt::Long;
use Try::Tiny;

use Dkron::API;
use JSON::XS;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub json {
    my $self = shift;
    $self->{json} //= JSON::XS->new->utf8;
}

sub run {
    my ($self, @argv) = @_;

    my $command = shift @argv;
    my %options = $self->parse_options(@argv);

    my $exit_code = try {
        my $client = Dkron::API->new(
            host => $options{host},
            port => $options{port},
        );
        my $call = $self->can("cmd_$command") or die "Invalid command: $command";
        $self->$call($client, %options);
        return 0;
    } catch {
        warn $_;
        return 255;
    };

    return $exit_code;
}

sub parse_options {
    my ($self, @argv) = @_;

    my $p = Getopt::Long::Parser->new(
        config => [ "posix_default", "no_ignore_case" ]
    );
    $p->getoptionsfromarray(\@argv, \my %options, qw/
        host=s
        port=s
        name=s
        schedule=s
        command=s
        tags=s
    /);

    return %options;
}

sub cmd_get_jobs {
    my ($self, $client, %options) = @_;

    my $result = $client->get_jobs;
    print $self->json->encode($result), "\n";
}

sub cmd_post_job {
    my ($self, $client, %options) = @_;

    my $result = $client->post_job({
        name => $options{name},
        schedule => $options{schedule},
        command => $options{command},
        tags => $self->json->decode($options{tags}),
    });
    print $self->json->encode($result), "\n";
}

sub cmd_delete_job {
    my ($self, $client, %options) = @_;

    my $result = $client->delete_job($options{name});
    print $self->json->encode($result), "\n";
}

1;

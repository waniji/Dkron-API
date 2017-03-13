package Dkron::API::CLI;
use strict;
use warnings;
use Getopt::Long;
use Try::Tiny;
use JSON::XS;

use Dkron::API;
use Dkron::API::Error;

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

    my $exit_code = try {
        my %parameters = $self->_parse_required_parameters(\@argv, qw/
            host=s
            port=i
        /);
        my $client = Dkron::API->new(
            host => $parameters{host},
            port => $parameters{port},
        );
        my $call = $self->can("cmd_$command") or die "Invalid command: $command";
        $self->$call($client, \@argv);
        return 0;
    } catch {
        if ($_->isa('Dkron::API::Error::MissingRequiredParameter')) {
            warn $_->error, "\n";
            $self->cmd_usage;
        } elsif ($_->isa('Dkron::API::Error::UnknownOption')) {
            $self->cmd_usage;
        } else {
            warn $_;
        }
        return 255;
    };

    return $exit_code;
}

sub _parse_required_parameters {
    my ($self, $argv, @spec) = @_;

    my $p = Getopt::Long::Parser->new(
        config => [ "posix_default", "no_ignore_case", "pass_through" ]
    );
    $p->getoptionsfromarray($argv, \my %parameters, @spec);

    # TODO: Make a better way
    my @required_parameters = map { s/=.*//; $_; } @spec;
    for my $required (@required_parameters) {
        unless (exists $parameters{$required}) {
            Dkron::API::Error::MissingRequiredParameter->throw(error => "'--$required' is required");
        }
    }

    return %parameters;
}

sub _parse_options {
    my ($self, $argv, @spec) = @_;

    my $p = Getopt::Long::Parser->new(
        config => [ "posix_default", "no_ignore_case" ]
    );
    $p->getoptionsfromarray($argv, \my %options, @spec)
        or Dkron::API::Error::UnknownOption->throw();

    return %options;
}

sub commands {
    my $self = shift;

    no strict 'refs';
    map { s/^cmd_//; $_ }
        grep { /^cmd_.*/ && $self->can($_) } sort keys %{__PACKAGE__."::"};
}

sub cmd_usage {
    my $self = shift;
    print(<<HELP);
Usage: dkron-cli <command> --host <string> --port <integer> [parameters]
where <command> is one of:
  @{[ join ", ", $self->commands ]}
HELP
}

sub cmd_status {
    my ($self, $client) = @_;

    my $result = $client->status;
    print $self->json->encode($result), "\n";
}

sub cmd_get_jobs {
    my ($self, $client) = @_;

    my $result = $client->get_jobs;
    print $self->json->encode($result), "\n";
}

sub cmd_post_job {
    my ($self, $client, $argv) = @_;

    my %parameters = $self->_parse_required_parameters($argv, qw/
        name=s
        schedule=s
        command=s
    /);

    my %options = $self->_parse_options($argv, qw/
        shell
        owner=s
        owner_email=s
        disabled
        tags=s
        retries=i
        parent_job=s
        processors=s
        concurrency=s
    /);

    for my $key (keys %options) {
        if ($key eq "tags" || $key eq "processors") {
            $parameters{$key} = $self->json->decode($options{$key});
        }
        elsif ($key eq "shell" || $key eq "disabled") {
            $parameters{$key} = $options{$key} ? Types::Serialiser::true : Types::Serialiser::false;
        }
        else {
            $parameters{$key} = $options{$key};
        }
    }

    my $result = $client->post_job(\%parameters);
    print $self->json->encode($result), "\n";
}

sub cmd_delete_job {
    my ($self, $client, $argv) = @_;

    my %options = $self->_parse_required_parameters($argv, qw/
        name=s
    /);

    my $result = $client->delete_job($options{name});
    print $self->json->encode($result), "\n";
}

1;

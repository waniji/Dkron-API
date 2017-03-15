# NAME

Dkron::API - Client library for Dkron

# SYNOPSIS

    use Dkron::API;

    my $dkron = Dkron::API->new(
        host => 'localhost',
        port => 8946,
    );
    $dkron->execute_job('job');

# DESCRIPTION

Dkron::API is ...

# SEE ALSO

- [http://dkron.io/docs/api/](http://dkron.io/docs/api/) - Dkron REST API documentation

# LICENSE

Copyright (C) Makoto Sasaki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Makoto Sasaki

requires 'perl', '5.008001';
requires 'Furl';
requires 'JSON::XS';
requires 'Getopt::Long', 2.39;
requires 'Try::Tiny';

on 'test' => sub {
    requires 'Test::More', '0.98';
};


use strict;
use warnings;
use Test::More;
use Plack::Builder;
use lib '../lib';

sub build_handler {
    builder {
        enable "Plack::Middleware::HttpMethodTunnel";
        sub { my $env = shift; is($env->{REQUEST_METHOD}, $env->{__expect}) };
    };
}

my @tests = (
  { 
    REQUEST_METHOD      => "GET",
    'X-HTTP-Method'     => "",
    __expect            => "GET",
  },
  { 
    REQUEST_METHOD      => "GET",
    'X-HTTP-Method'     => "POST",
    __expect            => "GET",
  },
  { 
    REQUEST_METHOD      => "GET",
    'X-HTTP-Method'     => "HEAD",
    __expect            => "HEAD",
  },
  { 
    REQUEST_METHOD      => "POST",
    'X-HTTP-Method'     => "PUT",
    __expect            => "PUT",
  },
  { 
    REQUEST_METHOD      => "GET",
    'X-HTTP-Method'     => "DELETE",
    __expect            => "GET",
  },
  { 
    REQUEST_METHOD      => "POST",
    'X-HTTP-Method'     => "DELETE",
    __expect            => "DELETE",
  },
  { 
    REQUEST_METHOD      => "POST",
    'X-HTTP-Method'     => "GET",
    __expect            => "GET",
  },
);

foreach my $env (@tests) {
      build_handler()->($env);
}

done_testing();


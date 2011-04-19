package Plack::Middleware::HttpMethodTunnel;

use parent qw( Plack::Middleware );
use Plack::Request;

sub call {
    my ($self, $env) = @_;
    my $real_method = $env->{REQUEST_METHOD};

    # handle override
    my $tunnel_method = uc $env->{'X-HTTP-Method'};
    unless ($tunnel_method) {
        my $request = Plack::Request->new($env); # don't parse unless we must
        $tunnel_method = uc( $request->param('X-HTTP-Method') || $real_method );
    }

    # handle tunnelling
    if ($real_method eq 'POST') { # POST can tunnel any method.
        $env->{REQUEST_METHOD} = $tunnel_method;
    }
    elsif ( $real_method eq 'GET' and $tunnel_method =~ /^(GET|HEAD)$/ ) { # GET can only tunnel GET/HEAD
        $env->{REQUEST_METHOD} = $tunnel_method;
    }
    else {
        $env->{REQUEST_METHOD} = $real_method;
    }
    return $self->app->($env);
}

=head1 NAME

Plack::Middleware::HttpMethodTunnel - Tunnel HTTP methods over GET and POST.

=head1 SYNOPSIS

 use Plack::Builder;

 my $app = sub {
    return [ 200, [ 'Content-Type' => 'text/plain' ], [ 'Hello Foo' ] ];
 };

 builder {
    enable "Plack::Middleware::HttpMethodTunnel";
    $app;
 };

# X-HTTP-Method: DELETE

=head1 DESCRIPTION

HTML Forms don't allow HTTP methods other than POST or GET. While many of us use XmlHttpRequest these days (which does support DELETE and PUT), that's not always feasible or desired for every application. Therefore if you want to build a RESTful web app, or RESTful web services, and you want to provide an alternate way to specify those methods, this module is the answer.

All you need to do, is enable this middleware in your app. Then when making your request do one of theree things:

=over 

=item HTTP Header

Specifiy an HTTP Header:

 X-HTTP-Method: DELETE

=item Query Param

Specify a query param:

 /some/page?X-HTTP-Method=HEAD

=item Post Body Param

Specify a post body param via a hidden field:

 <form method="POST">
    <input type="hidden" name="X-HTTP-Method" value="PUT">
 </form>

=back

=head1 CAVEATS

Only GET and HEAD may be tunneled over a GET request. All other methods must be tunneled over a POST.

If you specified both an HTTP header and a request param, the HTTP header will take precidence. 

=head1 SUPPORT

=over

=item Repository

L<http://github.com/rizen/Plack-Middleware-HttpMethodTunnel>

=item Bug Reports

L<http://github.com/rizen/Plack-Middleware-HttpMethodTunnel/issues>

=back

=head1 SEE ALSO

Much of the implementation details for this were stolen from L<REST::Application>. 

=head1 AUTHOR

JT Smith <jt_at_plainblack_dot_com>

=head1 LEGAL

Ouch is Copyright 2011 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut

1;

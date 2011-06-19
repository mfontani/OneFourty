package OneFourty;
use Dancer ':syntax';
use Dancer::Plugin::Cache::CHI;
$ENV{NET_TWITTER_NO_TRENDS_WARNING}=1;
use Net::Twitter;

our $VERSION = '0.1';

our $bird = Net::Twitter->new(
    decode_html_entities => 1,
    traits               => [qw/API::Search/],
);

before_template sub {
    my $tokens = shift;
    $tokens->{contestants} = cache->get('contestants');
    $tokens->{winners}     = cache->get('winners');
    $tokens->{losers}      = cache->get('losers');
};

get '/' => sub {
    template 'index';
};

post '/search' => sub {
    return redirect '/' unless params->{q} and params->{search};
    return redirect '/user/' . params->{q} if params->{q} =~ /^[a-z0-9_-]+$/i;
    return redirect '/';
};

get '/user/:name' => sub {
    return redirect '/' if params->{name} !~ /^[a-z0-9_-]+/i;
    my $data = cache->compute('last-for-' . params->{name}, '5min', sub {

        my @last = eval { grep { $_->{text} !~ /^RT @/ } @{ $bird->search( "from:" . params->{name} )->{results} } };
        if (!@last) {
            return { error => 'No tweets found :(' };
        }
        my $total   = 0;
        my $matched = 0;
        for (@last) {
            $total++;
            $matched++ if length $_->{text} == 140;
        }

        # Update latest contestants and leaderboard
        {
            my $contestants = cache->get('contestants');
            $contestants = [] if !defined $contestants or ref $contestants ne 'ARRAY';
            $contestants  = [ grep { $_->{name} ne params->{name} } @$contestants ];
            unshift @$contestants, { name => params->{name}, total => $total, matched => $matched };
            $contestants = [ grep defined, @$contestants[0..9] ];
            cache->set('contestants', $contestants);

            my $losers = cache->get('losers');
            $losers = [] if !defined $losers or ref $losers ne 'ARRAY';
            my $winners = cache->get('winners');
            $winners = [] if !defined $winners or ref $winners ne 'ARRAY';

            # Remove the user from both lists
            $losers  = [ grep { $_->{name} ne params->{name} } @$losers ];
            $winners = [ grep { $_->{name} ne params->{name} } @$winners ];

            # If none matched, add to losers
            if (!$matched) {
                unshift @$losers, { name => params->{name}, total => $total, matched => $matched };
            }
            # If at least one matched, and the user matched the same as total,
            # add to winners
            if ( $matched && $matched == $total ) {
                unshift @$winners, { name => params->{name}, total => $total, matched => $matched };
            }
            $losers  = [ grep defined, @$losers[ 0 .. 9 ] ];
            $winners = [ grep defined, @$winners[ 0 .. 9 ] ];
            cache->set( 'losers',  $losers );
            cache->set( 'winners', $winners );
        }

        return { last => \@last, total => $total, matched => $matched };
    });

    return template results => { q => params->{name}, error => $data->{error} }
        if !$data or exists $data->{error};

    return template results => {
        q             => params->{name},
        total_results => $data->{total},
        matched       => $data->{matched},
        tweets        => $data->{last},
    };
};

true;

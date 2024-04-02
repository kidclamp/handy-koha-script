use String::Random qw(random_string);
use Modern::Perl;
use LWP::UserAgent;
use Digest::MD5 qw( md5_base64 );
use Data::Dumper;

my $url = 'http://localhost:8080/cgi-bin/koha/opac-memberentry.pl?borrower_surname=RULZ&borrower_firstname=HAXZORZ&borrower_branchcode=CPL&borrower_categorycode=PT&captcha=';

my $captcha = random_string('CCCCC');
my $captcha_digest = md5_base64( $captcha );

my $ua = LWP::UserAgent->new;

for( my $i = 0; $i < 10; $i++){

my $card = random_string('CCCCC');
my $post_url = $url.$captcha."&captcha_digest=".$captcha_digest."&action=create&borrower_cardnumber=$card";
warn $post_url;
my $response = $ua->post($post_url);
#warn Data::Dumper::Dumper($response);

}


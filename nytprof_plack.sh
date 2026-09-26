#!/bin/bash

PSGI_FILE="/etc/koha/sites/kohadev/plack.psgi"
INTRANET_PLACK_SHARED_FILE="/etc/koha/apache-shared-intranet-plack.conf"
NYTPROF_DIR="/var/lib/koha/kohadev/report"

mkdir -p "$NYTPROF_DIR"

sudo apt install -y libdevel-nytprof-perl libplack-middleware-debug-perl
sudo cpanm Plack::Middleware::Profiler::NYTProf

if ! grep -qF "# NYTProf plack added" "$PSGI_FILE"; then
    sudo sed -i '/mount \x27\/intranet\x27      => builder {/a \ \
        # NYTProf plack added \
        enable_if \{\
            my \$env_check \= shift\;\
            my \$req \= Plack::Request-\>new\(\$env_check\)\;\
            my \$profile_this \= \$req-\>header\(\x27http_profile_the_thing\x27\)\;\
            return defined \$profile_this\
        \} \x27Profiler::NYTProf\x27=> [root=>\x27/var/lib/koha/kohadev/report/\x27]\;' "$PSGI_FILE"
    sudo sed -i  '/my \$apiv1  = builder {/i \ \
my \$nytprof = Plack::App::Directory->new(root => "\$home/nytprof/report")->to_app\;\
        ' "$PSGI_FILE"
    sudo sed -i  '/mount \x27\/intranet\x27      => builder {/i \
    mount \x27/nytprof\x27 => builder {\$nytprof\;}\;' "$PSGI_FILE"
fi

if ! grep -qF "# NYTProf plack added" "$INTRANET_PLACK_SHARED_FILE"; then
    echo "SED\n";
    sudo sed -n  '/Point the intranet site to Plack/p' "$INTRANET_PLACK_SHARED_FILE"
    sudo sed -i  '/Point the intranet site to Plack/i \
        # NYTProf plack added\
        ProxyPass /nytprof "unix:/var/run/koha/\${instance}/plack.sock|http://localhost/nytprof"\
        ProxyPassReverse /nytprof "unix:/var/run/koha/\${instance}/plack.sock|http://localhost/nytprof"\
        ' "$INTRANET_PLACK_SHARED_FILE"
fi

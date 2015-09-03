#! /bin/sh
#
# Site configuration test script
#
# Jordan Hrycaj <jordan@teddy-net.com>
#
# $Id$
#

# trg: theme specific configuration
trg="public/contact/mail/contact_me.php"

self=`basename $0`

baseurl_value () { # Syntax: <filename>
    # make sure we have three fields: <var> = <value>
    sed 's/=/ = /' "$@" |

	# lower case entries wanted only
	tr '[:upper:]' '[:lower;]' |

	# filter out email from params section
	awk '$1=="baseurl"{print $3;exit}' |

	# strip quotes
	sed 's/["'\'']//g'
}

email_value () { # Syntax: <filename>
    # make sure we have three fields: <var> = <value>
    sed 's/=/ = /' "$@" |

	# lower case entries wanted only
	tr '[:upper:]' '[:lower;]' |

	# filter out email from params section
	awk '$1=="[params]"{f=1;next}$1=="email"{print $3;exit}' |

	# strip quotes
	sed 's/["'\'']//g'
}

usage () {
    echo >&2
    test -z "$*" || {
	echo "*** $self: $*!" >&2
	echo >&2
    }
    echo "Usage: $self [--help | -h | <config-file>]" >&2
    echo >&2
    exit 2
}

info () {
    cat <<EOF

Testing site email form
------------------------

This script sends a test email through the web service.

Background

  A static web site (as the one here) cannot handle email by itself so
  it needs support by some sort of active component like CGI, PHP or
  PERL script that runs with/in the web server. Most commercial hoster
  sites support some sort of active component.

  The "hugo" web server does not support active components so it cannot
  be used for testing whether email will work on the production site.

  Apache supports all sorts of active components. Assuming a Debian/Sarge
  system it will nearly work out of the box. It is assumed that Apache
  with PHP5 support is properly installed.

  It is also assumed that sendmail (or any replacement) is not installed
  yet. Otherwise one can proceed with step 7 follwed by step 8 and 9.

Test site setup using Apache2/PHP5

  After Apache/PHP5 setup, the following configuration steps are needed:

  1. DON'T PANIC

     The setup procedure is explained in detail including test commands
     and procedures. This amounts to a lot of text despite the fact that
     there are only a few configutation items.

  2. Set the DocumentRoot for the virtual website.

     Make sure that the user "www-data" is able to access the site root.
     This might be achieved by moving the whole site to /var/www and
     setting

          DocumentRoot /var/www/<site-root>/public

     in /etc/apache2/sites-enabled/000-default.conf. You can test user
     "www-data" access with the command

          sudo -u www-data /bin/sh

  3. Set the base URL in the file "config.toml". This would be something
     like

          baseurl = "http://localhost:80"

     according to what the VirtualHost setting in the Apache site
     configuration is set to. The default is <VirtualHost *:80> which
     works with the example above.

  4. Rebuild the site. Simply run

          hugo

     and restart Apache

          /etc/init.d/apache2 restart

     in order to make the configuration changes effective.

     Test site access with your browser at "http://localhost" (or whatever
     you configued in steps 2 and 3.)

  5. Install msmtp as a sendmail repacement. On Debian/Sarge, run the
     command

          apt-get install msmtp-mta

  6. Now, msmtp as a sendmail repacement needs to be activated for PHP5
     in the conig file /etc/php5/apache2/php.ini by setting

          sendmail_path = sendmail -t -i

     Get an email test account, e.g. on gmail.com which I will use for
     the example here with:

          email-address: <testuser>@gmail.com
          password:      <topsecret>

  7. Place a file .msmtprc into the Apache home directory i.e. the home
     directory for the user "www-data". On stock Debian/Sarge this would
     be /var/www. The contents of /var/www/.msmtprc should look like

          defaults
          port 587
          tls on
          tls_trust_file /etc/ssl/certs/ca-certificates.crt
          syslog LOG_MAIL
          account google
          host smtp.gmail.com
          auth on
          from <testuser>@gmail.com
          user <testuser>
          password <topsecret>
          account default : google

     Restrict access credenials with the commands

          chmod 0600     /var/www/.msmtprc
          chown www-data /var/www/.msmtprc
          chgrp www-data /var/www/.msmtprc

     Now test whether the settings work by sending a test mail to another
     email account, e.g. <yours>@<truly>.org:

          echo yeah! | sudo -u www-data msmtp -dvti <yours>@<truly>.org

     You shoud find the test mail somewhere in the inbox and sent folders
     of <testuser>@gmail.com and <yours>@<truly>.org.

  8. Edit the email forwarder script

         $trg

     and set the variables at the beginning of the script to

         \$dest_handle = '<testuser>';
         \$dest_addr   = 'gmail.com';

     NOTE: Have a look at the script

         `dirname $0`/setup-email-form.sh

     which can be used to automate this last step in a Makefile.

  9. Make sure your config.toml file has the email parameter set to
     something like

         [params]
            email = "<yours>@<truly>.org"

     And that is it. Run this scrip as

         sh $0 config.toml

     which will send a contact test email from "<yours>@<truly>.org"
     to the test mailbox at "<testuser>@gmail.com".

Finally

     You should test your email form now in real with the web browser.

EOF
    (usage) 2>&1
    exit 0
}

# MAIN

case "$*" in
--help|-h|'') info;;
-*)           usage "unsupported option $1"
esac
test "$#" -eq 1 ||
    usage "More than one command line argument"

test -s "$1" ||
    usage "No such configuration file: $1"

cgi=`expr "$trg" : 'public/\(.*\)' \| "$trg"`
test -s "public/$cgi" ||
    usage "No such php mail forwarder script: \"public/$cgi\""

# filter out email value from configuration
email=`email_value "$1"`
test -n "$email" ||
    usage "No \"email\" address in configuration file: $1"

# filter out baseurl value from configuration
url=`baseurl_value "$1"`
test -n "$url" ||
    usage "No \"baseurl\" address in configuration file: $1"

# Need curl here ...
curl -V >/dev/null ||
    usage "The programme \"curl\" is needed to run this test"

# send email test message
now=`date`
(set -x; curl -v -s \
	      -F name=Conection-test \
	      -F phone=1234567890 \
	      -F email="$email" \
	      -F message="Testmail sent on $now" \
	      "$url/$cgi")
echo
# End

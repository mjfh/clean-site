#! /bin/sh
#
# Site configuration helper script, filter/edit php email forwarder
#
# Jordan Hrycaj <jordan@teddy-net.com>
#
# $Id$
#

# trg: theme specific configuration
trg="public/contact/mail/contact_me.php"

self=`basename $0`

edit_forwarder_script () { # Syntax: <filename> [<contact>@]<addr>
	f="$1"
	c=`expr "$2" : '\(.*\)@'`
	a=`expr "$2" : '.*@\(.*\)' \| "$2"`

	# define/replace destination address (edit in place)
	perl -pi -e "s/^(\\\$dest_addr\s*=).*/\$1 '$a';/" "$f"

	test -n "$c" || return

	# define/replace contact name (if present, edit in place)
	perl -pi -e "s/^(\\\$dest_handle\s*=).*/\$1 '$c';/" "$f"
}

contact_value () { # Syntax: <filename>
	# make sure we have three fields: <var> = <value>
	sed 's/=/ = /' "$@" |

	# lower case entries wanted only
	tr '[:upper:]' '[:lower;]' |

	# filter out contact from params section
	awk '$1=="[params]"{f=1;next}$1=="contact"{print $3;exit}' |

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

Setup site email script
-----------------------

This script automates the setup of the PHP5 email forwarder.

Background

  For sending contact email a PHP5 script will be used on the production
  site. This script uses a hard-coded forwarder adress which is set up
  automatically by this script.

  For details on setting up Apache/PHP5 for a test site supporting
  email over PHP5 run

         sh `dirname $0`/send-test-email.sh

Email script site setup

  1. Make sure your config.toml file has the email parameter set to
     something like

         [params]
            contact = "<testuser>@gmail.com"

     where "<testuser>@gmail.com" is an example for a email address
     for a contact mailbox.

  2. Run
         hugo

     and then this script as

         sh $0 config.toml

  3. Verify the changes by running

         diff *`expr $trg : '[^/]*\(.*\)'`

     it shoud idicate that the variables

         \$dest_handle = '<testuser>';
         \$dest_addr   = 'gmail.com';

     are set accordingly.

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

test -s "$trg" ||
    usage "No such php mail forwarder script: $trg"

# filter out contact value from configuration
addr=`contact_value "$1"`

test -n "$addr" ||
    usage "No \"contact\" address in configuration file: $1"

# edit and pipe out php configuration
edit_forwarder_script "$trg" "$addr"

# End

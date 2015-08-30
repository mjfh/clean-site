## About

Hugo theme based on on the Hugo port

  [startbootstrap-clean-blog](https://github.com/humboldtux/startbootstrap-clean-blog/)

of the startbootstrap theme

  [Start Bootstrap Clean Blog](http://startbootstrap.com/template-overviews/clean-blog/) 

![Screenshot](https://raw.githubusercontent.com/humboldtux/startbootstrap-clean-blog/master/images/tn.png)

Apart from cosmetic changes most of this theme is the same as the one this is
forked from. The main difference is that this fork uses the original PHP5
email forwarder with some automation scripts bundled by a Makefile.

## Test setup ASIS

Just use this package asis.

#### As is (without email forwarder)

   ```
   hugo server --theme=theme.toml
   ```

#### As is + email forwarder

You need GNU make installed or set the Makefile variables manually

   ```
   SCRIPTS = scripts<br>
   CONFIG  = theme.toml
   ```

Edit the config file theme.toml and set the contact address in the
\[params\] section


   ```
   \[params\]
   contact = "<contact>@<address>.org"
   ```

to an email adress of an account that will receive the contact
messages. Then run

   ```
   make site
   ```

In theory that is it. A bit more detailed explanation of what this make
command does is available with

   ```
   make howto-site
   ```

In practice you will have to set up your web server for testing so it can
forward the email messages.

In order to send a test mail you could run

   ```
   make test-mail
   ```

but this would most certainly not work as your mail forwarding process needs
support from your web server (hugo won't do here). There are detailed setup
instructions available with

   ```
   make howto-test-mail
   ```

## Theme setup

Run

   ```
   hugo new site my-site
   mkdir -p themes/clean-site
   git clone https://github.com/mjfh/clean-site.git themes/clean-site
   cp themes/clean-site/Makefile .
   (echo "theme='clean-site'";cat themes/clean-site/theme.toml) >config.toml
   ```

Now the system is set up. Run

   ```
   hugo server
   ```

in order to test it. You may want to copy some more test content
from the theme as

   ```
   cp themes/clean-site/content/*.md content/
   ```

Now go back to the section \[As is + email forwarder\] in order to setup
email.

## Full features set up

Please have a look at

   [startbootstrap-clean-blog](https://github.com/humboldtux/startbootstrap-clean-blog/)

and

   [HugoBasicExample](https://github.com/spf13/HugoBasicExample).

-- jordan

[//]: # (Local Variables:)
[//]: # (mode:markdown)
[//]: # (comment-column:0)
[//]: # (comment-start: "[//]: # (")
[//]: # (comment-end:"***")
[//]: # (End:)

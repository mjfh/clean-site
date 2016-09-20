/*
 * Configuration variables:
 *
 *   Required:
 *     debate_provider -- e.g. disqus
 *     debate_forum_id -- your forum id
 *     debate_post_id  -- identifier for each page
 *
 * To enable debate for a particular post (see footer.html partials):
 *
 *   Global theme/config file parameter settings:
 *
 *     [params.debate]
 *        provider = "<provider>"
 *        forum = "<forum-id>"
 *        script = "debate"
 *
 *   In the front matter of a contens file:
 *
 *     # activate debate for this particular post
 *     debate_id = "<post-id>"
 *
 *     # optionally overwrite <provider>/<forum-id>/<this-very-script>
 *     debate_provider = "<other-provider>"
 *     debate_forum = "<other-forum-id>"
 *     debate_script = "<other-script-name>"
 *
 * $Id$
 *
 * -- jordan
 */

// ---------------------------------------------------------------------
// Configuration (if you want to disable some unused providers)
// ---------------------------------------------------------------------

// List of supported provider activation names, comment out the
// ones that are not needed.
var debate_enable = {
    disqus:        "disqus",
    intensedebate: "intensedebate",
    burnzone:      "burnzone",
    livefyre:      "livefyre",
};
// You might then use a JS minimiser or packer which will minimise
// this script and optimise out unused code

// ---------------------------------------------------------------------
// Probably no need to change anything below ...
// ---------------------------------------------------------------------

// Pull in with JQuery
$(document).ready (function () {

    // Blurb function with tooltip
    function mnote (explain, tooltip) {
	if (tooltip) {
	    explain = ('<span id="debate-info" data-toggle=' +
		       '"tooltip" data-placement="bottom" title="' +
		       tooltip + '">' + explain + '</span>');
	}
	$('#debate-sink').before (
	    '<div class="' + $('#debate-sink').attr('class') +' '+
		'alert alert-warning alert-dismissible" ' +
		'role="alert"><button type="button" ' +
		'class="close" data-dismiss="alert" ' +
		'aria-label="Close"><span aria-hidden="true"' +
		'>&times;</span></button>' + explain + '</div>');
	if (tooltip)
	    $('#debate-info').tooltip ();
    }

     // Get info texts and provider method: enable()
    function debate_specs (provider) {
	if (provider == debate_enable.disqus) {
	    return {
		sslok: true,
		name: "DISQUS",
		info: ('//en.wikipedia.org/wiki/Disqus' +
		       '#Criticism_and_privacy_concerns'),

		enable: function () {
		    window ['disqus_shortname'] = debate_forum_id ;
		    window ['disqus_identifier'] = debate_post_id ;
		    $('#debate-sink').attr ('id', 'disqus_thread');

		    var pfx = '//' + debate_forum_id + '.disqus.com/' ;

		    $.getScript

		    (pfx + 'count.js',              // this one first

		     function () {                  // next is this one
			 $.getScript (pfx + 'embed.js')
		     });
		}
	    };
	}
	if (provider == debate_enable.intensedebate) {
	    return {
		name: "IntenseDebate",
		info: "//en.wikipedia.org/wiki/IntenseDebate",

		enable: function () {
		    window ['idcomments_post_url']   = '';
		    window ['idcomments_post_title'] = '';
		    window ['idcomments_acct']       = debate_forum_id ;
		    window ['idcomments_post_id']    = debate_post_id ;

		    $('#debate-sink')
			.html ('<span id="IDCommentsPostTitle">' +
			       '</span>');

		    function script (s) {
			return ('<script src="//' +
				'www.intensedebate.com/js/generic' +
				s + 'WrapperV2.js"></script>');
		    }
		    $('#IDCommentsPostTitle')
			.after (script ('Comment') + script ('Link'));
		}
	    };
	}
	if (provider == debate_enable.burnzone) {
	    return {
		name: "BurnZone",
		info: "//wordpress.org/plugins/burnzone-commenting/",

		enable: function () {
		    $('#debate-sink').attr ('id', 'conversait_area');
		    window ['conversait_sitename'] = debate_forum_id;
		    window ['conversait_id'] = debate_post_id ;

		    $.getScript                     // load this one

		    ('//www.theburn-zone.com/web/js/embed.js');
		}
	    };
	}
	if (provider == debate_enable.livefyre) {
	    return {
		name: "LiveFyre",
		info: "//en.wikipedia.org/wiki/LiveFyre",

		enable: function () {
		    $('#debate-sink')
			.attr ('id', 'livefyre-comments');

		    $.getScript

		    ('//zor.livefyre.com/' +        // load this one
		     'wjs/v3.0/javascripts/livefyre.js',

		     function (script, status) {    // then activate

			 var meta = {};
			 meta ['articleId']= debate_post_id;
			 meta ['url']      = fyre.conv.load
			     .makeCollectionUrl ();

			 var dt = {};
			 dt ['el'] = 'livefyre-comments';
			 dt ['network']   = "livefyre.com";
			 dt ['siteId']    = debate_forum_id;
			 dt ['articleId'] = debate_post_id;
			 dt ['signed']    = false;
			 dt ['collectionMeta'] = meta ;

			 fyre.conv.load ({}, [dt], function () {})});
		}
	    };
	}

	// No way, provider unknown
	return null ;
    }

    // Install debate provider
    function debate_setup (specs) {

	function https_running () {
	    return window.location.protocol.toLowerCase () == "https:";
	}

	// Say: debate provider is bonkers over ssl
	function htwarn (name) {
	    mnote (('External <strong>' + name + '</strong> ' +
		    'comments might not load as expected with HTTPS'),
		   ('For security reasons your browser might not accept ' +
		    'input from a non-HTTPS source when the main page is ' +
		    'loaded with HTTPS. This is an issue that needs to ' +
		    'be addressed by ' + name + '.'));
	}

	if (specs) {
	    var tooltip = ('Import external discussion list from ' +
			   specs.name + ' where you can comment on ' +
			   'this post. This might also enable ' +
			   'analytics functionality, e.g. from ' +
			   'Google.');

	    var button  = ('<a class="btn btn-default" data-toggle=' +
			   '"tooltip" data-placement="top" title="' +
			   tooltip + '"><img src=/img/chat.png alt="' +
			   specs.name + '"></a>');

	    $('#debate-sink')
		.html ('Activate debate and discussion' + button +
		       ', see <a href="' + specs.info +
		       '" rel="nofollow">' + specs.name +
		       '</a> for more information.');

	    $('#debate-sink a.btn')
		.on ('click', function () {
		    $('#debate-sink').html ('');

		    // I had problems with most debate providers
		    // running over ssl. I found that all of them
		    // pull in subsequent sources with the explicit
		    // url scheme http (which is not needed, see
		    // rfc3986). This is considered suspicious in
		    // Firefox and Chrome when the site scheme is
		    // https. It turned out that the old fashioned
		    // techology provider DISQUS using iframes was
		    // here the most usable one.
		    if (https_running () && !specs.sslok) {
			htwarn (specs.name);
		    }

		    specs.enable ();
		})
		.tooltip ();
	}

	return specs ;
    }

    // Activate ..
    (function (name) {

	if (!debate_setup (name)) {
	    mnote ('Unsupportd debate provider: <strong>' +
		   name + '</strong>', null);
	}

    } (debate_specs (debate_provider)));
});

// ---------------------------------------------------------------------
// End
// ---------------------------------------------------------------------

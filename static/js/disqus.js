/*
 * Configuration variables:
 *
 *   Required:
 *     disqus_shortname  -- your forum shortname
 *     disqus_identifier -- identifier for each page where DISQUS is present
 *
 *   Optional:
 *     disqus_title      -- unique title for each page where Disqus is present
 *     disqus_url        -- unique URL for each page where Disqus is present
 *
 * To enable DISQUS for a particular post:
 *
 *   Global theme/config file parameter settings:
 *
 *     [params]
 *        Disqus = "disqus_shortname"
 *
 *     [[params.script]]
 *        name = "disqus.js"
 *
 *   In the front matter of a contens file:
 *
 *     # activate DISQUS for this particular post
 *     disqusid = "disqus_identifier"
 *
 * $Id$
 *
 * -- jordan
 */
$(document).ready (function () {
    var tooltip = '"Import external discussion list from DISQUS where you can ' +
                  'comment on this post. This also enables analytics functionality, ' +
	          'e.g. from Google."';
    var button  = '<a class="btn btn-sm btn-default" data-toggle="tooltip" ' +
	          'data-placement="top" title=' + tooltip + '><img ' +
                  'src=/img/disqus.png alt="DISQUS"></a>';

    $('#disqus_thread').html ('Activate conversation ' + button +
			      ', see <a href="//en.wikipedia.org/wiki/Disqus' +
			      '#Criticism_and_privacy_concerns" ' +
			      'rel="nofollow">DISQUS</a> on Wikipedia.');

    $('#disqus_thread a').tooltip ();

    $('#disqus_thread a').on ('click', function () {
	$('#disqus_thread').html ('');

	var pfx = '//' + disqus_shortname + '.disqus.com/' ;
	$.getScript (pfx + 'count.js');
	$.getScript (pfx + 'embed.js');
    });
});
/* End */

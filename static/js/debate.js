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

// All these variables are needed at global level
var disqus_shortname, disqus_identifier ;
var idcomments_acct, idcomments_post_id,
    idcomments_post_url, idcomments_post_title;

// Pull in with JQuery
$(document).ready (function () {

    // get info texts and enable() method
    var w = (function (name) {
	switch (name) {
	case "disqus":
	    return {
		name: "DISQUS",
		info: ('en.wikipedia.org/wiki/Disqus' +
		       '#Criticism_and_privacy_concerns'),
		enable: function () {
		    disqus_shortname = debate_forum_id ;
		    disqus_identifier = debate_post_id ;
		    $('#debate-sink').attr ('id', 'disqus_thread');
		    var pfx = '//' + debate_forum_id + '.disqus.com/' ;
		    $.getScript (pfx + 'count.js');
		    $.getScript (pfx + 'embed.js');
		}
	    };

	case "intensedebate":
	    return {
		name: "IntenseDebate",
		info: "//en.wikipedia.org/wiki/IntenseDebate",
		enable: function () {
		    idcomments_acct = debate_forum_id ;
		    idcomments_post_id = debate_post_id ;
		    $('#debate-sink')
			.html ('<span id="IDCommentsPostTitle"></span>');
		    function tag_edit (val) {
			var u = ('//www.intensedebate.com/js/generic' +
				 val + 'WrapperV2.js');
			$('#IDCommentsPostTitle')
			    .after ('<script src="' + u + '"></script>');
		    }
		    tag_edit ('Link');
		    tag_edit ('Comment');
		}
	    };

	default:
	    return null;
	};
    }) (debate_provider);

    // apply
    if (w) {
	var tooltip = ('"Import external discussion list from ' + w.name +
	               ' where you can comment on this post. This might ' +
		       'also enable analytics functionality, e.g. from ' +
		       'Google."');

	var button  = ('<a class="btn btn-default" data-toggle="tooltip" ' +
	               'data-placement="top" title=' + tooltip + '><img ' +
                       'src=/img/chat.png alt="' + w.name + '"></a>');

	$('#debate-sink')
	    .html ('Activate debate and discussion' + button +
		   ', see <a href="' + w.info + '" rel="nofollow">' +
		   w.name + '</a> for more information.');

	$('#debate-sink a.btn')
	    .on ('click', function () {
		$('#debate-sink').html ('');
		w.enable ();
	    })
	    .tooltip ();
    }
});
/* End */

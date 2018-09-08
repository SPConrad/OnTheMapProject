$(document).ready(function(){

    if ($.fancybox != undefined) { $(".fancybox").fancybox(); }
    var lng = $('#box_lang').find('li.active').attr('id');
    document.lng = lng;

    $.fn.equalHeights = function () {
        var maxHeight = 0, $this = $(this);

        $this.each(function () {
            var height = $(this).innerHeight();

            if (height > maxHeight) { maxHeight = height; }
        });

        //return $this.css('height', maxHeight);
        return $this.innerHeight(maxHeight);
    };

    var navTopLi = $('#nav_top').children('li');
    navTopLi.click(function (ev) {
        var $this = $(this);
        if ($this.children('a').length === 0) {
            // didn't contain an anchor, so show corresponding box

            var clickedOnActive = $this.hasClass('active');
            // deactivated all
            navTopLi.removeClass('active');
            $('#top_boxes').children('div').hide();

            if (!clickedOnActive) {
                $this.addClass('active');

                var id = $this.attr('id').replace('nav_', 'box_');
                $('#' + id).show().find('input').focus();
            }
            return false;
        }
        return true;
    });

    // **** switching of language ****
    var boxLangLi = $('#box_lang').find('li');
    boxLangLi.click(function() {
        var lngClk = $(this);
        if (!lngClk.hasClass('active')) {
            boxLangLi.removeClass('active');
            lngClk.addClass('active');

            // eliminate protocol and hostname with optional port number
            // remove until 3rd slash (2 slashes after protocol, 1 slash after host(and :port)
            var keepIt = document.URL.replace(/^.*\/\/[^\/]*\//, '');
            // are there 2 characters (language id) before the next slash ?
            if (keepIt.indexOf('/') === 2 || keepIt.length === 2) {
                keepIt = keepIt.substr(2);
                //console.log('addr=' + '/' + lngClk.attr('id') + keepIt);
                if (keepIt.length !== document.URL.length) {
                    location.href = '/' + lngClk.attr('id') + keepIt;
                }
            } else if ($('#YafHead').length) {
                // we are in the forum
                //console.log('inside forum lang switched from', lng, 'to', lngClk.attr('id'));
                lng = lngClk.attr('id');

                $.ajax({
                    url: '/community/vsl.aspx?g=setLanguage&lang=' + lng
                })
			    .done(function(data) { location.reload(); })
				.fail(function(data) { alert('An error occured trying to change the language. Please try again.'); });
            }
        }
    });

    // **** handle click on REMEMBER ME ****
    var rememberImg = $('#img_rem');
    rememberImg.add('#txt_rem').click(function () {
        var stateOff = (rememberImg.attr('src') === '/css/images/CheckboxOff_bright_i.png');
        rememberImg.attr('src', '/css/images/CheckboxO' + ((stateOff) ? 'n' : 'ff') + '_bright_i.png');
        $('#RememberMe').attr('value', (stateOff) ? 1 : 0);
    });

    var navBasket = $('#nav_basket');
    var boxBasket = $('#box_basket');
    var initialBasketContent = '<div><hr style="margin-top:30px;"><div class="gotobasket"><a href=""><span>My</span>BASKET</a></div></div>';
    var basketContent = '';
    var basketTimer = undefined;
    // same hover in / out function for nav_basket and basket layer
    navBasket.add(boxBasket).hover(function () {
        //console.log('enter', this);
        if (basketTimer) {
            clearTimeout(basketTimer);
            basketTimer = undefined;
        }
        if (!basketContent.length) {
            boxBasket.html(initialBasketContent);
            basketContent = initialBasketContent;
        }
        if (this.id === 'nav_basket') {
            ajaxCall('/basket/' + lng, function (result) {
                basketContent = result;
                boxBasket.html(result);
                if (result.indexOf('class="basketlist"') === -1) {
                    navBasket.removeClass('full');
                } else {
                    navBasket.addClass('full');
                }
            });
        }
        boxBasket.show();
        navBasket.addClass('active');
    }, function () {
        //console.log('leave', this);
        boxBasket.hide();
        navBasket.removeClass('active');
        basketTimer = setTimeout(function () { basketContent = ''; }, 500);
    });

    /***** expand-reduce debugtable */
    $('table.debugtable caption').click(function() {
        var $this = $(this);
        var tbl = $this.parent();
        var tbd = $this.next('tbody');
        tbl.css({clear:(tbl.css('clear')=='none')?'left':'none'});
        tbd.css({display:(tbd.css('display')=='none')?'block':'none'});
    });

    /***** update height of side-layer to be sum of the heights of #top + #nav_frag + #fragment + #content */
//    function updateSideHeight() {
//        var heightSum = 0;
//        $('#top, #nav_frag, #fragment, #content').each(function () {
//            heightSum += $(this).innerHeight();
//        });
//        var side = $('#side');
//        side.css('height', '');
//        var curHeight = side.height();
//        side.css('height', (heightSum > curHeight) ? heightSum : curHeight);
//    }

    var music = $('#music');

    /**************************************************************
	 * AJAX call with URL, optional success function, optional POST data */
    function ajaxCall(theURL, successFct, theData, errorFct) {
        $.ajax({
            type: 'POST',
            url: theURL,
            data: (theData) ? theData : '',
            beforeSend: progressCursor,
            success: function (result) {
                if (successFct != undefined) {
                    successFct(result);
                }
            },
            complete: function () {
                // if on music area; then add class active to the .add fields in the content area
                if (music.length) {
                    $('#content').find('.tracktbl .add').addClass('active');
                }
                activatePlayButtons();
                defaultCursor();
            },
            error: function (xhr, textStatus, error) {
                ajaxError(xhr, textStatus, error);
                if (errorFct != undefined) {
                    errorFct(xhr, textStatus, error);
                }
            }
        });
    }
    document.ajaxCall = ajaxCall;

    /**************************************************************
	 * AJAX call with URL, optional POST data, optional final callback,
	 *
	 * This AJAX call POSTs data to the specified URL.
	 * It is assumed that the data have usual form data format,
	 * so the server side can interpret it like a normal FORM submit.
	 * The response from the server is a JSON object specifying the target and containing 
	 * { "target" : <"fancy" or css-selector to address target> , "data" : <HTML form to handle conversation> }
	 * Conversation ends (fancy box closes and finalCB is called) when:
	 * - the returned data are empty or
	 * - the form is submitted and contains an empty action attribute or
	 * - the form contains an element with the CSS class 'cancel' on which was clicked.
	 * In all other cases the form data are posted to the action URL and
	 * the returned JSON response is interpreted as before (continued conversation).
	 */
    var avoidConcurrentJsonResponseAjaxCall = false;
    function jsonResponseAjaxCall(theURL, theData, finalCB) {
        if (!avoidConcurrentJsonResponseAjaxCall) {
            avoidConcurrentJsonResponseAjaxCall = true;
            $.ajax({
                type: 'POST',
                url: theURL,
                data: (theData) ? theData : '',
                beforeSend: progressCursor,
                success: function (result) {
                    // close probably open fancy box
                    $.fancybox.close();

                    if ("string" !== typeof result) {
                        if ('fancy' === result.target) {
                            if (result.data && result.data.length) {
                                // show fancybox (or replace fancybox content)
                                var fbdata = $('<div id="fancy_vsl"></div>').append(result.data);
                                $.fancybox({ modal: (result.closeBtn === undefined), minWidth: 40, minHeight: 40, content: fbdata, closeBtn: (result.closeBtn !== undefined) });
                                var form = $('#fancy_vsl').find('form');
                                form.submit(function (ev) {
                                    //console.log("Handler for submit of AJAX returned FORM called.", $(this).serialize());
                                    var act = form.attr('action');
                                    if (act.length) {
                                        jsonResponseAjaxCall(act, $(this).serialize(), finalCB);
                                    } else {
                                        // close fancy box because no action for post to server
                                        $.fancybox.close();
                                        if (finalCB !== undefined) {
                                            // no or empty result data received; call final action if any
                                            finalCB(false);
                                        }
                                    }
                                    return false;
                                });
                                form.find('.cancel').click(function (ev) {
                                    // close fancy box because no post to server
                                    $.fancybox.close();
                                    if (finalCB !== undefined) {
                                        // no or empty result data received; call final action if any
                                        finalCB(true);
                                    }
                                    return false;
                                });
                            } else if (finalCB !== undefined) {
                                // no or empty result data received; call final action if any
                                finalCB(false, result.data);
                            }
                        } else if (result.target !== undefined) {
                            // result targeted to different part then fancybox
                            // use target as jquery selector and put data there
                            $(result.target).html(result.data);
                            if (finalCB !== undefined) {
                                // no or empty result data received; call final action if any
                                finalCB(false, result.data);
                            }
                        }
                    } else {
                        if (finalCB !== undefined) {
                            // data received as non JSON object(string); call final action if any
                            finalCB(false, result);
                        }
                    }
                },
                complete: function () { defaultCursor(); avoidConcurrentJsonResponseAjaxCall = false; },
                error: ajaxError
            });
        } else {
            console.log('AJAX call to "', theURL, '" ignored due to already pending call');
        }
    }
    //pin method to document; used in PriceBox.cshtml
    document.jsonResponseAjaxCall = jsonResponseAjaxCall;

    function ajaxError(xhr, textStatus, error) {
        console.log('ajaxError:', 'xhr.statusText=', xhr.statusText, 'textStatus=', textStatus, 'error=', error);
    }

    /**************************************************************
	 * Fragment Navigation */
    var fragNav = $('#nav_frag');
    // check for address plugin;  FORUM didn't include it
    if ($.address) {
        $.address.change(function (event) {
            //console.log('value=' + event.value + ' path=' + event.path + ' pathNames=' + event.pathNames);

            if (document.URL.indexOf('_escaped_fragment_') !== -1) {
                // ignore Google Crawler
                return;
            }

            if (fragNav.length) {
                var theAs = fragNav.find('a');
                if (theAs.length) {
                    var frag = theAs.filter(function () {
                            return $(this).hasClass('active');
                        });
                    if (!frag.length) {
                        frag = $(theAs[0]);
                    }
                    var hash = frag.attr('href').replace('#!', '');
                    // plugin returns '/' if no hash-bang is contained else '/!' and hash-bang
                    if (event.value.length > 1) {
                        // escaped fragment found
                        hash = event.value.replace('/!', '');
                        frag = theAs.filter(function () {
                            return $(this).attr('href').toLowerCase() === '#!' + hash.toLowerCase();
                        });
                    } else if (frag.hasClass('active')) {
                        return;
                    }

                    if (frag.length) {
                        document.FragmentTriggered = true;
                        ajaxCall('/fragnav/' + lng + '/' + frag.parent().attr('id'), function (result) {
                            var frgmt = $('#fragment');
                            frgmt.html(result);
                            //updateSideHeight();
                            glossarHandler(frgmt);
                        });

                        theAs.removeClass('active');
                        frag.addClass('active');

                        // on all anchors in the #top area add or update the hash-bang value;
                        // keeps the addressed fragment when switching from one page to the other when having a fragment with the same hash-bang
                        $('#top').find('a').attr('href', function (i, ref) { return (ref != undefined) ? ref.split('#!')[0] + '#!' + hash : undefined });
                    }
                }
            }
        });
    }

    /**************************************************************
	 * Music */

    // if on music area; then add class active to the .add fields in the content area
    if (music.length > 0) {
        $('#content').find('.tracktbl .add').addClass('active');
    }

    var musicDetailNavs = '.music_detail .nav li';

    function showActiveMusicDetail() {
        music.find('.music_detail .uline.layered').children('div').addClass('hidden');
        var activeNav = music.find(musicDetailNavs).filter('.active');
        if (activeNav.length) {
            // the layer to be made visible has as classname the name of the ID clicked on
            $('.' + activeNav.attr('data')).removeClass('hidden');
        }
    }

    function addMusicDetailListeners(root) {
        // Music Details close:
        var musicDetail = $('.music_detail',root);
        musicDetail.find('.back').click(function (ev) {
            loadMusicListBack();
        });

        // Music Details layer navigation: description, instruments, tutorials, etc.
        var mBoxNavLis = music.find(musicDetailNavs);
        mBoxNavLis.click(function (ev) {
            mBoxNavLis.removeClass('active');
            $(ev.currentTarget).addClass('active');
            showActiveMusicDetail();
            adjustMusicHeight();
        });

        showActiveMusicDetail();
    }
    // call below is required if we start with a detail (target of "Copy Link" functionality)
    addMusicDetailListeners(music);

    var hideme = $('#hideme');

    function adjustMusicHeight() {
        var musicHideMeHeight = hideme.height();
        if (musicHideMeHeight) {
            var height2Set = musicHideMeHeight + 30;  // 30px for audio controls
            music.height(height2Set);
        }
    }

    var musicCharSpan = $('#music_char').find('span.busy');
    musicCharSpan.click(function (ev) {
        var tgt = $(this);
        musicCharSpan.removeClass('active');
        tgt.addClass('active');

        loadMusicBrowseResultWithLetter(tgt.html());
    });

    var suggestLayer = $('#suggest');
    var mSearch = $('#music_search');
    var mPattern = $('#music_pattern');

    mPattern.keyup(function (ev) {
        var term = $(this).val().trim();
        var key = ev.which;
        if (term.length > 2) {
            //console.log('show suggestion', term);
            if (key == 13) {
                //console.log('keypressed=' + key);
                suggestLayer.hide();
                $('html').off('keyup',escHit);
                enterHit();
            } else {
                ajaxCall('/musicBrSel/' + lng, function (result) {
                    if (result.trim().length > 0) {
                        $('html').keyup(escHit);
                        suggestLayer.show();
                        suggestLayer.html(result);
                        $('.suggestion').click(showDemo);
                    }
                }, { lang: lng, term: term });
            }
        } else {
            suggestLayer.hide();
            $('html').off('keyup', escHit);

            if (term.length === 0 && key == 13) { enterHit(); }
        }
    });

    function escHit(ev) {
        if (ev.which == 27) {
            suggestLayer.hide();
            $('html').off('keyup', escHit);
        }
    }
    function enterHit() {
        musicCharSpan.removeClass('active');
        // reset all combo boxes to value 0
        resetAllMusicSelections();
        loadMusicBrowseResult(mPattern.val());
    }

    function showDemo() {
        var $this = $(this);
        var tid = $this.attr('id').replace('t', '');
        var tt = $this.html();
        //console.log('elem=' + tt + ' ' + tid);

        loadMusicDetails($this.attr('data'), hideme);

        mSearch.find('input').val(tt);
        suggestLayer.hide();

        verticalSep4MusicSearchResult();
    }

    var allMusicSelections = mSearch.find('select');
    allMusicSelections.on('change', function (ev) {
        mPattern.val('');
        allMusicSelections.each(function (idx, elem) {
            // on selection change of music search we reset all others combo boxes
            if (elem != ev.target) {
                $(elem).val('0').attr('selected', 'selected');
            }
        });
        loadMusicBrowseResult('');
    });

    function resetAllMusicSelections() {
        // reset all combo boxes to value 0
        allMusicSelections.val('0').attr('selected', 'selected');
    }

    verticalSep4MusicSearchResult();

    function progressCursor() {
        $('html').addClass('progress');
    }

    function defaultCursor() {
        $('html').removeClass('progress');
    }

    /*
	 * loads music details from demoId together with language
	 */
    function loadMusicDetails(tgtData, tgtElem, afterReplace, optPostData) {
        //console.log('loadMusicDetails: tgtData=', tgtData, 'tgtElem=',tgtElem);

        // language and demoId
        ajaxCall('/music/' + lng + '/' + tgtData.split('/')[0], function (result) {
            $(tgtElem).html(result);
            if (afterReplace != undefined) {
                afterReplace($(tgtElem));
            }
            addMusicDetailListeners($(tgtElem));

            if (music.length) {
                // in music area so adjust height
                adjustMusicHeight();
            }
            if (insideExtPlayer) {
                $(window).resize();
            }
        }, optPostData);
    }

    /*
	 * loads music module playlist back 
	 * together with language and playlistId
	 */
    function loadMusicListBack() {
        // language and playListId
        ajaxCall('/musicBack/' + lng, function (result) {
            hideme.html(result);
            adjustMusicHeight();

            activatePlayButtons();
        }, { 'playListId': $('#defaultPlaylistId').val() });
    }

    function loadMusicBrowseResultWithLetter(startLetter) {
        mPattern.val('');
        resetAllMusicSelections();

        ajaxCall('/musicLetter/' + lng, function (result) {
            $('.music_result').html(result);

            verticalSep4MusicSearchResult();
        }, { 'startLetter': startLetter });
    }

    var productsSelection = $('#products');
    var composersSelection = $('#composers');
    var programmingSelection = $('#programming');
    var styleSelection = $('#style');

    function loadMusicBrowseResult(search) {
        var product = 0;
        var composer = 0;
        var arranger = 0;
        var category = 0;

        if (search.length == 0) {
            product = productsSelection.find(':selected').val();
            composer = composersSelection.find(':selected').val();
            arranger = programmingSelection.find(':selected').val();
            category = styleSelection.find(':selected').val();
        }
        //console.log(search, product, composer, arranger, category);
        ajaxCall('/musicResult/' + lng, function (result) {
            musicCharSpan.removeClass('active');
            $('.music_result').html(result);

            verticalSep4MusicSearchResult();
        }, { 'search': search, 'product': product, 'composer': composer, 'arranger': arranger, 'category': category });
    }

    function verticalSep4MusicSearchResult() {
        var mCols = $('.music_col');
        if ((mCols.length > 2) && ($(mCols[2]).children().length > 0)) {
            // right column isn't empty; equalheights on all
            mCols.equalHeights();
        } else if ((mCols.length > 1) && ($(mCols[1]).children().length > 0)) {
            // middle column isn't empty; therefore use equalheights not on the right one
            mCols.filter(function (idx, elem) {
                return (idx !== mCols.length - 1);
            }).equalHeights();
        }
    }

    /**************************************************************
	 * Player */
    var initialVolume = 0.7;
    var playerDiv = $('#player');

    var insideExtPlayer = $('#extplayer').length;
    if (!insideExtPlayer) {
        playerDiv.hide();
    }

    // data = media path starting with numeric ID (demo ID)
    // target = the DOM ELEMENT (e.g.DIV) to which the media HTML5 tag (audio or video) should be added
    function playVslPlayer(target, data, title, startedInPlaylist, currentTime, onMetadataloaded, considerCuePoints, newVolume, optMediaTagEnhancement) {
        if (currentTime) {
            // cue_point click for already playing video ?
            var isSameMediaPlaying = target.find('.mejs-controls[data="' + data + '"]').length;

            //console.log('cue Time', currentTime, 'isSameMediaPlaying', isSameMediaPlaying);
            if (isSameMediaPlaying) {
                var video = target.find('video');
                if (video.length) {
                    target.vslMediaElementPlayerRef.setCurrentTime(currentTime);
                    return;
                }
            }
        }

        removeVslPlayer(target);

        if (newVolume != undefined) {
            initialVolume = newVolume;
        }

        // ignore demo(media) ID (part before slash) if URL didn't start with slash
        var mediaId = data.split('/');
        if (mediaId.length && mediaId[0].length) {
            var fileName = data.substr(mediaId[0].length);
        }

        // type is part after first slash
        var type = mediaId[1];
        var widthToUse = (target.closest('div.video').length) ? target.parent().parent().parent().css('width').replace('px','') : 720; // 3rd parent is the layout element
        var insideFancy = target.closest('.fancybox-inner').length;
        var setAutoplay = navigator.vendor.toLowerCase().indexOf('opera') != -1; // Opera
        setAutoplay |= ((!(window.mozInnerScreenX == null)) && navigator.platform.indexOf('Mac') != -1); // FF on Mac
        target.html('<' + type + ' src="' + fileName + '" id="vslplayer' + mediaId[0] + (insideFancy ? '' : (($('#extplayer').length) ? '" width="588' : '" width="' + widthToUse)) + (setAutoplay ? '" autoplay="true' : '') + '"' + (optMediaTagEnhancement ? optMediaTagEnhancement : '') + '></' + type + '>');
        var thePlayer = initPlayer('#vslplayer' + mediaId[0], startedInPlaylist, currentTime, removeVslPlayer, onMetadataloaded, insideFancy, data.replace('.mp4', '').replace(/^.*_[0-9]+x/, ''), considerCuePoints);
        // store the track data which will be played; needed to restore active play button after AJAX switching
        var meCtrl = target.find('.mejs-controls');
        meCtrl.attr('title', title).attr('data', data);
        // hook the ME Object to the .mejs-controls control for later use (removeVslPlayer,etc.)
        target.vslMediaElementPlayerRef = thePlayer;
        target.show();

        if (optMediaTagEnhancement && (optMediaTagEnhancement.indexOf('muted') != -1)) {
            meCtrl.css('z-index', '-1');
            var unmute = target.siblings('.unmute');
            unmute.show();
            // blink unmute image
            setTimeout(function () { changeMuted(unmute, 8); }, 1000);
        }

        // uncomment if cue-point shouldn't start immediately
        // if (currentTime === undefined) {
        thePlayer.play();
        // }
    }

    function changeMuted(unmute, repcount) {
        unmute.toggleClass('light');
        if (repcount-- > 0) {
            setTimeout(function () { changeMuted(unmute, repcount); }, 1000);
        } else {
            unmute.addClass('light');
        }
    }

    /*
	* vslPlayer is either the MediaElementPlayer object or the surrounding DOM element
	* containing the HTML media tag (audio or video) which is enveloped by
	* the MediaElementPlayer's .mejs-container is (should be) added
	*/
    function removeVslPlayer(vslPlayer) {
        var surroundLayer = vslPlayer;
        //console.log('removeVslPlayer-1',vslPlayer);

        if (vslPlayer) {
            // if the passed object isn't the MediaElementPlayer try to find it
            if (!vslPlayer.container && !vslPlayer.pluginElement) {
                vslPlayer = (surroundLayer.vslMediaElementPlayerRef) ? surroundLayer.vslMediaElementPlayerRef : vslPlayer;
            } else {
                if (vslPlayer.container) {
                    surroundLayer = $(vslPlayer.container[0].parentNode);
                } else {
                    surroundLayer = $(vslPlayer.pluginElement).closest('.me_container');
                    if (!surroundLayer.length) {
                        surroundLayer = $('.me_container');
                    }
                }
            }
        }

        //console.log('EQUAL', vslPlayer === surroundLayer,'removeVslPlayer-2', 'vslPlayer', vslPlayer, 'surroundLayer', surroundLayer);
        if (vslPlayer && (vslPlayer.container || vslPlayer.pluginElement)) {
            if (vslPlayer.pluginType != 'flash') {
                initialVolume = vslPlayer.getVolume();
            }
            var mediaTag = surroundLayer.find('video, audio');
            // pause the player before remove (don't know why this (pause) was done by Electric Arts)
            mediaTag.each(function () {
                if (this.player && this.player.pause) {
                    this.player.pause();
                }
            });

            mediaTag.remove();
            vslPlayer.remove();
            // due to bug in MediaElementsPlayer (on remove of the player, it adds the audio tag again)
            // so after the remove call we have a doubled audio tag,
            // we need to query again for the audio tags to remove both
            mediaTag = surroundLayer.find('video, audio');
            mediaTag.remove();

            // mediaTag.remove();
            surroundLayer.vslMediaElementPlayerRef = undefined;

            if (surroundLayer) {
                surroundLayer.css({ 'vertical-align': '', 'height': '' });
                surroundLayer.hide();
            }
        }

        // remove inline height of video module
        $(surroundLayer).closest('div.video').css('height', '');
        $(surroundLayer).siblings('.unmute').hide();

        adjustMusicHeight();

        $('#emb').css('height', '');

        // deactivate all active play Items
        deactivatePlayButtons();
    }

    function initPlayer(mediaTagId, startedInPlaylist, currentTime, removePlayerFct, onMetadataloaded, insideFancy, vidHeight, considerCuePoints) {
        var videoMod = $(mediaTagId).closest('div.video');
        var insideVideoMod = videoMod.length;
        var vidH = (insideVideoMod) ? 123 : ($.isNumeric(vidHeight) ? Math.min(parseInt(vidHeight), 405) : 405);
        var vidW = (insideVideoMod) ? $(mediaTagId).attr('width') : 720; // inside video module

        var vslPlayer = new MediaElementPlayer(mediaTagId, {
            plugins: ['flash', 'silverlight'],
            features: (insideFancy) ? ['stop', 'playpause', 'current', 'progress', 'duration', 'tracks', 'volume', 'fullscreen']
                                    : ['stop', 'playpause', 'current', 'progress', 'duration', 'tracks', 'volume'],
            type: '',
            pluginPath: '/scripts/mediaelement.2.20.1/',
            flashName: 'flashmediaelement.swf',
            silverlightName: 'silverlightmediaelement.xap',
            defaultVideoWidth: vidW,
            defaultVideoHeight: vidH,
            videoWidth: (insideFancy) ? window.innerWidth : vidW,
            videoHeight: (insideFancy) ? window.innerHeight : vidH,
            audioWidth: (insideExtPlayer) ? 628 : 720,
            audioHeight: 30,
            alwaysShowControls: false,
            enableAutosize: true,
            success: function (mediaElement, domObject, player) {
                mediaElement.addEventListener('loadedmetadata', function (e) {
                    var mediaTag = $(this);

                    if (!stopHookAdded) {
                        addMEStopHandler(mediaElement, removePlayerFct);
                    }
                    var isFlash = mediaElement.pluginType === 'flash';
                    if (this.tagName === 'VIDEO' || (isFlash && mediaElement.tagName != 'AUDIO')) {
                        if (currentTime) {
                            mediaElement.setCurrentTime(currentTime);
                        }

                        var playerHeight = (isFlash && !insideFancy) ? player.options.defaultVideoHeight : (mediaElement.videoHeight) ? mediaElement.videoHeight : mediaTag.height();
                        var playerWidth = (isFlash && !insideFancy) ? player.options.defaultVideoWidth : (mediaElement.videoWidth) ? mediaElement.videoWidth : mediaTag.width();
                        // for video in EmbNav or VideoModule scale width of video if it is wider than 720 or grid
                        var scale = (!isFlash && !insideFancy && mediaElement.videoWidth) ? Math.min(1, vidW / mediaElement.videoWidth) : 1;
                        if (scale < 1.0) {
                            playerWidth = (insideVideoMod) ? vidW : Math.ceil(scale * playerWidth);
                            playerHeight = (insideVideoMod) ? Math.floor(scale * playerHeight) : Math.ceil(scale * playerHeight);
                        } else if (insideVideoMod) {
                            // update width on the VIDEO tag because video is smaller than the grid
                            videoMod.find('video').attr('width', playerWidth);
                        }
                        var surroundLayer = mediaTag.closest('.mejs-container').parent();
                        if (insideFancy) {
                            // consider possible too high or too width video
                            // use body width
                            var width2Check = window.innerWidth - 17; // 17 for the scrollbar - width
                            if (considerCuePoints) {
                                width2Check -= 45;
                            }
                            var maxUseablePlayerHeight = Math.min(window.innerHeight, playerHeight);
                            var maxUseablePlayerWidth = Math.min(width2Check, playerWidth);

                            var zoomWidth = maxUseablePlayerWidth / playerWidth;
                            var zoomHeight = maxUseablePlayerHeight / playerHeight;
                            var zoom = Math.min(zoomWidth, zoomHeight);
                            if (zoom < 1.0) {
                                playerWidth = Math.ceil(zoom * playerWidth);
                                playerHeight = Math.ceil(zoom * playerHeight);
                                if (zoomWidth < zoomHeight) {
                                    mediaTag.width(playerWidth);
                                } else {
                                    mediaTag.height(playerHeight);
                                }
                            }
                        } else if (insideVideoMod) {
                            var imgHeight = videoMod.find('.me_container').data('imgh');
                            if (playerHeight > imgHeight) {
                                videoMod.css('height', playerHeight);
                            }
                        } else {
                            // in Embedded Navigation use at least the parent height
                            var emb = $('#emb');
                            if (emb.length) {
                                var playerDivParentHeight = surroundLayer.parent().innerHeight();
                                playerHeight = (playerHeight > playerDivParentHeight) ? playerHeight : playerDivParentHeight;
                                emb.height(playerHeight);
                            } else {
                                // use case e.g. #music #player
                                // enlarge #music if necessary
                                if (playerHeight > music.height()) {
                                    music.height(playerHeight);
                                }
                                // video positioned on top of music (visible in case of high amount of masterpieces
                                surroundLayer.css('vertical-align', 'top');
                            }
                        }
                        //console.log('initPlayer: playerWidth', playerWidth, 'playerHeight', playerHeight);
                        player.setPlayerSize(playerWidth, playerHeight);
                        player.setControlsSize();
                        if (!insideFancy) {
                            mediaElement.addEventListener('ended', function () {
                                // video ended;
                                removePlayerFct(vslPlayer);
                            });
                        }
                    } else if (startedInPlaylist) {
                        mediaElement.addEventListener('ended', function () {
                            // in playlist started audio ended;
                            //console.log('audio ended in playlist');

                            var track = mediaTag.closest('.mejs-mediaelement').siblings('.mejs-controls').attr('data');
                            var tracks = (insideExtPlayer) ? $('#player_playlist').find('.play') : $('#playlist').children('.audio').children('.play');
                            var newtrack = tracks[0];
                            removePlayerFct(vslPlayer);
                            tracks.each(function (idx) {
                                if (getAssociatedData($(this)) === track) {
                                    newtrack = (idx === tracks.length - 1) ? tracks[0] : tracks[idx + 1];
                                    return false;
                                }
                            });
                            // play next or first track
                            setTimeout(function () { $(newtrack).trigger('click'); }, 500);
                        });
                    }
                    player.setVolume(initialVolume);
                    if (onMetadataloaded) {
                        onMetadataloaded();
                    }
                });
            }
        });
        //console.log('initPlayer', vslPlayer, vslPlayer.container[0].parentNode);

        if ($(mediaTagId).length && $(mediaTagId)[0].tagName === 'VIDEO') {
            // case video therefore hide controls
            vslPlayer.hideControls();
        }

        var stopHookAdded = addMEStopHandler(vslPlayer, removePlayerFct);

        return vslPlayer;
    }

    function addMEStopHandler(me, removePlayerFct) {
        var stopbutton = undefined;
        if (me.container) {
            stopbutton = me.container.find('.mejs-stop');
        } else {
            // case flash
            var pE = $(me.pluginElement);
            stopbutton = pE.closest('.me_container').find('.mejs-stop');
            if (!stopbutton.length) {
                stopbutton = $('.me_container').find('.mejs-stop');
            }
        }

        stopbutton.click(function () {
            removePlayerFct(me);
        });
        return stopbutton.length;
    }

    adjustMusicHeight();


    /**************************************************************
	* academy - instrumentology - playing techniques - play samples with native HTML5 audio
	*/
    $('#techniques').find('.smpl').click(function (ev) {
        var tgt = $(ev.target);
        var audio = tgt.find('audio');
        if (audio.length) {
            var aud = audio[0];
            // avoid activating an audio already playing (ended check for safari)
            if (aud.paused === true || aud.ended === true) {
                tgt.addClass('active');
                $(aud).on('ended', function (ev) {
                    var tgt = $(ev.target);
                    // sample ended;
                    tgt.closest('.smpl').removeClass('active');
                    tgt.off('ended');
                });
                aud.play();
            }
        }
    });


    /**************************************************************
	* get associated data.
	* checks if clicked item has a 'data' attribute.
	* If not then check if parent has a 'data' attribute.
	* If not then check if closest <tr> has a 'data' attribute.
	* If not then check if closest 'music_detail' has a 'data' attribute.
	*/
    function getAssociatedData(tgt) {
        // a.) check if clicked target has a 'data' attribute (use case play list)
        var data = (tgt) ? tgt.attr('data') : null;
        if (data) {
            tgt.title = tgt.html();
        }

        if (!data) {
            // b.)  check if clicked target's parent
            //		has a 'data' attribute (use case demo list)
            var par = (tgt) ? tgt.parent() : null;
            data = (par) ? par.attr('data') : null;
            if (data) {
                tgt.title = par.children('.title').html();
            }
        }

        if (!data) {
            // c.)  check if clicked target is contained in <tr> which
            //		has a 'data' attribute (use case demo list)
            var tr = (tgt) ? tgt.closest('tr') : null;
            data = (tr) ? tr.attr('data') : null;
            if (data) {
                tgt.title = tr.children('.title').html();
            }
        }

        if (!data) {
            // d.)  check if clicked target is contained in .music_detail 
            //		 which has a 'data' attribute (use case play via .music_details .title)
            var tr = (tgt) ? tgt.closest('.music_detail') : null;
            data = (tr) ? tr.attr('data') : null;
            if (data) {
                tgt.title = tr.find('.title').html();
            }
        }
        return data;
    }


    // =============================
    // activate all play buttons in the different areas according to the playing track
    // =============================
    function activatePlayButtons(tgt) {
        var playingTrackData = getAssociatedData(playerDiv.find('.mejs-controls'));
        //console.log('activatePlayButtons: playingTrackData=', playingTrackData);
        if (playingTrackData != undefined) {
            // restore active class on button for playing track
            var dataSel = '[data="' + playingTrackData + '"]';
            var playingTrackSel = 'tr' + dataSel + '>td.play';
            var allPlay = $('.play' + dataSel, '#side').add(playingTrackSel, '#top').add('.music_detail' + dataSel + ' .play', music)
					.add(playingTrackSel, '#content').add(playingTrackSel, '#fragment').add(playingTrackSel, '#extplayer');
            allPlay.addClass('active').each(function (idx, elem) {
                var pnt = $(elem).parent();
                if (pnt[0].tagName === 'TR') {
                    // to have colored row background for playing track
                    pnt.addClass('active');
                    if (tgt) {
                        // for external player
                        tgt.closest('#player_playlist').find('#playlist_start').addClass('active');
                    }
                }
            });
        }
    }

    // =============================
    // deactivate all play buttons in the different areas
    // =============================
    function deactivatePlayButtons() {
        // restore active class on button for playing track
        var playingTrackSel = 'tr>td.play';
        var allPlay = $('.play', '#side').add(playingTrackSel, '#top').add('.music_detail .play', music)
				.add(playingTrackSel, '#content').add(playingTrackSel, '#fragment').add(playingTrackSel, '#extplayer').add('#playlist_start', '#extplayer');
        allPlay.removeClass('active').each(function (idx, elem) {
            var pnt = $(elem).parent();
            if (pnt[0].tagName === 'TR') {
                // to have colored row background for playing track
                pnt.removeClass('active');
            }
        });
    }

    function distributeBasketHeadItems() {
        var formHeadDiv = $('.basket .head');
        for (var k = formHeadDiv.length - 1; k >= 0; k--) {
            var formHead = $('ul>li', formHeadDiv[k]);
            var reqWidth = 0;
            for (var i = 0, j = formHead.length; i < j; i++) {
                var listItem = formHead[i];
                if (i == j - 1) {
                    listItem.style.paddingRight = 0;
                }
                reqWidth += listItem.offsetWidth;
            }

            var between = 0;
            if (formHead.length > 1) {
                var ulWidth = formHead[0].parentNode.clientWidth;
                var ulPadding = formHead[0].offsetLeft;
                between = Math.floor(((ulWidth - 2 * ulPadding - reqWidth) + 4) / (formHead.length - 1));
            }

            var leftPos = 0;
            for (var i = 0, j = formHead.length; i < j; i++) {
                var listItem = formHead[i];
                if (i == j - 1) {
                    listItem.style.left = ulWidth - ulPadding - listItem.offsetWidth + 'px';
                } else {
                    listItem.style.left = listItem.offsetLeft + leftPos + 'px';
                }
                leftPos += listItem.offsetWidth + between;
            }
        }
    }
    distributeBasketHeadItems();

    // =============================
    // GTM events
    // =============================
    if (typeof dataLayer !== "undefined") {
        document.vsldataLayer = dataLayer;
    }
    $('#btn_address').click(function (ev) {
            if (typeof dataLayer !== "undefined") {
                dataLayer.push({ 'event': 'gtm.click.startcheckout' });
            }
            return true;
    });

    $('#btn_referral').click(function (ev) {
        if ($('#btn_address').hasClass("referral_vsl")) {
            var route = '/referral/Basket/' + lng;
            jsonResponseAjaxCall(route, null, function (cancelled, stringResult) {
                //$('#btn_address').removeClass("referral_vsl");
            });
            //$('#btn_address').removeClass("referral_vsl");
            return false;
        }
        else
            return false;
    });

    $('#btn_payment').click(function (ev) {
        if (typeof dataLayer !== "undefined") {
            dataLayer.push({ 'event': 'gtm.click.ordersummary' });
        }

        return true;
    });
    //$('#btn_order').click(function (ev) {
    //    if (typeof dataLayer !== "undefined") {
    //        dataLayer.push({ 'event': 'gtm.click.checkout' });
    //    }

    //    return true;
    //});

    // =============================
    // event handler for "Forgot Login" stuff
    // =============================
    $('#btn_forgot_pwd').click(function (ev) {
        var result = true;
        var tgt = $(ev.target);

        // =============================
        // Forgot-Password and Account-Confirmation
        // =============================
        if (tgt.hasClass('btn_forgot_pwd')) {
            result = false;
            var route = tgt[0].dataset.route;
            jsonResponseAjaxCall(route, undefined, function (cancelled, stringResult) {
            });
        }

        return result;
    });

    // =============================
    // event handler on id="all
    // adding the handler here avoids the necessity of adding the eventhandler again when new elements are added to the DOM (e.g. via AJAX)
    // =============================
    $('#all').add('#extplayer').add('#box_profile .agree').click(function (ev) {
        var result = true;
        var tgt = $(ev.target);
        var playOnRowClickEnabled = true;
        //console.log('#all Handler:', tgt, ev);

        // =============================
        // foldable
        // =============================
        if (tgt.hasClass('hotspot_foldable')) {
            result = false;
            var foldable = tgt.closest('.foldable');

            if (tgt[0].tagName === 'H3') {
                // foldable containing h3 and p's
                if (foldable.length) {
                    var para = tgt.siblings(); //all siblings, not only 'p'
                    if (foldable.hasClass('open')) {
                        para.slideUp(200);
                    } else {
                        para.slideDown(200);
                    }
                }
            }

            if (foldable.hasClass('mo_list') && !foldable.hasClass('open') && !foldable.find('.hotspot_detail').length) {
                ajaxCall('/myOrder/' + lng, function (res) {
                    foldable.append(res);
                }, { 'orderID': foldable.find('.mo_id').html() });
            }

            foldable.toggleClass('open');
            //updateSideHeight();
            if (insideExtPlayer) {
                updateSplitter();
            }
        }

        // =============================
        // my playlist : playlist_buttons
        // =============================
        switch (tgt[0].id) {
            case 'playlist_new':
                //console.log('Clicked on:', tgt[0].id);
                result = false;
                if (insideExtPlayer) {
                    var ppl = $('#player_playlist');
                    if (ppl.find('tbody tr').length) {
                        jsonResponseAjaxCall('/ext/playlisActn/' + lng + '/' + tgt[0].id, undefined, function (cancelled, stringResult) {
                            if (!cancelled) {
                                ppl.find('tbody').html('');
                                if (stringResult.length) {
                                    ppl.find('thead tr').attr('data', '0');
                                    ppl.find('#pl_title').html(stringResult);
                                }
                            }
                        });
                    }
                } else {
                    if ($('#playlist').children('ul').children('li').length) {
                        jsonResponseAjaxCall('/playlisActn/' + lng + '/' + tgt[0].id, undefined, function (cancelled, stringResult) {
                            if (!cancelled) {
                                $('#playlist').children('ul').children('li').remove();
                                if (stringResult.length) {
                                    $('#playlist.myplayer').find('.h2').attr('data', '').html(stringResult);
                                }
                            }
                        });
                    }
                }
                break;
            case 'playlist_save':
            case 'playlist_load':
            case 'playlist_saveas':
                result = false;
                var orderedDemoIds = undefined;
                if (insideExtPlayer) {
                    var tmp = '';
                    var tmpVolume = '';
                    $('#player_playlist').find('tbody tr').each(function () {
                        var tmpData = getAssociatedData($(this));
                        if (tmpData) {
                            tmp += ',' + tmpData.split('/')[0];
                            var spnr = $(this).find('.spinner');
                            tmpVolume += ',' + ((spnr) ? spnr.val() : '-3');
                        }
                    });
                    if (tmp.length) {
                        orderedDemoIds = { 'demoids': tmp.substring(1), 'volumes': tmpVolume.substring(1) };
                    }
                }
                jsonResponseAjaxCall((insideExtPlayer ? '/ext' : '') + '/playlisActn/' + lng + '/' + tgt[0].id, orderedDemoIds, function (cancelled, stringResult) {
                    if (!cancelled) {
                        if (tgt[0].id === 'playlist_load') {
                           append2MyPlayList(stringResult);
                        } else {
                            if (!insideExtPlayer) {
                                ajaxCall('/myDemoLists/' + lng, function (result) {
                                    var myPlLists = $('#content h2:not(:first-child)');
                                    myPlLists.nextAll().remove();
                                    myPlLists.parent().append($(result).find('h2').nextAll());
                                });
                            }
                        }
                    }
                });
                break;
            case 'playlist_start':
                result = false;
                var clkdAct = tgt.hasClass('active');
                var trax = tgt.closest('table').find((clkdAct) ? 'td.play.active' : 'td.play');
                if (trax.length) {
                    $(trax[0]).click();
                }
                break;
        }

        // =============================
        // start/stop playing of medium
        // =============================
        if (tgt.hasClass('play')) {
            result = false;
            playOnRowClickEnabled = false;

            var data = getAssociatedData(tgt);
            var clkdActiveItem = tgt.hasClass('active');
            //console.log('clicked on play item', tgt, data, clkdActiveItem);

            var plDiv = playerDiv;
            // check if click is done in video module
            var vidMod = tgt.closest('div.video');
            if (vidMod.length) {
                plDiv = $(vidMod).find('.me_container');
            }

            // deactivate all active play Items
            // this is done by removeVslPlayer() or indirect by playVslPlayer()
            if (clkdActiveItem || data == undefined || data.length === 0) {
                removeVslPlayer(plDiv);
            } else {
                plDiv.show();
                var newVolume = initialVolume;
                var dezibel = tgt.parent().find('.volume .spinner').val();
                if (dezibel) {
                    newVolume = Math.pow(10, dezibel / 10);
                }
                playVslPlayer(plDiv, data, (tgt.length) ? tgt[0].title : tgt.title, tgt.closest('#playlist').length || tgt.closest('#player_playlist').length, undefined, undefined, undefined, newVolume, tgt.hasClass('muted') ? ' muted' : undefined);
                activatePlayButtons(tgt);
            }
        }

        // =============================
        // unmute Video clicked
        // =============================
        if (tgt.hasClass('unmute')) {
            result = false;
            var meCtrl = tgt.siblings('.me_container').find('.mejs-controls');
            meCtrl.css('z-index', '');
            tgt.hide();
            meCtrl.find('.mejs-volume-button button').click();
        }

        // =============================
        // add track to playlist
        // =============================
        if (tgt.hasClass('add')) {
            result = false;
            // either .add.active or .add inside of #music or inside #music_browse or inside .music_detail
            if (tgt.hasClass('active') || tgt.closest('#music').length || tgt.closest('#music_browse').length || tgt.closest('.music_detail').length) {
                var demoId = getAssociatedData(tgt).split('/')[0];
                ajaxCall('/addMyPlay/' + lng + '/' + demoId, function (res) {
                    append2MyPlayList(res);
                }, { 'extPlayer': insideExtPlayer ? "1" : "0", 'volume': insideExtPlayer ? tgt.data('volume') : "3" });
            }
        }

        // =============================
        // delete track from MyPlaylist
        // =============================
        if (tgt.hasClass('del')) {
            result = false;
            var plID = getAssociatedData(tgt);
            var trackID = '0';
            var pos = plID.indexOf('/');
            if (pos > 0) {
                // track clicked
                trackID = plID.substring(0, pos);
                plID = getAssociatedData(tgt.closest('table').find('thead tr'));
            }
            ajaxCall((tgt.closest('#player_playlist').length ? '/ext' : '') + '/playlisActn/' + lng + '/del', function (res) {
                if (res === plID) {
                    // clicked on CAPTION or TH in TR
                    tgt.closest('table').remove();
                } else {
                    // remove parent: the TR
                    tgt.parent().remove();
                    updateTrackCount();
                }
            }, { 'plID': plID, 'trackID': trackID });
        }
        // =============================
        // delete from Basket
        // =============================
        if (tgt.hasClass('delete') && tgt.closest('.basket')) {
            result = false;
            var retPath = '/' + lng + '/MyVSL/MyBasket';
            if (tgt[0].tagName === 'TH') {
                ajaxCall('/clearBasket/' + lng, function (res) {
                    window.location.href = retPath;
                });
            } else {
                ajaxCall('/basketRemove/' + lng + '/' + tgt.parent()[0].id, function (res) {
                    window.location.href = retPath;
                });
            }
        }

        // =============================
        // download
        // =============================
        if (tgt.hasClass('dwl') || tgt.closest('.dwl_tr').length) {
            playOnRowClickEnabled = false;
            var chkSrc = tgt.hasClass('dwl') ? tgt : tgt.closest('.dwl_tr');
            var ancs = chkSrc.find('a');
            if (ancs.length) {
                ancs[0].click();
            }
            //console.log('clicked on DOWNLOAD', getAssociatedData(tgt));
        }

        // =============================
        // play in fancybox
        // =============================
        if (tgt.hasClass('bigplay')) {
            result = false;
            // stop a probably running player in the #player area
            removeVslPlayer(playerDiv);

            playOnRowClickEnabled = false;
            var vidata = getAssociatedData(tgt);
            var theRow = tgt.closest('.hotspot_detail');
            var chapters = theRow.next();

            function bigPlayFancy(chapters) {
                $.fancybox({
                    modal: false, minWidth: 72, minHeight: 30, padding: 0, margin: 0, closeBtn: false,
                    scrolling: 'no',
                    wrapCSS: 'fancy_video',
                    content: '<div class="chapters bigplay"><div class="me_container">Video loading</div></div>',
                    afterShow: function () {
                        var fancyMeContainer = $('.fancybox-inner .me_container');
                        playVslPlayer(fancyMeContainer, vidata, tgt.attr('title'), undefined, undefined, function () {
                            // metadata loaded
                            fancyMeContainer.find('.mejs-stop').click(function () {
                                $.fancybox.close();
                            });
                            if (chapters.length) {
                                fancyMeContainer.css('padding-left', '45px');
                                fancyMeContainer.append(chapters.clone().append('<div class="cl"></div>').addClass('videodemolist'));
                            }
                            $.fancybox.update();
                            $.fancybox.reposition();
                            $('.chapters.bigplay .chapters').children('dl').click(function (ev) {
                                var tgt = $(ev.target);
                                var startTime = getStartTime(tgt);
                                if (startTime && fancyMeContainer.vslMediaElementPlayerRef) {
                                    fancyMeContainer.vslMediaElementPlayerRef.setCurrentTime(startTime);
                                }
                            });
                        }, chapters.length);
                    }
                });
            }

            if (chapters.hasClass('detail') || theRow.length==0) {
                // details loaded - cue points possible || videoModule
                chapters = chapters.find('.chapters');
                bigPlayFancy(chapters);
            } else {
                // load details - to show available cue points if any
                loadVideoDetails(theRow, function (insertedTD) {
                    bigPlayFancy(insertedTD.find('.chapters'));
                });
            }
        }

        // =============================
        // copy link
        // =============================
        //if (tgt.hasClass('copylink')) {
        //	result = false;
        //	console.log('clicked on COPY LINK', getAssociatedData(tgt));
        //}

        // =============================
        // Click on TR in tracktbl:
        // e.g. I-icon in AudioDemoList or VideoDemoList
        //	 or 
        // =============================
        if (tgt.parent().hasClass('hotspot_detail')) {
            if (!(tgt.hasClass('add') && tgt.hasClass('active')) && !tgt.hasClass('del')) {
                result = false;
                var tr = tgt.parent();
                if (music.length) {
                    // on Music area
                    if (!tgt.hasClass('add')) {
                        var dataElem = tr.find('.title');
                        if (dataElem.length === 0) {
                            // use case playlist
                            dataElem = tgt;
                        }
                        var tgt_data = getAssociatedData(dataElem);

                        // stop track if not the selected one is playing
                        if (tgt_data !== getAssociatedData(playerDiv.find('.mejs-controls'))) {
                            removeVslPlayer(playerDiv);
                        }

                        // show detail
                        loadMusicDetails(tgt_data, hideme);
                    }
                } else {
                    if ((tgt.closest('.audiodemolist').length > 0 || tgt.closest('.videodemolist').length > 0)
						 && tgt.hasClass('info')) {
                        // click on info bg icon; show details
                        //console.log('clicked on I icon for', getAssociatedData(tgt));

                        if (!tr.next().hasClass('detail')) {
                            loadVideoDetails(tr);
                        } else {
                            tr.next().toggleClass('hidden');
                            if (insideExtPlayer) {
                                $(window).resize();
                            }
                        }
                    } else if (playOnRowClickEnabled) {
                        // wish from herb: click on row is sufficient to play the track
                        tr.find('.play').trigger('click');
                    }
                }
            }
        }

        // =============================
        // videodemolist cue point
        // =============================
        if (tgt.hasClass('cue_point')) {
            result = false;
            var data = getAssociatedData(tgt);
            var startTime = getStartTime(tgt);
            playVslPlayer(playerDiv, data, (tgt.length) ? tgt[0].title : tgt.title, false, startTime);
            $(tgt).closest('.detail').prev().addClass('active').find('.play').addClass('active');
            //console.log('clicked on cue_point', data, $('video', playerDiv));
        }

        // =============================
        // pricebox
        // =============================
        if (tgt.hasClass('buy')) {
            result = false;
            var tmpProdID = tgt.siblings('input').val();
            var tmpData = tmpProdID;
            if (tmpProdID.indexOf('|') != -1) {
                tmpProdID = tmpProdID.split('|')[0];
            }
            jsonResponseAjaxCall('/basket/' + lng + '/' + tmpProdID, { 'ProdIDs': tmpData }, function () {
                navBasket.addClass('full');
            });
            if (typeof dataLayer !== "undefined") {
                dataLayer.push({'event':'gtm.click.addtocart'});
            }
        }

        // =============================
        // checkbox / radio
        // =============================
        if (tgt.hasClass('checkbox')) {
            result = false;
            var inp = tgt.children('input');
            // when we've added an empty .checkbox before the asp:CheckBoxFor or asp: then propagate the click
            if (!inp.length) {
                var nextCBorR = tgt.next('input[type="checkbox"],input[type="radio"]');
                var oldState = nextCBorR.prop('checked');
                var inpType = nextCBorR.attr('type');
                var checkboxContainer = tgt.closest('.checkbox_container');
                checkboxContainer.find('.hideable').removeClass('block');
                if (inpType === 'radio') {
                    var radios = tgt.parent().find('input[name="' + nextCBorR.attr('name') + '"]');
                    radios.each(function () {
                        $(this).prev('.checkbox').removeClass('active');
                    });
                }
                if (oldState && inpType === 'checkbox') {
                    tgt.removeClass('active');
                } else {
                    tgt.addClass('active');
                    checkboxContainer.find('.hideable' + ((inpType === 'radio') ? '.' + nextCBorR[0].id : '')).addClass('block');
                }
                nextCBorR.click();
                checkboxContainer.find('div.error').addClass('hidden');
            }
        }

        // =============================
        // label of checkbox
        // =============================
        if (tgt.hasClass('cb_label')) {
            result = false;
            var behind = tgt.hasClass('behind');
            var radioOrCB = tgt;
            do {
                radioOrCB = (behind) ? radioOrCB.prev() : radioOrCB.next();
            } while (radioOrCB.length && !radioOrCB.hasClass('checkbox'));
            radioOrCB.click();
        }

        // =============================
        // open already available hidden content in a fancybox
        // =============================
        if (tgt.hasClass('uncover')) {
            result = false;
            var clazz = '.hideable.' + tgt.attr('class').replace('uncover', '').trim().replace(' ', '.');
            var stgt = tgt;
            var toUncover = undefined;
            do {
                toUncover = stgt.siblings(clazz);
                stgt = stgt.parent();
            } while (stgt.length > 0 && toUncover.length == 0);
            if (toUncover.length > 0) {
                $.fancybox({ minWidth: 40, minHeight: 40, content: toUncover });
            }
        }

        // =============================
        // open already available hidden content in a fancybox
        // =============================
        if (tgt.hasClass('notegraph_button')) {
            result = false;
            var isStop = false;
            var aud = tgt.parent().find('.notegraph_button.active audio');
            if (aud.length) {
                aud[0].load();
                var theButton = $(aud[0]).parent();
                theButton.removeClass('active');
                isStop = (theButton[0] == tgt[0]);
            }
            if (!isStop) {
                aud = tgt.find('audio');
                if (aud.length) {
                    $(aud[0]).on('ended', function (e) {
                        tgt.removeClass('active');
                    });
                    aud[0].play();
                    tgt.addClass('active');
                }
            }
        }

        // =============================
        // MyProduct I Button show AC
        // =============================
        if (tgt.hasClass('mp_info')) {
            result = false;
            // response from AJAX is shown in fancy
            jsonResponseAjaxCall('/myProductAC/' + lng, { 'sid': tgt.data('sid') });
        }

        // =============================
        // WISHList
        // =============================
        if (tgt.hasClass('btn_store_wishlist')) {
            result = false;
            var route = '/wishlistActn/' + lng + '/' + tgt[0].id;
            var comment = $('#Order_Comment').val();
            jsonResponseAjaxCall(route, { 'wishlist_comment': comment }, function (cancelled, stringResult) {
            });
        }
        if (tgt.hasClass('btn_load_wishlist')) {
            result = false;
            var route = '/wishlistActn/' + lng + '/' + tgt[0].id;
            jsonResponseAjaxCall(route, undefined, function (cancelled, stringResult) {
                if (!cancelled && stringResult === "RELOAD") {
                    // reload basket page
                    location.reload();
                }
            });
        }
        if (tgt.hasClass('btn_wl_load_wishlist')) {
            result = false;
            var wishlistId = getAssociatedData(tgt).split('/')[0];

            var route = '/loadWishlistRetJson/' + lng;
            jsonResponseAjaxCall(route, { 'wishlist_id': wishlistId }, function (cancelled, stringResult) {
            });
        }
        if (tgt.hasClass('btn_wl_delete_wishlist')) {
            result = false;

            var route = '/wishlistActn/' + lng + '/' + tgt[0].id;
            var wishlistId = getAssociatedData(tgt).split('/')[0];
            jsonResponseAjaxCall(route, { 'wishlist_id': wishlistId }, function (cancelled, stringResult) {
                if (!cancelled && stringResult === "RELOAD") {
                    tgt.closest('table').remove();
                }
            });
        }

        // =============================
        // UPLOAD(s)
        // =============================
        if (tgt.hasClass('studentId_fileupload_upload')) {
            result = false;
        }

        if (tgt.parent().hasClass('referral_vsl')) {
            result = false;
            var route = '/referral/Social/' + lng;
            jsonResponseAjaxCall(route, null, function (cancelled, stringResult) {
            });
        }

        if (tgt.parent().hasClass('referral_image')) {
            result = false;
            var route = '/referral/Basket/' + lng;
            jsonResponseAjaxCall(route, null, function (cancelled, stringResult) {
            });
        }
        return result;
    });

    function loadVideoDetails(row, afterReplace) {
        var newTr = $('<tr class="detail' + ((afterReplace != undefined) ? ' hidden' : '') + '"><td colspan="7"></td></tr>');
        row.after(newTr);
        loadMusicDetails(getAssociatedData(row), newTr.children('td'), afterReplace, 'audiodemo=true');
        // hover over detail in audiodemolist highlights previous TR
        newTr.hover(function () {
            $(this).prev().toggleClass('tr_hover');
        });
    }

    function getStartTime(tgt) {
        var startTime = tgt.attr('data-cue');
        if (startTime === undefined) {
            startTime = tgt.prev().attr('data-cue');
        }
        return startTime;
    }

    function append2MyPlayList(res) {
        res = res.trim();
        if (res.length) {
            if (insideExtPlayer) {
                var tmp = $('#player_playlist .tracktbl tbody');
                tmp.append(res);
                updateSplitter();
                updateTrackCount();
                initSpinner(tmp.find('.spinner'));
            } else {
                $('#playlist.myplayer').children('ul').append(res);
            }
        }
    }

    // if #nav_profile didn't contain an anchor then click it so that #box_profile is shown
    var navLogin = $('#nav_profile');
    if (!navLogin.children('a').length) {
        navLogin.click();
    }

    $('.vsltabs').click(function (ev) {
        var tgt = $(ev.target);
        if (tgt.hasClass('sort') && tgt.prop('nodeName') === 'IMG') {
            // FORUM: propagate click from sort arrow to preceeding <a>
            var anc = tgt.prev('a');
            if (anc.length) {
                anc[0].click();
            }
        } else if (tgt.hasClass('checkbox')) {
            var inp = tgt.children('input');
            inp.val(tgt.hasClass('active') ? '0' : '1');
        }
    });

    function addCheckboxErrorHandler(node) {
        $(node).find('input[type="checkbox"],input[type="radio"]').on('invalid', function (ev) {
            var tgt = $(ev.target);
            //console.log(ev.currentTarget.validationMessage);
            var cbContainer = tgt.closest('.checkbox_container');
            if (cbContainer.length) {
                var err = cbContainer.find('div.error');
                if (!err.length) {
                    err = $('<div></div>').addClass('error');
                    cbContainer.append(err);
                }
                err.html(tgt[0].validationMessage).removeClass('hidden');
            }
            return false;
        });
    }

    addCheckboxErrorHandler('.basket form');
    //updateSideHeight();

    // MyProfile AJAX checks on field focus get lost
    // ---------------------------------------------
    $('#User_ForumName').blur(function () {
        var dUser = $(this).val();
        //console.log('User_ForumName focus Lost, Value is', $(this).val());
        jsonResponseAjaxCall('/profileUserCheck/' + lng, { 'userName': dUser, 'target': 'profile_user_exists' }, function (res) {
        });
    });
    $('#ChangeRequest_NewForumName').blur(function () {
        var dUser = $(this).val();
        //console.log('User_ForumName focus Lost, Value is', $(this).val());
        jsonResponseAjaxCall('/profileUserCheck/' + lng, { 'userName': dUser, 'target': 'change_req_user_exists', 'strIgnoreSelf': 'TRUE' }, function (res) {
        });
    });
    $('#User_EMail').blur(function () {
        var dEmail = $(this).val();
        //console.log('User_EMail focus Lost, Value is', dEmail);
        jsonResponseAjaxCall('/profileEmailCheck/' + lng, { 'email': dEmail, 'target': 'profile_email_exists' }, function (res) {
        });
    });
    //$('#ChangeRequest_NewEmail').blur(function () {
    //    var dEmail = $(this).val();
    //    //console.log('User_EMail focus Lost, Value is', dEmail);
    //    jsonResponseAjaxCall('/profileEmailCheck/' + lng, { 'email': dEmail, 'target': 'change_req_email_exists' }, function (res) {
    //    });
    //});

    // update title of NEWSLETTER TopNav Item (from DB Display value and Title are the same)
    $('#nav_newsletter').find('a').attr('title', (lng === 'de') ? 'Newsletter abonnieren' : 'Subscribe to newsletter');

    // MyDownloads (checkboxes and select)
    var myDownloads = $('#mydownloads');
    var theDlCBoxes = myDownloads.find('.body .checkbox').next('input[type="checkbox"]').add(myDownloads.find('.body select')).on('change', myDownloadsAJAX);

    function myDownloadsAJAX(ev) {
        var filterVal = 0;
        theDlCBoxes.each(function (idx, elem) {
            if (elem.checked) {
                filterVal |= $(elem).val();
            }
        });
        var dateHeadActive = $('.dl_list th.dl_date.active');
        ajaxCall('/myDownloads/' + lng, function (res) {
            myDownloads.find('.content').html(res);
        }, { 'filterValue': filterVal, 'osValue': $('#os_type_sel').val(), 'productValue': $('#product_sel').val(), 'manualValue': $('#manual_lang_sel').val(), 'sortValue': (dateHeadActive.length > 0) ? (dateHeadActive.hasClass('reverse') ? -1:1) : 0 });
    }
    //pin method to document; used in MyDownloadsResult
    document.myDownloadsAJAX = myDownloadsAJAX;

    // MyProducts (checkboxes)
    var myProducts = $('#myproducts');
    var theProdCBoxes = myProducts.find('.body .checkbox').next('input[type="checkbox"]');
    var changeFunction = function (ev) {
        var filterVal = 0;
        theProdCBoxes.each(function (idx, elem) {
            if (elem.checked) {
                filterVal |= $(elem).val();
            }
        });
        ajaxCall('/myProducts/' + lng, function (res) {
            myProducts.find('.content').html(res);
            $('#myproducts #Sort').change(changeFunction);
        }, { 'filterValue': filterVal, 'sort': myProducts.find('#Sort').val() });
    };
    theProdCBoxes.add('#myproducts #Sort').change(changeFunction);

    // Product Registration
    var prodRegistration = $('#prodreg');
    prodRegistration.click(function (ev) {
        var x = prodRegistration.find('#check_serial');
        if (x.length && ev.target === x[0]) {
            var checkBoxes = prodRegistration.find('#postForm').find('input[type="radio"]');

            var cBoxSet = true;
            if (checkBoxes.length > 0) {
                cBoxSet = false;
                checkBoxes.each(function (idx, elem) {
                    if (elem.checked) {
                        cBoxSet = true;
                        return false;
                    }
                });
            }
            if (cBoxSet) {
                ajaxCall('/prodReg/' + lng, function (res) {
                    // ok result
                    updateProdRegWithAjaxResponse(res, '#postForm');

                    addSerialCheck('#prodreg input.serialformat');
                    addCheckboxErrorHandler(prodRegistration);
                }, prodRegistration.find('#postForm').serialize(), function (xhr, textStatus, error) {
                    // AJAX error result
                    prodRegistration.html(error);
                });
            }
            return false;
        }
        var y = prodRegistration.find('#check_vkserial');
        if (y.length && ev.target === y[0]) {
            ajaxCall('/viennaKeyReg/' + lng, function (res) {
                // ok result
                updateProdRegWithAjaxResponse(res, '#postFormVK');
                addAlphaNumDashCheck('#prodreg input.serial[name="vkserial"]');
            }, prodRegistration.find('#postFormVK').serialize(), function (xhr, textStatus, error) {
                // AJAX error result
                prodRegistration.html(error);
            });
            return false;
        }
        return true;
    });

    // jump from MyProducts to MyDownloads
    jump2MyDownloads(myProducts.find('.mp_list a'), function (ev, multiSelect) {
        multiSelect.data('collids', $(ev.target).attr('href').split('=')[1]);
    });

    // jump from Basket to MyDownloads
    jump2MyDownloads('#download_your_files');

    function jump2MyDownloads(selector, setCollIds) {
        $(selector).click(function (ev) {
            var form = $('#jmp2download');
            form.attr('action', '/' + lng + '/MyVSL/MyDownloads');
            var multiSelect = $('#prodVal', form);
            if (setCollIds) {
                setCollIds(ev, multiSelect);
            }
            var option = multiSelect.find('option');
            // build string that split works even if it is a single value (and be an int)
            var collIDs = (',' + multiSelect.data('collids')).split(',');
            for (var i = 1, j = collIDs.length; i < j; i++) {
                // clone required amount of options
                var theOption = option;
                if (i > 1) {
                    theOption = option.clone();
                    multiSelect.append(theOption);
                }
                theOption.val(collIDs[i]);
            }
            form.submit();
            return false;
        });
    }

    function updateProdRegWithAjaxResponse(res, formID) {
        var form = prodRegistration.find(formID);
        var formParent = form.parent();
        form.remove();
        var newForm = $(res).find(formID);
        if (newForm.length) {
            formParent.append(newForm);
        } else {
            // either session timeout or session abendoned due to too much failed registrations
            location.reload(true);
        }
    }

    function addSerialCheck(top) {
	    // ensure pattern for serial number XXX-XXXXX-XXXXX-XXXXX
	    var serial = $(top);

	    var kBack = 8, kTab = 9, kEnter = 13, kPosA = 35, kEnd = 36, kLeft = 37, kUp = 38, kRight = 39, kDown = 40, kDel = 46, k0 = 48, k9 = 57, kA = 65, kZ = 90, nk0 = 96, nk9 = 105;   // 48-57 0-9   65-90 A-Z
	    serial.keydown(function (ev) {
	        var key = ev.which;

	        var valid = (key == kBack || key == kTab || key == kEnter || (key >= kPosA && key <= kDown) || key == kDel || (key >= kA && key <= kZ) || (!ev.shiftKey && ((key >= k0 && key <= k9) || (key >= nk0 && key <= nk9)) ));
	        if ((ev.ctrlKey && key != 65/*a*/ && key != 67/*c*/ && key != 86/*v*/ && key != 88/*x*/) || ev.altKey || !valid) {
	            // ignore key
	            return false;
	        }
	        // console.log('serial down shift ctrl alt', ev.keyCode, key, ev.shiftKey, ev.ctrlKey, ev.altKey, valid);
	        return true;
	    });

	    serial.keyup(function (ev) {
	        var key = ev.which;

	        if (key == kTab || key == kEnter || (key >= kPosA && key <= kDown)) {
	            return;
	        }
	        var cursorPos = getCursorPos(serial[0]);
	        var contentOriginal = $(this).val().trim();
	        //console.log('caretpos', cursorPos);
	        var contentNew = contentOriginal.replace(/[^A-Z0-9]/gi, '').toUpperCase();
	        contentNew = contentNew.substr(0, 18);

	        if (contentNew.length > 13) {
	            contentNew = contentNew.substr(0, 13) + '-' + contentNew.substr(13);
	        }
	        if (contentNew.length > 8) {
	            contentNew = contentNew.substr(0, 8) + '-' + contentNew.substr(8);
	        }
	        if (contentNew.length > 3) {
	            contentNew = contentNew.substr(0, 3) + '-' + contentNew.substr(3);
	        }

	        // was the '-' deleted, so we need to skip further character
	        if (key == kBack && (cursorPos == 3 || cursorPos == 9 || cursorPos == 15)) {
	            var a = contentNew.substr(0, cursorPos - 1);
	            var b = contentNew.charAt(cursorPos + 1);
	            var c = contentNew.substr(cursorPos + 2);
	            contentNew = contentNew.substr(0, cursorPos - 1) + contentNew.charAt(cursorPos + 1) + '-' + contentNew.substr(cursorPos + 2);
	        }

	        if (contentNew.length == 4 || contentNew.length == 10 || contentNew.length == 16) {
	            contentNew = contentNew.substr(0, contentNew.length - 1);
	        }
	        if ((key != kBack) && (contentNew.length == cursorPos + 1) && (cursorPos == 4 || cursorPos == 10 || cursorPos == 16)) {
	            cursorPos++;
	        }
	        if ((key == kBack) && (cursorPos == 4 || cursorPos == 10 || cursorPos == 16)) {
	            cursorPos--;
	        }

	        if (contentNew != contentOriginal) {
	            $(this).val(contentNew);
	        }

	        if (ev.ctrlKey && key != 65/*a*/) {
	            setCursorPos(serial[0], Math.min(cursorPos, contentNew.length));
	        }

	        //console.log('serial', ev.keyCode, key, ev.shiftKey, contentNew);
	    });
	}

    function addAlphaNumDashCheck(top) {
        // ensure pattern 0-9 A-Z and dash and positioning keys
        var serial = $(top);

        var kBack = 8, kTab = 9, kEnter = 13, kPosA = 35, kEnd = 36, kLeft = 37, kUp = 38, kRight = 39, kDown = 40, kDel = 46, k0 = 48, k9 = 57, kA = 65, kZ = 90, nk0 = 96, nk9 = 105, kDash = 189;   // 48-57 0-9   65-90 A-F  '-' 189
        serial.keydown(function (ev) {
            var key = ev.which;

            var valid = (key == kBack || key == kTab || key == kEnter || (key >= kPosA && key <= kDown) || key == kDel || (key >= kA && key <= kZ) || (!ev.shiftKey && ((key >= k0 && key <= k9)  || (!ev.shiftKey && key == kDash) || (key >= nk0 && key <= nk9))));
            if ((ev.ctrlKey && key != 65/*a*/ && key != 67/*c*/ && key != 86/*v*/ && key != 88/*x*/) || ev.altKey || !valid) {
                // ignore key
                return false;
            }
            // console.log('serial down shift ctrl alt', ev.keyCode, key, ev.shiftKey, ev.ctrlKey, ev.altKey, valid);
            return true;
        });
    }

    //pin method to document; used in SaveWishlistDialog and SavePlaylistDialog
    document.addAlphaNumDashCheck = addAlphaNumDashCheck;

    addSerialCheck('#Voucher_Serial');
    addSerialCheck('#prodreg input.serialformat');
    addAlphaNumDashCheck('#prodreg input.serial[name="vkserial"]');
    addCheckboxErrorHandler(prodRegistration);

	function getCursorPos(fld) {

	    var pos = 0;
	    // IE Support
	    if (document.selection) {
	        fld.focus();
	        var sel = document.selection.createRange();

	        sel.moveStart('character', -fld.value.length);

	        pos = sel.text.length;
	    } else if (fld.selectionStart || fld.selectionStart == '0') {
	        // Firefox support
	        pos = fld.selectionStart;
	    }

	    return pos;

	}

	function setCursorPos(fld, pos) {
	    if (fld.setSelectionRange) {
	        fld.focus();
	        fld.setSelectionRange(pos, pos);
	    } else if (fld.createTextRange) {
	        var range = fld.createTextRange();
	        range.collapse(true);
	        range.moveEnd('character', pos);
	        range.moveStart('character', pos);
	        range.select();
	    }
	}

	function glossarHandler(startElem) {
	    $('abbr', startElem).hover(function (e) {
	        var posRelParent = $('#all');
	        if (posRelParent.length) {
	            var leftrightShift = 15;
	            var cite = $('.' + $(this).data('glossar'));
	            var leftCite = parseInt(posRelParent.css('margin-left'));
	            // firefox delivers margin left 0 in case of auto; chrome and IE delivers a value > 0
                leftCite = (leftCite == 0) ? 10 - posRelParent[0].offsetLeft : -leftCite;
	            leftCite += e.pageX - parseInt(cite.css('padding-left'));
	            leftCite = (leftCite > 620 /* left limited to this value so that width of cite (current 320px) is fully visible */) ? leftCite - cite.width() - leftrightShift - parseInt(cite.css('padding-left')) - parseInt(cite.css('padding-right')) : leftCite + leftrightShift;
	            cite.css({
	                left: leftCite,
	                top: Math.max(0, Math.min(this.offsetTop + 18 - posRelParent[0].offsetTop, posRelParent.height() - 10 - cite.height()))
	            }).stop().show(100);
	        }
	    }, function () {
	        $('.' + $(this).data('glossar')).hide();
	    });
	}
	document.glossarHandler = glossarHandler;

	setDynamicPlaylistHeight();
	glossarHandler();

    /* scrollbars */

	function initScrollbars() {
	    $(".scrollable").each(function (i, x) {

	        x = $(x);

	        x.removeClass("scrollable");
	        x.addClass("content");

	        var item = $('<div id="' + x.attr("id") + "_wrap" + '" class="scrollable"><div class="scrollbar"><div class="handle"><div></div></div></div><div class="pane">' + x.outerHTML() + '</div></div>');
	        x.replaceWith(item);

	        var pane = item.find(".pane");
	        var content = item.find(".content");
	        var bar = item.find(".scrollbar");
	        var handle = item.find(".handle");

	        content.css("overflow", "visible");
	        content.css("height", "auto");

	        handle.draggable({
	            axis: "y",
	            containment: "parent",
	            drag: function (e, x) {
	                if (content.height() > pane.height()) {
	                    pane.scrollTop((content.height() - pane.height()) * x.position.top / (bar.height() - handle.height()));
	                } else {
	                    pane.scrollTop(0);
	                }
	            }
	        });

	        bar.on("click", function (e, item) {
	            if (pane.height() < content.height())
	                pane.scrollTop((content.height() - pane.height()) * (e.pageY - bar.offset().top) / bar.height());
	        });

	        pane.scroll(function () {
	            if (pane.height() >= content.height())
	                handle.css("top", 0);
	            else
	                handle.css("top", (bar.height() - handle.height()) * pane.scrollTop() / (content.height() - pane.height()) + "px");
	        });

	    });
	}

	function updateScrollbars() {
	    $(".scrollable").each(function (i, item) {
	        item = $(item);

	        var pane = item.find(".pane");
	        var content = item.find(".content");
	        var bar = item.find(".scrollbar");
	        var handle = item.find(".handle");

	        if (pane.height() >= content.height()) {
                handle.height(bar.height());
	        } else {
	            handle.height(Math.min(Math.max(30, (bar.height() * pane.height() / content.height())), bar.height()));
	        }
	    });

	    resetScrollbars();
	}

	function resetScrollbars() {
	    $(".scrollable").each(function (i, item) {
	        item = $(item);

	        var pane = item.find(".pane");
	        var content = item.find(".content");
	        var bar = item.find(".scrollbar");
	        var handle = item.find(".handle");

	        if (pane.height() >= content.height()) {
	            handle.css("top", 0);
	        } else {
	            handle.css("top", (bar.height() - handle.height()) * pane.scrollTop() / (content.height() - pane.height()) + "px");
	        }
	    });
	}

    /* splitter */
	var splitterH = 6;
	function initSplitter() {
	    $("#player_splitter").draggable({
	        orientation: "vertical",
	        containment: "parent",
	        drag: function (e, ui) {
	            var ratio = ($("#player_content").height() - ui.position.top - splitterH / 2) / $("#player_content").height();
	            updateSplitter(ratio);
	        }
	    });
	}

	function updateSplitter(ratio) {
	    var h = $("#player_footer").position().top - $("#player_content").position().top;
	    var tmp = h * (1 - ratio) - splitterH / 2;

	    $("#player_content").css("height", h);

	    if ($("#player_load_playlist").hasClass("active") || $("#player_add_track").hasClass("active")) {
	        $("#player_top").css("height", tmp);
	    } else {
	        $("#player_top").css("height", h);
	    }

	    $("#player_bottom").css("height", h - tmp - splitterH);

	    $("#player_splitter").css("top", tmp);

	    updateScrollbars();
	}

	function updateTrackCount() {
	    var parts = $("#pl_title").html().split('&');
	    $("#pl_title").html(parts[0] + '&nbsp;&ndash;&nbsp;' + $('#player_playlist tr.hotspot_detail').length + ' tracks');
	}

	function initSpinner(tgt) {
	    tgt.spinner({
	        step: 1,
	        numberFormat: "n",
	        min: -30,
	        max: 0,
	        spin: function (ev, ui) {
	            if ($(ev.target).closest('tr.hotspot_detail').hasClass('active')) {
	                $('audio')[0].volume = Math.pow(10, ui.value / 10);
	            }
	        }
	    });
	}

	if (insideExtPlayer) {
	    jQuery.fn.outerHTML = function (s) {
	        return s
                ? this.before(s).remove()
                : jQuery("<p>").append(this.eq(0).clone()).html();
	    };

	    initScrollbars();
	    initSplitter();
	    initSpinner($('#player_playlist .spinner'));

	    $("#player_close").on("click", function () {
	        // clear session info of playlist of external player
	        ajaxCall('/ext/playlisActn/' + lng + '/del', function (res) {
	            window.close();
	        }, { 'plID': 0, 'trackID': 0 });
	    });

	    $(window).on("resize", function (e) {
	        var ratio = ($("#player_bottom").height() + splitterH / 2) / $("#player_content").height();
	        updateSplitter(ratio);
	    });

	    $("#player_add_track").on("click", function (e) {
	        if ($(e.target).hasClass("active")) {
	            $(e.target).removeClass("active");
	            $("#player_demo_browser").removeClass("shown");
	            $("#player_demo_browser_wrap").removeClass("shown");
	            $("#player_splitter").removeClass("shown");
	            $("#player_bottom").removeClass("shown");
	        } else {
	            $("#player_load_playlist").removeClass("active");
	            $("#player_playlist_browser").removeClass("shown");
	            $("#player_playlist_browser_wrap").removeClass("shown");
	            $(e.target).addClass("active");
	            $("#player_demo_browser").addClass("shown");
	            $("#player_demo_browser_wrap").addClass("shown");
	            $("#player_splitter").addClass("shown");
	            $("#player_bottom").addClass("shown");
	        }

	        $(window).resize();
	    });

	    $("#player_load_playlist").on("click", function (e) {
	        if ($(e.target).hasClass("active")) {
	            $(e.target).removeClass("active");
	            $("#player_playlist_browser").removeClass("shown");
	            $("#player_playlist_browser_wrap").removeClass("shown");
	            $("#player_splitter").removeClass("shown");
	            $("#player_bottom").removeClass("shown");
	        } else {
	            $("#player_add_track").removeClass("active");
	            $("#player_demo_browser").removeClass("shown");
	            $("#player_demo_browser_wrap").removeClass("shown");
	            $(e.target).addClass("active");
	            $("#player_playlist_browser").addClass("shown");
	            $("#player_playlist_browser_wrap").addClass("shown");
	            $("#player_splitter").addClass("shown");
	            $("#player_bottom").addClass("shown");
	            $.get('/' + lng + '/Player/Playlists', function (data) {
	                var ppb = $("#player_playlist_browser");
	                var open = ppb.find('.tracktbl.open');
                    // set new content
	                ppb.html('<div class="player_load_playlist res"></div>' + data);
	                $(".player_load_playlist", ppb).on("click", function () {
	                    $("#player_load_playlist").click();
	                });
	                // keep open state
	                open.each(function () {
	                    var name = $(this).find('th.title').html();
	                    var item = ppb.find('.tracktbl th.title[title="' + name + '"]');
	                    var ttbl = item.closest('.tracktbl');
	                    if (!ttbl.hasClass('open')) {
	                        ttbl.addClass('open');
	                    }
	                });
	                updateSplitter();
	            });
            }

	        $(window).resize();
	    });
	    $.get('/' + lng + '/Player/Playlists', function (data) {
	        var ppb = $("#player_playlist_browser");
	        ppb.html('<div class="player_load_playlist res"></div>' + data);
	        $(".player_load_playlist", ppb).on("click", function () {
	            $("#player_load_playlist").click();
	        });
	    });

	    $("#player_playlist").sortable({
	        items: ".hotspot_detail",
	        axis: "y",
	        handle: ".info,.title,.composer,.duration,.res",
	        containment: "#player_playlist",
	        cursor: "move"
	        //helper: "clone"
	    });
	    var sort_detail = undefined;
	    var detail_dropped_on = undefined;
	    $("#player_playlist").on("sortstart", function (event, ui) {
            // eliminate detail below dragged item
	        var nxt = $(ui.helper).next();
	        if (nxt.hasClass('ui-sortable-placeholder')) {
	            nxt = nxt.next();
        	}
	        if (nxt.hasClass('detail')) {
	            sort_detail = nxt;
	            nxt.remove();
	        }
	    });
	    $("#player_playlist").on("sortbeforestop", function (event, ui) {
	        var nxt = $(ui.placeholder).next();
	        if (nxt.hasClass('detail')) {
	            detail_dropped_on = nxt;
	        }
	    });
	    $("#player_playlist").on("sortstop", function (event, ui) {
	        if (detail_dropped_on) {
	            // move detail on which item was dropped before the item
	            detail_dropped_on.prev().before(detail_dropped_on);
	        }
	        if (sort_detail) {
	            // add eliminated detail below dragged item
	            $(ui.item).after(sort_detail);
	        }
	        detail_dropped_on = undefined;
	        sort_detail = undefined;
	    });

	    $(window).resize();
	    updateSplitter();

	    $('.pane').on('mousewheel', function (event) {
	        var pane = $(this);
	        var contentH = pane.find('.content').height();
	        var paneH = pane.height();
	        if (paneH < contentH) {
	            pane.scrollTop(Math.max(0, Math.min(pane.scrollTop() - 24 * event.deltaY, contentH - paneH)));
	        }
	    });
	    $(window).focus();
	}

    // =============================
    // AJAX cookie decline
    // =============================
	$('#btn_cookie_decline').on('submit', function (ev) {
	    var $form = $(this);
	    var $target = $($form.attr('data-target'));

	    $.ajax({
	        type: $form.attr('method'),
	        url: $form.attr('action'),
	        data: $form.serialize(),

	        success: function (data, status) {
	            $target.html(data);
	        }
	    });
	    return false;
	});

    // =============================
    // StudentID Upload
    // =============================
	var studentIdUpldUrl = '/studentIdUpload/' + lng;
    var studentIdUpldBtn = $('<button type="submit"/>')
            .addClass('studentId_fileupload_upload')
            .text((lng == 'de') ? 'HOCHLADEN' : 'UPLOAD')
            .on('click', function () {
                var $this = $(this),
                    data = $this.data();
                $this
                    .off('click')
                    .text((lng == 'de') ? 'ABBRECHEN' : 'ABORT')
                    .on('click', function () {
                        $this.remove();
                        $('#studentid_upload_progress').removeClass('active');
                        data.abort();
                    });
                data.submit().always(function () {
                    $this.remove();
                    $('#studentid_upload_progress').removeClass('active');
                });
            });
    studentIdUpldBtn = $('<div class="submit"></div>').append(studentIdUpldBtn);

    if ($.blueimp && $.blueimp.fileupload) {
        $('#studentId_fileupload').fileupload({
            url: studentIdUpldUrl,
            dataType: 'json',
            autoUpload: false,
            acceptFileTypes: /(\.|\/)(gif|jpe?g|png|tif?f|bmp|pdf)$/i,
            maxFileSize: 5242880, // 5 MB
            disableImagePreview: true
        }).on('fileuploadadd', function (e, data) {
            data.context = $('<div/>').appendTo('#studentId_files');
            $.each(data.files, function (index, file) {
                var node = $('<p id=\'sid_file_for_up_exists_marker\' />')
                        .append($('<input type=\'text\' readonly=\'readonly\' class=\'fname\'/>').attr('title', file.name).val(file.name));
                if (!index) {
                    node
                        .append(studentIdUpldBtn.clone(true).children().data(data)); // children() because of our added DIV
                }
                if ($('#sid_file_for_up_exists_marker').length > 0) {
                    $('#sid_file_for_up_exists_marker').remove();
                }
                node.appendTo(data.context);
            });
        }).on('fileuploadprogressall', function (e, data) {
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $('#studentid_upload_progress').addClass('active');
            $('#studentid_upload_progress .progress-bar').css(
                'width',
                progress + '%'
            );
        }).on('fileuploaddone', function (e, data) {
            $.each(data.result, function (index, file) {
                if (file.url) {
                    var succTxt = $('<span/>').text((lng == 'de') ? 'Hochladen erfolgreich' : 'Upload successful');
                    $(data.context.children()[index])
                        .append(succTxt);
                    $('#studentId_fileupload').data('vsluploaded', 'true');
                } else if (file.error) {
                    if (file.error == 'NotLoggedInUser') {
                        window.location = file.delete_url;
                    } else {
                        var error = $('<span class="text-danger"/>').text(file.error);
                        $(data.context.children()[index])
                            .append(error);
                    }
                }
            });
        }).on('fileuploadfail', function (e, data) {
            $.each(data.files, function (index) {
                var error = $('<span class="text-danger"/>').text((lng == 'de') ? 'Hochladen fehlgeschlagen' : 'File upload failed');
                $(data.context.children()[index])
                    .append(error);
            });
        }).prop('disabled', !$.support.fileInput)
            .parent().addClass($.support.fileInput ? undefined : 'disabled');
    }

    var fancyOpenOnLoad = $('.fancy_showonload');
    if (fancyOpenOnLoad.length) {
        $.fancybox({ minWidth: 40, minHeight: 40, content: $(fancyOpenOnLoad[0]).html() });
    }

    var sticky = $('.sticky');
    if (sticky.length > 0) {
        var stickyOffset = sticky.offset().top;
        $(window).scroll(function () {
            var scroll = $(window).scrollTop();

            var subst = sticky.siblings('.stickysubst');
            if (scroll >= stickyOffset) {
                if (subst.length == 0) {
                    sticky.after($('<div class="stickysubst"></div>'));
                    subst = sticky.siblings('.stickysubst');
                    subst.css('padding', sticky.css('padding'));
                    subst.css('margin', sticky.css('margin'));
                }
                subst.css('height', sticky.css('height'));
                subst.show();
                sticky.addClass('fixed');
            } else {
                sticky.removeClass('fixed');
                if (subst.length > 0) {
                    subst.hide();
                }
            }
        });
    }
});

$(window).load(function () {
    setDynamicPlaylistHeight();

    // due to font loading via @font-face the equalHeights can't be used on document.ready
	$('.col1').equalHeights();
	$('.col2').equalHeights();
	$('.col3').equalHeights();
	$('.col4').equalHeights();
	$('.col5').equalHeights();

	if ($('#cookie-alert').length) {
	    $('#foot').css('padding-bottom', $('#cookie-alert').outerHeight());
	}
});

function setDynamicPlaylistHeight() {
    var pList = $('#playlist.dynamicplayer');
    if (pList.length) {
        var remainingHeight = $('#top').height() - $('#nav_sub').height() - 2;
        pList.height(remainingHeight);
    }
}

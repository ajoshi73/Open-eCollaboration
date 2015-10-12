var spinnerOpts, spinner;
(function($) {

    "use strict";

    $(function() {

    	$(document).on('click', 'a[href="#"]', function(e) {
         
    		if(e.preventDefault) {
    			e.preventDefault();
    		} else {
    			e.returnValue = false;
    		}
    		
    	});

        if ($('#create_room').length > 0) {

            var el = $('.of-inline-input');

            el.focus();
            el.select();

        }

        // Toggle button for showing blocks
        $(document).on('click change', '[data-of-toggler]', function(e) {
            var id = $(this).data('of-toggler'),
                el = $('[data-of-toggled="' + id + '"]'),
                isRadio = $(this).is('input[type="radio"]'),
                condition = isRadio ? (parseInt($(this).val()) === 1) : !$(this).hasClass('of-active');

            if (isRadio !== false && e.type !== 'change') {
                return;
            }

            if (isRadio !== true) {
                e.preventDefault();
                $(this).toggleClass('of-active');
            }

            el.toggleClass('of-hidden', !condition);
            el.find('input').first().focus();
            el.find('textarea').trigger('keydown');

        }).on('ready', function() {

            var hash = location.hash.replace('#', ''),
                el = $('[data-of-toggled="' + hash + '"]'),
                link = $('a[data-of-toggler="' + hash + '"]');

            link.addClass('of-active');
            el.removeClass('of-hidden');
            el.find('input').first().focus();
            el.find('textarea').trigger('keydown');

        }).on('click', '[data-of-toggler-multiple]', function(e) {
            // Toggle buttons for switching blocks

            e.preventDefault();
            var id = $(this).data('of-toggler-multiple'),
                el = $('[data-of-toggled-multiple="' + id + '"]');

            if ($(this).hasClass('of-active'))
                return false;

            $(this).addClass('of-active');
            $(this).siblings('[data-of-toggler-multiple]').removeClass('of-active');

            el.removeClass('of-hidden');
            el.siblings('[data-of-toggled-multiple]').addClass('of-hidden');
            return false;

        });

        // Accordion

        $(document).on('click', '.of-accordion header', function(e) {
            e.preventDefault();

            if (e.metaKey !== false) {
                $('.of-accordion').addClass('of-closed');
                $(this).parent().removeClass('of-closed');

                return;
            }

            $(this).parent().toggleClass('of-closed');

        });

        // File

        $(document).on('click', 'a[data-file]', function(e) {
            e.preventDefault();

            $('input[data-file="' + $(this).data('file') + '"]').trigger('click');
        })


        // Fix for touch (iPhone tested) - when user focuses on input in header, header stays on top of viewport.
        $('header').find('input, select, textarea').on('focus', function() {
            var curScroll = $(window).scrollTop();

            $('.of-header').find('.active').not($(this).parent()).removeClass('active');

            $('html, body').animate({
                scrollTop: curScroll
            }, 1);
        });

        $(document).on('click', '[data-toggle]', function(e) {
            e.stopPropagation();

            var header = $('.of-header'),
                el = $(this),
                id = el.attr('data-toggle'),
                target = $('.' + id);

            el.removeAttr('data-of-badge');

            if (target.hasClass('active')) {
                target.removeClass('active');
                el.removeClass('active');

                if (id === 'of-search') {
                    target.removeAttr('style');
                }

                return false;
            }

            header.find('.of-search').removeAttr('style');
            header.find('.of-search-results').parent().removeClass('focus');
            header.find('.active').not(el).removeClass('active');

            target.addClass('active');
            el.addClass('active');

            if (id === 'of-search') {
                var windowHeight = $('body').height() - $('header[role="banner"]').height(),
                    curScroll = $(window).scrollTop();

                $('html, body').animate({
                    scrollTop: curScroll
                }, 1);

                var parent = $(this).parent(),
                    search = parent.find('.of-search');

                search.attr('style', 'display: block !important; height: ' + windowHeight + 'px;').find('input').focus();
            }

        }).on('click', '[data-toggle="of-profile-menu"]', function(e) {
        	
        	var profileIgnoreHandler = function(e) {
        		e.stopPropagation();
        	}
        	
            var profileHideHandler = function(e) {
            	var $profileMenu = $(".of-profile-menu");
            	
            	$profileMenu.removeClass('active');
            	$profileMenu.parent().removeClass('active');
            	
            	$("html").off('mousedown', profileHideHandler)
            	.off('mousedown', '.of-profile-menu', profileIgnoreHandler);
            }

            $("html").on('mousedown', profileHideHandler)
            .on('mousedown', '.of-profile-menu', profileIgnoreHandler);

        }).on('keyup', function(e) {
            var key = e.keyCode ? e.keyCode : e.which;

            if (key !== 27)
                return false;

            var header = $('.of-header');

            header.find('.active').removeClass('active');
            header.find('.of-search').removeAttr('style');
            header.find('.of-search-results').parent().removeClass('focus');
        });

        $(document).on('click', '[data-of-toggle-menu]', function(e) {
            e.preventDefault();

            var menu = $('[data-of-menu="' + $(this).attr('data-of-toggle-menu') + '"]');

            if (menu.hasClass('active')) {
                $(this).removeClass('active');
                menu.removeClass('active');
                return;
            }

            $(this).addClass('active');
            menu.addClass('active');

        });

        $('.of-tabs').tabs();

    });
}(jQuery));
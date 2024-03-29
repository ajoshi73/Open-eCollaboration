+ function($) {

    'use strict';

    var of_forms = [],
        of_selects = [];

    $(document).ready(function() {

        $('form.of-form').each(function(i, el) {
            of_forms.push(new OF_Form(el));
        });

        $('.of-checkbox, .of-radio').attr('tabIndex', 0);

        $('input[disabled] + .of-checkbox, input[disabled] + .of-radio[disabled]').attr('tabIndex', '-1');

        $('select[data-of-select]').each(function(i, el) {
            of_selects.push(new OF_Select(el));
        });

        $('input[data-of-autocomplete]').each(function() {
            $(this).ofAutoComplete();
        });

        $('textarea').not('[data-of-no-resize]').each(function() {
            $(this).ofAutoResize();
        });

        // If the browser does not support native html5 date picker AND has touch, use jQuery UI version
        if ((!Modernizr.inputtypes.date && !Modernizr.touch)) {

            $('input[type="date"], input[type="datetime"], input[type="datetime-local"]').datepicker({
                changeMonth: true,
                changeYear: true,
                showWeek: true,
                dayNamesShort: true,
                onSelect: function() {
                    $(this).trigger('blur');
                }
            });
        }

    });

    $.fn.ofAutoComplete = function() {
        var el = $(this),
            src = el.data('of-autocomplete') !== '' ? el.data('of-autocomplete') : false,
            data = [],
            results = [],
            used = [],
            moving = false,
            MIN_LENGTH = 2;

        if (src === false)
            return false;

        el.attr('autocomplete', 'off');

        var a = null;
        var header = null;
        
        if(el.closest(".of-input-autocomplete").length == 0) {
        	a = $('<div/>').addClass('of-input-autocomplete');
        	header = $('<header>').appendTo(a)
        } else {
        	a = elel.closest(".of-input-autocomplete");
        	header = a.next("header");
        }
        
        var val = el.val();

        a.insertAfter(el);
        el.appendTo(header);

        if(val.length > 0) {
            var elArr = val.split(', ');

            for(var i = 0, il = elArr.length; i < il; i++) {

                appendTag(elArr[i].toLowerCase());                

            }

            el.val('');
        }

        a.on('click tap', 'li', function(e) {
            e.preventDefault();

            appendTag($(this).data('index'));

            el.val('');
            populateList(false);
            el.focus();
        });

        el.on('focus', function(e) {
            a.addClass('focus');

            if (el.val().length > 0)
                a.addClass('active')

        }).on('blur', function(e) {
            a.removeClass('focus');
        }).on('paste drop', function(e) {

            var ev = e.originalEvent,
                data = typeof ev.clipboardData !== 'undefined' ? ev.clipboardData : ev.dataTransfer;

            if ($.inArray('Files', data.types) > -1) {
                e.preventDefault();
                return false;
            }

            var pos = el.caret();

            var tagText = replaceDisallowed(data.getData('text/plain'));

            if (el.get(0).selectionStart !== el.get(0).selectionEnd) {
                el.val(tagText);
            } else {
                el.val(el.val().substring(0, pos) + tagText + el.val().substring(pos));
                el.caret(pos + tagText.length);
            }

            return false;

        }).on('keydown', function(e) {

            var key = e.keyCode ? e.keyCode : e.which;
            moving = false;

            // DOWN
            if (key === 40 && a.hasClass('active') && a.find('li').length > 1) {
                var current = a.find('li.current'),
                    next = current.nextAll().not('.disabled').first();

                if (next.length === 0 || typeof next === 'undefined') {
                    moving = true;
                    return false;
                }

                current.removeClass('current');
                next.addClass('current');
                moving = true;
                return false;
            }

            // UP
            if (key === 38 && a.hasClass('active') && a.find('li').length > 1) {
                var current = a.find('li.current'),
                    next = current.prevAll().not('.disabled').first();

                if (next.length === 0 || typeof next === 'undefined') {
                    moving = true;
                    return false;
                }

                current.removeClass('current');
                next.addClass('current');
                moving = true;
                return false;
            }

            if (isDisallowed(e)) {
                e.preventDefault();
                return false;
            }

            if (isReturn(e)) {
                e.preventDefault();
            }

            if (isBackspace(e)) {

                if (hasTags()) {
                    removeLastTag();
                }

            }

        }).on('keyup', function(e) {
            var key = e.keyCode ? e.keyCode : e.which,
                input = $(this),
                val = input.val();

            if (isDisallowed(e)) {
                e.preventDefault();
                return false;
            }

            if (isEscape(e)) {
                el.blur();
            }

            if (isReturn(e) && a.hasClass('active')) {

                if (a.find('.current').length === 0) {
                    return false;
                }

                var index = a.find('.current').data('index');
                appendTag(index);

                if (typeof index !== 'undefined')
                    el.val('');

                populateList(false);

                return false;
            };


            if (moving !== false) {
                e.preventDefault();
                return false;
            }

            moving = false;
            results = findTag(val, populateList);

            return;

        });

        function replaceDisallowed(val) {

            return val.replace(/[^\w\������!?]/g, '');
        }

        function findTag(val, callback) {
            var result = [],
                length = val.length;

            if (isEmpty(val) || length < -1) {
                a.removeClass('active');
                return false;
            }

            $.ajax({
                cache: false,
                url: src,
                dataType: 'json',
                data: {
                    query: val
                },
                contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
                error: function(xhr, ajaxOption, thrownError) {

                },
                success: function(response) {

                    if(response.length > 0) {
                        callback(response);
                    } else {
                        callback(new Array(val));
                    }

                    return;
                }
            })

            // for (var i = 0, il = data.length; i < il; i++) {

            //     var d = data[i].toLowerCase();

            //     if (d.substring(0, length) === val.toLowerCase()) {
            //         result.push(d);
            //     }
            // }


            // if (result.length === 0 && isEmpty(val) !== true) {
            //     result = '#' + val;
            // }

            return;

        }

        function isDisallowed(e) {
            var key = e.keyCode ? e.keyCode : e.which,
                HASHTAG = (key === 51 && e.shiftKey !== false),
                DISALLOWED = [32];

            if (HASHTAG || $.inArray(key, DISALLOWED) > -1) {
                e.preventDefault();
                return true;
            }

            return false;

        }

        function isEscape(e) {
            var key = e.keyCode ? e.keyCode : e.which;


            if (key !== 27)
                return false;

            return true;
        }

        function isBackspace(e) {
            var key = e.keyCode ? e.keyCode : e.which;

            if (key !== 8)
                return false;

            return true;
        }

        function isReturn(e) {
            var key = e.keyCode ? e.keyCode : e.which;

            if (key !== 13)
                return false;

            return true;
        }

        function isEmpty(val) {
            var reg = /([\S]+[\s]*)*[\S]+/g,
                validated = reg.test(val.trim());

            return !validated;
        }

        function hasTags() {
            return (a.find('.of-tag').length > 0);
        }

        function removeLastTag(index) {

            index = typeof index !== 'undefined' ? index : false;

            // Removed by click..
            if (index !== false) {
                var tag = a.find('.of-tag[data-index=' + index + ']');

                tag.remove();
                used.splice(used.indexOf(index), 1);

                updateHiddenField();
                populateList(false);

                return false;
            }

            if (el.val().length === 0) {
                var tag = a.find('.of-tag').last(),
                    index = tag.data('index');

                tag.remove();
                used.splice(used.indexOf(index), 1);

                updateHiddenField();
                populateList(false);
            }

            return false;

        }

        function updateHiddenField() {
            var hidden = el.parent().parent().parent().find('input[type="hidden"]');

            if(hidden.length === 0) {
                var hidden = $('<input type="hidden" name="' + el.attr('name') + '_tags">');
                el.parent().parent().parent().append(hidden);
            }

            hidden.val(used.join(', '));
        }

        function appendTag(index) {
            var tag = $('<div class="of-tag of-icon"><span></span><i><a href="#" tabindex="-1"><svg viewBox="0 0 512 512"><use xlink:href="#close"></use></svg></a></i></div>');
            index = typeof index !== 'undefined' ? index : false;

            if (index === false) {


                data.push(el.val().toLowerCase());

                index = el.val().toLowerCase();

                el.val('');
            }

            tag.attr('data-index', index);
            tag.find('span').text('#' + index);

            tag.insertBefore(el);
            used.push(index);

            updateHiddenField();

            tag.find('a').on('click tap', function(e) {
                e.preventDefault();

                removeLastTag($(this).parents('.of-tag').data('index'));

            });
        }

        function populateList(results) {


            var parent = header.parent(),
                wrap = header.next();

            if (!wrap.hasClass('of-autocomplete-wrap')) {

                wrap = $('<article>').addClass('of-autocomplete-wrap').insertAfter(header);

            }

            var list = wrap.find('ul');

            if (list.length === 0)
                list = $('<ul/>').appendTo(wrap);

            if (typeof results === 'boolean') {
                list.empty();
                a.removeClass('active');

                if (results !== false)
                    used = [];

                return false;
            }

            if (typeof results !== 'string') {
                list.empty();
                // parent.removeClass('active');
            }

            if (typeof results === 'object') {
                for (var i = 0, il = results.length; i < il; i++) {
                    var index = results[i].toLowerCase(),
                        result = '#' + index,
                        li = $('<li>').text(result).data('index', index);

                    if (used.indexOf(index) > -1) {
                        li.addClass('disabled');
                    }

                    list.append(li);
                }


                if (list.find('li').length > 0 && results.indexOf(el.val().toLowerCase()) < 0 && el.val().length >= MIN_LENGTH) {

                    var index = el.val().toLowerCase(),
                        val = '#' + index,
                        li = $('<li>').text(val);

                    if (used.indexOf(index) > -1) {

                        li.addClass('disabled');
                    }

                    li.appendTo(list);
                }

                list.find('li').not('.disabled').first().addClass('current');
                parent.addClass('active');
                return false;
            }

            if (typeof results === 'string') {

                if (el.val().length < MIN_LENGTH)
                    return false;

                if (list.find('li').length > 0) {

                    list.find('li').not(':first').remove();

                    var li = list.find('li');
                    li.removeClass('disabled').addClass('current').removeData('index').text(results);

                    return false;
                }

                var li = $('<li>');
                li.addClass('current').text(results);

                list.append(li);
                parent.addClass('active');

            }

        }

    }

    $.fn.ofAutoResize = function() {
        var el = $(this),
            ph = $('<div>').addClass('of-auto-resize-clone').insertBefore(el),
            content = null;

        el.addClass('of-auto-resize');

        el.on('change', resize);

        el.on('cut paste drop keydown', delayedResize);

        function resize() {

            content = htmlEscape(el.val());
            content.replace(/\n/g, '<br>');

            ph.html(content + '<br class="lbr">');

            el.css('height', ph.height());

        }

        function delayedResize() {
            setTimeout(function() {
                resize();
            }, 0);
        }

        function htmlEscape(str) {
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;');
        }

        resize();

    }

    $.fn.caret = function(pos) {
        var target = this[0];
        var isContentEditable = target.contentEditable === 'true';
        //get
        if (arguments.length == 0) {
            //HTML5
            if (window.getSelection) {
                //contenteditable
                if (isContentEditable) {
                    target.focus();
                    var range1 = window.getSelection().getRangeAt(0),
                        range2 = range1.cloneRange();
                    range2.selectNodeContents(target);
                    range2.setEnd(range1.endContainer, range1.endOffset);
                    return range2.toString().length;
                }
                //textarea
                return target.selectionStart;
            }
            //IE<9
            if (document.selection) {
                target.focus();
                //contenteditable
                if (isContentEditable) {
                    var range1 = document.selection.createRange(),
                        range2 = document.body.createTextRange();
                    range2.moveToElementText(target);
                    range2.setEndPoint('EndToEnd', range1);
                    return range2.text.length;
                }
                //textarea
                var pos = 0,
                    range = target.createTextRange(),
                    range2 = document.selection.createRange().duplicate(),
                    bookmark = range2.getBookmark();
                range.moveToBookmark(bookmark);
                while (range.moveStart('character', -1) !== 0) pos++;
                return pos;
            }
            //not supported
            return 0;
        }
        //set
        if (pos == -1)
            pos = this[isContentEditable ? 'text' : 'val']().length;
        //HTML5
        if (window.getSelection) {
            //contenteditable
            if (isContentEditable) {
                target.focus();
                window.getSelection().collapse(target.firstChild, pos);
            }
            //textarea
            else
                target.setSelectionRange(pos, pos);
        }
        //IE<9
        else if (document.body.createTextRange) {
            var range = document.body.createTextRange();
            range.moveToElementText(target);
            range.moveStart('character', pos);
            range.collapse(true);
            range.select();
        }
        if (!isContentEditable)
            target.focus();
        return pos;
    }

}(jQuery);

var OF_Form = function(element, options) {

    var form = this;
    this.element = element;
    this.$element = $(element);
    this.options = {
        shouldValidate: true,
        scrollToError: true,
        scrollToErrorSpeed: 100,
        lang: {
            mustNotBeEmpty: 'F�ltet f�r inte vara tomt',
            mustChoose: 'Du m�ste v�lja minst %d alternativ',
            mustBeEmail: 'F�ltet m�ste vara en e-postadress',
            mustBeNumeric: 'F�ltet f�r endast inneh�lla siffror',
            defaultError: 'F�ltet validerar inte',
            mustMatch: 'L�senorden �verrensst�mmer inte'
        }
    };

    this.parseOptions = function(options) {};

    this.appendError = function(el, errorText) {
        var input = el.find('input, textarea, select').get().length ? el.find('input, textarea, select') : false,
            errorIcon = $('<i><svg viewBox="0 0 512 512"><use xlink:href="#error"></use></svg></i>'),
            errorDescription = $('<span class="description error"></span>')

        el.addClass('of-input-error of-icon');

        errorDescription.clone().text(errorText).appendTo(el);
        if (input !== false)
            errorIcon.clone().appendTo(el);
    };

    this.appendValid = function(el) {
        var input = el.find('input, textarea, select').get().length ? el.find('input, textarea, select') : false,
            validIcon = $('<i><svg viewBox="0 0 512 512"><use xlink:href="#checkmark"></use></svg></i>');

        el.addClass('of-input-valid of-icon');
        if (input !== false)
            validIcon.appendTo(el);

    };

    this.dropNotifications = function(e) {
        var el = typeof e.target !== 'undefined' ? $(e.target).parent() : $(e);

        if (el.hasClass('of-input-error') || el.hasClass('of-input-valid')) {
            el.removeClass('of-input-error of-input-valid of-icon').find('i').remove().end().find('.error').remove();
        }
    };

    this.validate = function(e) {


        var el = typeof e.target !== 'undefined' ? ($(e.target).attr('type') === 'checkbox' || $(e.target).attr('type') === 'radio' ? $('label[data-of-for="' + $(e.target).attr('name') + '"]') : $(e.target).parent()) : $(e);

        if (typeof el.data('of-required') === 'undefined')
            return;

        var validation = el.data('of-required').split(':'),
            input = el.find('input, textarea, select'),
            errors = 0,
            shouldExit = false;

        if (validation[0] !== 'match_password') {
            form.dropNotifications(el);
        } else {
            var fields = $('input[type="password"]'),
                fieldsLength = fields.length - 1;

            fields.each(function(i) {

                var reg = /([\S]+[\s]*)*[\S]+/g,
                    validated = reg.test($(this).val().trim());

                if (validated === false)
                    shouldExit = true;

                form.dropNotifications($(this).parent());
            });
        }

        if (shouldExit !== false && input.index('input[type="password"]') < 1)
            return false;

        switch (validation[0]) {
            case '':

                if (typeof el.data('of-for') !== 'undefined') {

                    var name = el.data('of-for'),
                        chosen = $('input[name="' + name + '"]:checked').length;

                    if (chosen !== 1) {
                        ++errors;

                        form.appendError(el, form.options.lang.mustNotBeEmpty);
                    }

                } else {
                    var reg = /([\S]+[\s]*)*[\S]+/g,
                        validated = reg.test(input.val().trim());

                    if (validated === false) {
                        ++errors;

                        form.appendError(el, form.options.lang.mustNotBeEmpty);
                    }
                }
                break;
            case 'choose':
                var amount = validation[1],
                    name = el.data('of-for'),
                    chosen = $('input[name="' + name + '"]:checked').length;

                if (amount > chosen) {
                    ++errors;

                    form.appendError(el, form.options.lang.mustChoose.replace('%d', amount));
                }

                break;
            case 'email':
                var reg = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
                    validated = reg.test(input.val());

                if (validated === false) {
                    ++errors;

                    form.appendError(el, form.options.lang.mustBeEmail);
                }

                break;

            case 'number':
                var reg = new RegExp(/^[+-]?(?=.|,)(?:\d+,)*\d*(?:\.\d+)?$/),
                    validated = reg.test(input.val());

                if (validated === false) {
                    ++errors;

                    form.appendError(el, form.options.lang.mustBeNumeric);
                }

                break;

            case 'match_password':

                var fields = $('input[type="password"]'),
                    validated = false,
                    val = false,
                    empty = false;

                fields.each(function() {

                    if (val === false) {
                        val = $(this).val();
                        return true;
                    }

                    if ($(this).val() === val) {
                        validated = true;
                        return true;
                    }

                    validated = false;
                    return true;
                });

                if (validated !== false) {
                    var reg = /([\S]+[\s]*)*[\S]+/g;

                    empty = true;
                    validated = reg.test(input.val().trim());
                }

                if (validated === false) {
                    ++errors;

                    fields.each(function() {
                        form.appendError($(this).parent(), empty !== false ? form.options.lang.mustNotBeEmpty : form.options.lang.mustMatch);
                    });
                }

                break;
            default:
                var reg = new RegExp(validation),
                    validated = reg.test(input.val());

                if (validated === false) {
                    ++errors;

                    form.appendError(el, form.options.lang.defaultError);
                }

                break;
        }

        if (errors === 0) {

            if (validation[0] !== 'match_password') {
                form.appendValid(el);
            } else {
                var fields = $('input[type="password"]')

                fields.each(function() {

                    form.appendValid($(this).parent());
                });
            }

        }

        return errors;

    };

    this.bindUiActions = function() {

        if (this.options.shouldValidate !== false) {

            var form = this,
                errors = 0;

            $(document).on('blur', 'input, textarea, select', form.validate);

            $(document).on('change', 'input[type=checkbox], input[type=radio], select', form.validate);

            this.$element.on('submit', function() {

                form.$element.find('[data-of-required]').each(function(i, label) {
                    form.dropNotifications(label);
                    errors += form.validate($(label));
                });

                if (form.options.scrollToError !== false && errors > 0) {
                    $('html, body').animate({
                        scrollTop: $('.of-input-error').first().offset().top
                    }, form.options.scrollToErrorSpeed, function() {
                        $('.of-input-error').first().find('input, select, textarea').focus();
                    });
                }

                if (errors === 0)
                    return true;

                // return false;
            });

        }

    };


    this.bindUiActions();
};

var OF_Select = function(element, options) {

    this.element = element;
    this.$element = $(element);

    this.parseOptions = function(options) {

        var el = this.element,
            defaults = {
                multiple: el.multiple
            };

        if (typeof options === 'undefined') {
            return defaults;
        }

        for (var key in options) {
            defaults[key] = options[key];
        }

        return defaults;
    };

    this.handle = function() {

        // Hide all select-boxes, we will be replacing them with custom ones.
        this.$element.hide();

        // Definitions
        var el = this.$element,
            options = el.find('option'),
            optgroup = false,
            multiple = (typeof el.attr('multiple') !== 'undefined'),
            selected = [],
            a = $('<div/>').addClass(multiple !== false ? 'of-select-multiple' : 'of-select'),
            b = $('<header class="of-icon"><span></span>'),
            ba = multiple === false ? $('<i><svg viewBox="0 0 512 512"><use xlink:href="#arrow-down"></use></svg></i><i><svg viewBox="0 0 512 512"><use xlink:href="#arrow-up"></use></svg></i>') : false,
            c = $('<article/>'),
            d = $('<ul/>'),
            dTop = 0,
            e = $('<li/>'),
            f = $('<div class="of-tag of-icon"><span></span><i><a href="#" tabIndex="-1"><svg viewBox="0 0 512 512"><use xlink:href="#close"></use></svg></a></i></div>');

        // If the select element has classes, insert them to the custom one
        if (typeof el.attr('class') !== 'undefined')
            a.addClass(el.attr('class'));

        // Append arrows if the select box does not allow multiple choices, otherwise, make header > span editable to act as input.
        if (multiple === false) {
            ba.appendTo(b);
        } else {
            b.find('> span').attr('contenteditable', true);
        }

        // If select should be inline, add width: auto;
        if (el.data('of-select') === 'inline') {
            a.css({
                width: 'auto',
                display: 'inline-block'
            });
        }

        $(window).on('keydown', function(e) {

            var key = e.keyCode ? e.keyCode : e.which;

            // Single: If select box has focus and is opened, select active option on RETURN / SPACE key press
            if (a.is(':focus') && a.hasClass('active') && (key == 13 || key == 32)) {
                e.stopPropagation();
                e.preventDefault();

                a.find('li.selected').trigger('click');

                return false;

            }

            // Single: If select box has focus and is closed, open it on RETURN / SPACE / UP / DOWN key press
            if ((a.is(':focus') && !a.hasClass('active')) && (key == 13 || key == 32 || key == 38 || key == 40)) {
                e.stopPropagation();
                e.preventDefault();

                a.addClass('active');

                return false;
            }

            // Single: If select box has focus and is open, move down one option per DOWN key press
            if (a.is(':focus') && a.hasClass('active') && key == 40) {
                e.preventDefault();
                var firstEl = a.find('li').first();

                if (a.find('li.selected').length > 0) {
                    firstEl = a.find('li.selected').last();
                }

                if (firstEl.nextAll(':not(.group, .disabled):visible').first().length === 0)
                    return;

                firstEl.removeClass('selected');
                firstEl.nextAll(':not(.group, .disabled):visible').first().addClass('selected');

                return false;

            }

            // Single: If select box has focus and is open, move up one option per UP key press
            if (a.is(':focus') && a.hasClass('active') && key == 38) {
                e.preventDefault();
                var firstEl = a.find('li').first();

                if (a.find('li.selected').length > 0) {
                    firstEl = a.find('li.selected').last();
                }

                if (firstEl.prevAll(':not(.group, .disabled):visible').first().length === 0)
                    return;

                firstEl.removeClass('selected');
                firstEl.prevAll(':not(.group, .disabled):visible').first().addClass('selected');

                return false;

            }

            // Multiple: If select box has focus and is closed open it by pressing ENTER / UP / DOWN key press
            if ((b.find('> span').is(':focus') && !a.hasClass('active')) && (key == 13 || key == 38 || key == 40)) {
                e.stopPropagation();
                e.preventDefault();

                a.addClass('active');

                return false;
            }

            // Multiple: If select box has focus and is opened, select active option on RETURN / SPACE key press
            if (a.hasClass('active') && b.find('> span').is(':focus') && (key == 13)) {
                e.stopPropagation();
                e.preventDefault();

                a.find('.current').trigger('click');
                a.addClass('active');

                a.nextAll(':not(.group, .selected, disabled):visible').first().addClass('current');

                return false;
            }

            // Multiple: If select box has focus and is open, move down one option per DOWN key press
            if (b.find('> span').is(':focus') && a.hasClass('active') && key == 40) {
                e.preventDefault();
                var firstEl = a.find('li').first();

                if (a.find('li.current').length > 0) {
                    firstEl = a.find('li.current').last();
                }

                if (firstEl.nextAll(':not(.group, .disabled, .selected):visible').first().length === 0)
                    return;

                firstEl.removeClass('current');
                var next = firstEl.nextAll(':not(.group, .disabled, .selected):visible').first();
                next.addClass('current');

                if (next.offset().top > (c.scrollTop() + c.height())) {

                    c.animate({
                        scrollTop: ((next.offset().top - d.offset().top) - (c.height() - next.height()) + 'px')
                    }, 0);

                }

                return false;

            }

            // Multiple: If select box has focus and is open, move up one option per UP key press
            if (b.find('> span').is(':focus') && a.hasClass('active') && key == 38) {
                e.preventDefault();
                var firstEl = a.find('li').first();

                if (a.find('li.current').length > 0) {
                    firstEl = a.find('li.current').last();
                }

                if (firstEl.prevAll(':not(.group, .disabled, .selected):visible').first().length === 0)
                    return;

                firstEl.removeClass('current');
                var prev = firstEl.prevAll(':not(.group, .disabled, .selected):visible').first();
                prev.addClass('current');


                //console.log(prev.offset().top, c.offset().top, d.offset().top, c.height(), prev.height());

                if (prev.offset().top < c.offset().top) {
                    var to = 0;
                    if (d.find('.group') !== false) {
                        if (prev.prev().hasClass('group')) {
                            to = 0;
                        } else {
                            to = prev.offset().top - d.offset().top;
                        }
                    } else {
                        to = prev.offset().top - d.offset().top;
                    }


                    c.animate({
                        scrollTop: (to + 'px')
                    }, 0);
                }

                // TODO: Vid pil upp m�ste scrollen h�nga med...

                return false;

            }

        });

        // Append children to the custom select

        b.appendTo(a);
        d.appendTo(c);
        c.appendTo(a);

        // Insert custom select after the original one
        a.insertAfter(el);

        // If touch device insert native select box
        if (Modernizr.touch && multiple !== true) {
            el.show();
        }

        a.prepend(el);
        d.Top = d.offset().top;

        // console.log(multiple, a.attr('class'));

        if (multiple !== false) {
            // Handle multiple
            var participantSelect = (typeof el.data('of-participant-select') !== 'undefined');

            // Remove last tag selected on BACKSPACE
            b.find('> span').on('keydown', function(e) {

                var key = e.keyCode ? e.keyCode : e.which;

                if (key === 8 && $(this).text().length === 0 && b.find('.of-tag').length > 0) {
                    b.find('.of-tag').last().remove();
                }

            }).on('keyup', function(e) {

                // Search options

                var key = e.keyCode ? e.keyCode : e.which,
                    fullVal = $(this).text(),
                    val = fullVal.toLowerCase().trim(),
                    reg,
                    errorLi = $('<li/>').addClass('error').text('Inga poster matchade s�kningen "' + fullVal + '"');
                try {
                    reg = new RegExp(val, 'g');
                } catch (e) {
                    reg = new RegExp('', 'g');
                }

                if (key === 40 || key === 38)
                    return false;

                a.addClass('active');

                d.find('.group').hide();
                d.find('.error').remove();

                var x = 0;
                d.find('li').not('.group').hide().removeClass('current').each(function(i, el) {
                    if (reg.test($(el).text().toLowerCase().trim())) {
                        if (!$(el).hasClass('disabled') && !$(el).hasClass('selected'))
                            x++;
                        $(el).show();

                        if (x === 1)
                            $(el).addClass('current');

                        $(el).prevAll('.group:first').show();
                    }
                });

                if (d.find('li:visible').length === 0) {
                    errorLi.clone().appendTo(d);
                }

            }).on('focus', function() {
                var x = 0;
                d.find('li').not('.group').hide().removeClass('current').each(function(i, el) {
                    if (!$(el).hasClass('disabled') && !$(el).hasClass('selected'))
                        x++;
                    $(el).show();

                    if (x === 1)
                        $(el).addClass('current');

                    $(el).prevAll('.group:first').show();
                });
            }).on('blur', function(e) {
                if (e.relatedTarget !== null)
                    a.removeClass('active');
            });

        }

        a.on('focus', function(e) {
            e.stopPropagation();
            e.preventDefault();

            // a.addClass('active');

        }).on('blur', aBlurEvent);


        function aBlurEvent(e) {
            a.removeClass('active');
        }

        // Loop through available options and append them
        options.each(function(index) {
            var option = $(this),
                parent = option.parent(),
                hasGroup = parent.is('optgroup'),
                newEl = e.clone();

            // console.log(hasGroup);

            if (hasGroup !== false) {
                if (parent.attr('label') !== optgroup) {
                    var group = e.clone().addClass('group').text(parent.attr('label')).appendTo(d);

                    group.on('click', function(e) {
                        e.stopPropagation();
                        e.preventDefault();
                    });
                }

                newEl.addClass('child');

                optgroup = parent.attr('label');
            }

            if (option.prop('disabled') !== false) {
                // Disabled
                newEl.addClass('disabled');
            }

            if (option.prop('selected') !== false) {
                // Selected
                selected.push(index);
                newEl.addClass('selected');

                if (multiple === false) {
                    b.find('span').text(option.text());
                } else {
                    b.addClass('of-has-tags');
                    var tag = f.clone().attr('data-index', index),
                        tagA = tag.find('a');
                    tag.find('span').text(option.text());
                    tag.insertBefore(b.find('> span'));

                    tagA.on('click', function(e) {
                        e.stopPropagation();
                        e.preventDefault();

                        tag.remove();

                        if (b.find('.of-tag').length === 0) {
                            b.removeClass('of-has-tags');
                        }

                    });

                    tag.on('remove', function() {
                        el.find('option').eq(tag.data('index')).removeAttr('selected');
                        newEl.removeClass('selected');
                    });
                }
            }

            newEl.attr({
                'data-index': index,
                'title': option.text()
            }).text(option.text());

            var link = false;

            if (typeof option.data('href') !== 'undefined') {
                var tmp = newEl.text(),
                    link = $('<a>').attr('href', option.data('href')).text(tmp);

                if (typeof option.data('target') !== 'undefined')
                    link.attr('target', option.data('target'));

                newEl.text('');
                link.appendTo(newEl);

                link.on('mousedown', function(e) {
                    a.off('blur');
                })
                .on('mouseup', function(e) {
                    setTimeout(function() {
                        a.on('blur', aBlurEvent);
                    }, 100);
                })

                .on('click', function(e) {
                    e.stopPropagation();

                    if (newEl.hasClass('disabled'))
                        return false;

                    return true;
                });
            }

            newEl.appendTo(d);

            if(link === false) {
                newEl.on('click', function(e) {
                e.stopPropagation();
                e.preventDefault();

                if (newEl.hasClass('disabled') || (newEl.hasClass('selected') && multiple !== false))
                    return;

                // Multiple option

                if (multiple !== false) {
                    c.animate({
                        scrollTop: '0px'
                    }, 0);

                    if (participantSelect === false) {
                        var tag = f.clone().attr('data-index', index),
                            tagA = tag.find('a');
                        b.addClass('of-has-tags');
                    } else {
                        var selectedList = $('ul[data-of-selected="' + el.attr('name') + '"]'),
                            tag = selectedList.find('.of-placeholder').clone().removeClass('of-placeholder').attr('data-index', index),
                            tagA = tag.find('a.remove-item');
                    }

                    if (participantSelect === false) {
                        tag.find('span').text(newEl.text());
                        tag.insertBefore(b.find('> span'));
                    } else {

                        $.getJSON('json/deltagare.php', {
                            sensor: false,
                            id: index
                        }, function(response) {

                            tag.find('u[data-of-placeholder="name"]').replaceWith(response.name);

                            // for (var i = 0, il = response.metaline.length; i < il; i++) {
                            //     $('<li/>').text(response.metaline[i]).appendTo(tag.find('.of-meta-line'));
                            // }

                            tag.find('select').attr({
                                'name': 'participant_' + response.id
                            });

                            // tag.find('select').on('change', function() {

                            //     $(this).parent().parent().prevAll('li').first().text($(this).find('option:selected').text());

                            // });

                            tag.find('img').attr({
                                'src': response.image_source, // TODO: 2x support?
                                'alt': response.name
                            });

                            selectedList.prepend(tag);
                        });
                    }
                    b.find('> span').text('');
                    b.find('> span').trigger('focus')

                    tagA.on('click', function(e) {
                        e.stopPropagation();
                        e.preventDefault();

                        tag.remove();

                        if (b.find('.of-tag').length === 0) {
                            b.removeClass('of-has-tags');
                        }

                    });

                    tag.on('remove', function() {
                        el.find('option').eq(tag.data('index')).removeAttr('selected');
                        newEl.removeClass('selected');
                    });

                    newEl.addClass('selected');
                    el.find('option').eq(index).prop('selected', 'selected');


                    a.removeClass('active');

                    return false;
                }

                // Single option

                a.find('li').removeClass('selected');
                newEl.addClass('selected');
                b.find('span').text(newEl.text());

                if (multiple !== false && e.shiftKey === false)
                    el.find('option').removeProp('selected');

                el.find('option').eq(index).prop('selected', 'selected').trigger('change');

                a.removeClass('active');
            });
            }

            newEl.on('mouseover', function() {

                if ($(this).hasClass('selected') || $(this).hasClass('disabled'))
                    return false;

                if (multiple !== false) {
                    a.find('.current').not(newEl).removeClass('current');
                    newEl.addClass('current');
                }

                return false;


            });

        });

        if (selected.length === 0 && multiple === false) {
            a.find('li:not(disabled)').first().addClass('selected');
        }

        b.on('click', function(e) {
            e.stopPropagation();
            e.preventDefault();

            $('.of-select, .of-select-multiple').not(a).removeClass('active');

            a.toggleClass('active');

            if (multiple !== false) {
                b.find('> span').focus();
            }

            return false;

        });

        $(document).on('click', function(e) {
            a.removeClass('active');
        });

        $(window).on('keyup', function(e) {

            var key = e.keyCode ? e.keyCode : e.which;

            if (key == 27) {
                e.preventDefault();
                e.stopPropagation();
                a.removeClass('active');

                return false;
            }

            if (a.is(':focus')) {

                if (key === 40 || key === 38) {
                    e.preventDefault();
                    a.addClass('active');
                }

            }

        });

        el.on('change', function(e) {

            if (multiple === false) {

                b.find('span').text($(this).find('option:selected').text());

                return;
            }

            if (participantSelect === false) {
                b.addClass('of-has-tags');

                $(this).parent().find('.of-tag').hide();
            } else {
                var selectedList = $('ul[data-of-selected="' + el.attr('name') + '"]');
                // selectedList.find('li:not(.of-placeholder)').hide();

            }

            $(this).parent().find('li.selected').removeClass('selected');

            if ($(this).find('option:selected').length === 0)
                return;

            $(this).find('option').each(function(index, option) {


                if ($(option).prop('selected') === false) {

                    if (participantSelect === false) {
                        $('.of-tag[data-index="' + index + '"]').remove();
                    } else {
                        selectedList.find('[data-index="' + index + '"]').remove();
                    }

                    return true;
                }

                var newEl = $(option);

                if (participantSelect === false) {
                    var tag = f.clone().attr('data-index', index),
                        tagA = tag.find('a');
                } else {
                    var tag = selectedList.find('.of-placeholder').clone().removeClass('of-placeholder').attr('data-index', index),
                        tagA = tag.find('a.remove-item');
                }

                b.find('> span').text('');

                if (participantSelect === false) {
                    tag.find('span').text(newEl.text());
                    tag.insertBefore(b.find('> span'));
                } else {

                    // console.log(selectedList.find('[data-index="' + index + '"]').length);

                    if (selectedList.children('[data-index="' + index + '"]').length > 0)
                        return true;

                    $.getJSON('/json/deltagare.php', {
                        sensor: false,
                        id: index
                    }, function(response) {

                        tag.find('u[data-of-placeholder="name"]').replaceWith(response.name);

                        // for (var i = 0, il = response.metaline.length; i < il; i++) {
                        //     $('<li/>').text(response.metaline[i]).appendTo(tag.find('.of-meta-line'));
                        // }

                        tag.find('select').attr({
                            'name': 'participant_' + response.id
                        });

                        tag.find('img').attr({
                            'src': response.image_source,
                            'alt': response.name
                        });

                        selectedList.prepend(tag);
                    });
                }

                tagA.on('click', function(e) {
                    e.stopPropagation();
                    e.preventDefault();

                    tag.remove();

                    if (b.find('.of-tag').length === 0) {
                        b.removeClass('of-has-tags');
                    }

                });

                tag.on('remove', function() {
                    el.find('option').eq(tag.data('index')).removeAttr('selected');
                    newEl.removeClass('selected');
                });

                newEl.addClass('selected');
                el.find('option').eq(index).prop('selected', 'selected');
                a.removeClass('active');

                return true;

            });

        });

        if (multiple === false)
            a.attr('tabIndex', '0');

        if (el.data('of-select') === 'inline') {

            var newWidth = 0;

            a.css('width', 1000);
            a.find('article').show();
            a.find('li').each(function() {

                $(this).css({
                    'display': 'inline-block',
                    'white-space': 'nowrap'
                });

                var width = $(this).outerWidth() + 24;

                $(this).removeAttr('style');

                // console.log($(this).text(), width);

                if (width <= newWidth)
                    return true;

                newWidth = width;
            });
            a.find('article').removeAttr('style');
            a.css({
                'max-width': newWidth,
                'width': '100%'
            });
            a.addClass('of-select-inline');
        }
    };

    this.handleToggle = function() {
        this.$element.hide();

        // Create toggle button and hide original select box.

        var el = this.$element,
            a = $('<div/>').addClass('of-toggle').attr('tabIndex', 0),
            b = $('<span/>').addClass('handle');

        el.find('option').each(function() {
            if ($(this).is(':selected') && $(this).val() === '1') {
                a.addClass('true');
            }
        });

        a.attr('data-true', el.find('option[value="1"]').text());
        a.attr('data-false', el.find('option[value="0"]').text());

        b.appendTo(a);
        a.insertAfter(el);

        el.hide();

        a.on('click', function(e) {
            e.preventDefault();

            if ($(this).hasClass('true')) {
                el.val('0');
                $(this).removeClass('true');
                el.trigger("change");
                return;
            }

            el.val('1');
            el.trigger("change");
            $(this).addClass('true');
        });

        $(window).on('keydown', a, function(e) {
            var key = e.keyCode ? e.keyCode : e.which;

            if (a.is(':focus') && key === 32) {
                e.preventDefault();

                if (a.hasClass('true')) {
                    el.val('0');
                    a.removeClass('true');
                    return false;
                }

                el.val('1');
                a.addClass('true');
                return false;
            }

        });

    };

    this.options = this.parseOptions(options);

    if (this.$element.data('of-select') === 'toggle') {
        this.handleToggle();
        return;
    }

    this.handle();

    // console.log(this.element.tabIndex);

};

jQuery(function($) {
    $.datepicker.regional['sv_SE'] = {
        closeText: 'St�ng',
        prevText: 'F�reg�ende m�nad',
        nextText: 'N�sta m�nad',
        currentText: 'LOL',
        monthNames: ['Januari', 'Februari', 'Mars', 'April', 'Maj', 'Juni',
            'Juli', 'Augusti', 'September', 'Oktober', 'November', 'December'
        ],
        monthNamesShort: ['Jan', 'Feb', 'Mar', 'Apr', 'Maj', 'Jun',
            'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dec'
        ],
        dayNames: ['S�ndag', 'M�ndag', 'Tisdag', 'Onsdag', 'Torsdag', 'Fredag', 'L�rdag'],
        dayNamesShort: ['S�n', 'M�n', 'Tis', 'Ons', 'Tor', 'Fre', 'L�r'],
        dayNamesMin: ['S�', 'M�', 'To', 'On', 'To', 'Fr', 'L�'],
        weekHeader: 'V',
        dateFormat: 'yy-mm-dd',
        firstDay: 1,
        isRTL: false,
        showMonthAfterYear: false,
        yearSuffix: ''
    };
    $.datepicker.setDefaults($.datepicker.regional['sv_SE']);
});
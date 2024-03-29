var ofCalendars = {};
var idsExists = new Array(),
    dayTemplate,
    currentEvents,
    activeDay = new Date();
activeDay.setHours(0, 0, 0, 0);

(function($) {

    "use strict";

    $(function() {
        $.support.cors = true;
        moment.locale('sv-SE');

        if (typeof ofCalendarInitialEvents === 'undefined') {
            return;
        }

        setupTodaysEvents(ofCalendarInitialEvents.posts);
        var initializedCalendars = [];

        $('.of-calendar').each(function(calendarIndex) {
            var el = $(this),
                elAsParent = el,
                isWidget = el.hasClass('of-widget');

            var context = isWidget ? $('#of-calendar-widget-template').html() : $('#of-calendar-template').html(),
                dayContext = isWidget ? $('#of-day-template').html() : $('#of-day-template').html(),
                template = Handlebars.compile(context);
            dayTemplate = isWidget ? false : Handlebars.compile(dayContext);
            var daysOfTheWeek = isWidget ? ['M�', 'Ti', 'On', 'To', 'Fr', 'L�', 'S�'] : ['M�<span class="of-hide-to-sm">ndag</span>', 'Ti<span class="of-hide-to-sm">sdag</span>', 'On<span class="of-hide-to-sm">sdag</span>', 'To<span class="of-hide-to-sm">rsdag</span>', 'Fr<span class="of-hide-to-sm">edag</span>', 'L�<span class="of-hide-to-sm">rdag</span>', 'S�<span class="of-hide-to-sm">ndag</span>'];


            var cal = $(this).clndr({
                startWithMonth: moment(),
                daysOfTheWeek: daysOfTheWeek,
                events: ofCalendarInitialEvents.posts,
                render: function(data) {

                    var container = $(this).find('article.day ul'),
                        loadingLi = $('<li/>');

                    data.currentEvents = ofCalendarTodaysEvents;
                    if (!initializedCalendars[calendarIndex]) {
                        data.currentEvents = ofCalendarTodaysEvents;

                        initializedCalendars[calendarIndex] = true;
                        console.log(data);
                    }

                    return template(data);
                },
                adjacentDaysChangeMonth: true,
                clickEvents: {
                    click: function(target) {
                        var el = $(target.element),
                            events = target.events,
                            parent = el.closest('.calendar-row');

                        if (el.hasClass('disabled') || !el.hasClass('activities') || el.hasClass('adjacent-month'))
                            return;

                        if (isWidget) {

                            var container = el.parents('.of-calendar').find('article.day ul'),
                                loadingLi = $('<li/>');

                            container.empty();
                            loadingLi.appendTo(container).ofLoading();

                            container.html(getWidgetDay(events));
                            currentEvents = events;

                            elAsParent.find('.active').removeClass('active');

                            el.addClass('active');

                            activeDay = new Date(target.date._d);

                            setupTodaysEvents(events, activeDay);

                            return;
                        }

                        if (el.hasClass('active')) {
                            el.removeClass('active');
                            $('.calendar-day').slideUp(300);
                            return;
                        }

                        $('.of-calendar a').removeClass('active').ofLoading(false);

                        el.addClass('active').ofLoading();

                        if ($('.calendar-day').length > 0) {
                            $('.calendar-day').slideUp(300, function() {
                                $('.calendar-day').remove();
                                openDay(el, events, parent);
                            });
                        } else {
                            openDay(el, events, parent);
                        }

                    },
                    onMonthChange: function(month) {
                        var old_month = month;
                        month = new Date(month._d).toGregorian();

                        $.ajax({
                            crossDomain: true,
                            dataType: 'json',
                            type: 'POST',
                            url: ofCalendarAjaxUrl,
                            data: {
                                month: month
                            },
                            success: function(response) {

                                $('#of-month-ph').html(old_month.format('MMMM YYYY').toUcFirst());

                                cal.setEvents(response.posts);

                            },
                            error: function(jqXHR, textStatus, errorThrown) {
                                console.error(jqXHR);
                                console.error(textStatus);
                                console.error(errorThrown);
                            }
                        });
                    }
                }
            });

            ofCalendars[$(this).attr("id")] = cal;
            
        });

        function openDay(el, events, parent) {
            var data = {};

            data.events = events;
            data.day = moment(new Date(data.events[0]._clndrDateObject._d)).format('D MMMM YYYY');


            var day = $(dayTemplate(data));

            day.insertAfter(parent).find('h2 span').text(el.find('> span').text());
            day.slideDown(300);
            el.ofLoading(false);


            $('body, html').animate({
                scrollTop: (day.parent().offset().top) + 'px'
            }, 0);
        }
    });

}(jQuery));

Date.prototype.toGregorian = function(show_day_of_month) {

    show_day_of_month = typeof show_day_of_month !== 'undefined' ? show_day_of_month : false;

    var yyyy = this.getFullYear().toString(),
        mm = (this.getMonth() + 1).toString(),
        dd = this.getDate().toString();

    var response = yyyy + '-' + (mm[1] ? mm : "0" + mm[0]);

    if (show_day_of_month !== false)
        response += '-' + (dd[1] ? dd : "0" + dd[0]);

    return response;
};



(function(root, factory) {
    if (typeof define === 'function' && define.amd) {
        define([], factory);
    } else if (typeof exports === 'object') {
        module.exports = factory();
    } else {
        root.Handlebars = root.Handlebars || factory();
    }
}(this, function() {
    // handlebars/safe-string.js
    var __module4__ = (function() {
        "use strict";
        var __exports__;
        // Build out our basic SafeString type
        function SafeString(string) {
            this.string = string;
        }

        SafeString.prototype.toString = function() {
            return "" + this.string;
        };

        __exports__ = SafeString;
        return __exports__;
    })();

    // handlebars/utils.js
    var __module3__ = (function(__dependency1__) {
        "use strict";
        var __exports__ = {};
        /*jshint -W004 */
        var SafeString = __dependency1__;

        var escape = {
            "&": "&amp;",
            "<": "&lt;",
            ">": "&gt;",
            '"': "&quot;",
            "'": "&#x27;",
            "`": "&#x60;"
        };

        var badChars = /[&<>"'`]/g;
        var possible = /[&<>"'`]/;

        function escapeChar(chr) {
            return escape[chr];
        }

        function extend(obj /* , ...source */ ) {
            for (var i = 1; i < arguments.length; i++) {
                for (var key in arguments[i]) {
                    if (Object.prototype.hasOwnProperty.call(arguments[i], key)) {
                        obj[key] = arguments[i][key];
                    }
                }
            }

            return obj;
        }

        __exports__.extend = extend;
        var toString = Object.prototype.toString;
        __exports__.toString = toString;
        // Sourced from lodash
        // https://github.com/bestiejs/lodash/blob/master/LICENSE.txt
        var isFunction = function(value) {
            return typeof value === 'function';
        };
        // fallback for older versions of Chrome and Safari
        /* istanbul ignore next */
        if (isFunction(/x/)) {
            isFunction = function(value) {
                return typeof value === 'function' && toString.call(value) === '[object Function]';
            };
        }
        var isFunction;
        __exports__.isFunction = isFunction;
        /* istanbul ignore next */
        var isArray = Array.isArray || function(value) {
            return (value && typeof value === 'object') ? toString.call(value) === '[object Array]' : false;
        };
        __exports__.isArray = isArray;

        function escapeExpression(string) {
            // don't escape SafeStrings, since they're already safe
            if (string instanceof SafeString) {
                return string.toString();
            } else if (string == null) {
                return "";
            } else if (!string) {
                return string + '';
            }

            // Force a string conversion as this will be done by the append regardless and
            // the regex test will do this transparently behind the scenes, causing issues if
            // an object's to string has escaped characters in it.
            string = "" + string;

            if (!possible.test(string)) {
                return string;
            }
            return string.replace(badChars, escapeChar);
        }

        __exports__.escapeExpression = escapeExpression;

        function isEmpty(value) {
            if (!value && value !== 0) {
                return true;
            } else if (isArray(value) && value.length === 0) {
                return true;
            } else {
                return false;
            }
        }

        __exports__.isEmpty = isEmpty;

        function appendContextPath(contextPath, id) {
            return (contextPath ? contextPath + '.' : '') + id;
        }

        __exports__.appendContextPath = appendContextPath;
        return __exports__;
    })(__module4__);

    // handlebars/exception.js
    var __module5__ = (function() {
        "use strict";
        var __exports__;

        var errorProps = ['description', 'fileName', 'lineNumber', 'message', 'name', 'number', 'stack'];

        function Exception(message, node) {
            var line;
            if (node && node.firstLine) {
                line = node.firstLine;

                message += ' - ' + line + ':' + node.firstColumn;
            }

            var tmp = Error.prototype.constructor.call(this, message);

            // Unfortunately errors are not enumerable in Chrome (at least), so `for prop in tmp` doesn't work.
            for (var idx = 0; idx < errorProps.length; idx++) {
                this[errorProps[idx]] = tmp[errorProps[idx]];
            }

            if (line) {
                this.lineNumber = line;
                this.column = node.firstColumn;
            }
        }

        Exception.prototype = new Error();

        __exports__ = Exception;
        return __exports__;
    })();

    // handlebars/base.js
    var __module2__ = (function(__dependency1__, __dependency2__) {
        "use strict";
        var __exports__ = {};
        var Utils = __dependency1__;
        var Exception = __dependency2__;

        var VERSION = "2.0.0";
        __exports__.VERSION = VERSION;
        var COMPILER_REVISION = 6;
        __exports__.COMPILER_REVISION = COMPILER_REVISION;
        var REVISION_CHANGES = {
            1: '<= 1.0.rc.2', // 1.0.rc.2 is actually rev2 but doesn't report it
            2: '== 1.0.0-rc.3',
            3: '== 1.0.0-rc.4',
            4: '== 1.x.x',
            5: '== 2.0.0-alpha.x',
            6: '>= 2.0.0-beta.1'
        };
        __exports__.REVISION_CHANGES = REVISION_CHANGES;
        var isArray = Utils.isArray,
            isFunction = Utils.isFunction,
            toString = Utils.toString,
            objectType = '[object Object]';

        function HandlebarsEnvironment(helpers, partials) {
            this.helpers = helpers || {};
            this.partials = partials || {};

            registerDefaultHelpers(this);
        }

        __exports__.HandlebarsEnvironment = HandlebarsEnvironment;
        HandlebarsEnvironment.prototype = {
            constructor: HandlebarsEnvironment,

            logger: logger,
            log: log,

            registerHelper: function(name, fn) {
                if (toString.call(name) === objectType) {
                    if (fn) {
                        throw new Exception('Arg not supported with multiple helpers');
                    }
                    Utils.extend(this.helpers, name);
                } else {
                    this.helpers[name] = fn;
                }
            },
            unregisterHelper: function(name) {
                delete this.helpers[name];
            },

            registerPartial: function(name, partial) {
                if (toString.call(name) === objectType) {
                    Utils.extend(this.partials, name);
                } else {
                    this.partials[name] = partial;
                }
            },
            unregisterPartial: function(name) {
                delete this.partials[name];
            }
        };

        function registerDefaultHelpers(instance) {
            instance.registerHelper('helperMissing', function( /* [args, ]options */ ) {
                if (arguments.length === 1) {
                    // A missing field in a {{foo}} constuct.
                    return undefined;
                } else {
                    // Someone is actually trying to call something, blow up.
                    throw new Exception("Missing helper: '" + arguments[arguments.length - 1].name + "'");
                }
            });

            instance.registerHelper('blockHelperMissing', function(context, options) {
                var inverse = options.inverse,
                    fn = options.fn;

                if (context === true) {
                    return fn(this);
                } else if (context === false || context == null) {
                    return inverse(this);
                } else if (isArray(context)) {
                    if (context.length > 0) {
                        if (options.ids) {
                            options.ids = [options.name];
                        }

                        return instance.helpers.each(context, options);
                    } else {
                        return inverse(this);
                    }
                } else {
                    if (options.data && options.ids) {
                        var data = createFrame(options.data);
                        data.contextPath = Utils.appendContextPath(options.data.contextPath, options.name);
                        options = {
                            data: data
                        };
                    }

                    return fn(context, options);
                }
            });

            instance.registerHelper('each', function(context, options) {
                if (!options) {
                    throw new Exception('Must pass iterator to #each');
                }

                var fn = options.fn,
                    inverse = options.inverse;
                var i = 0,
                    ret = "",
                    data;

                var contextPath;
                if (options.data && options.ids) {
                    contextPath = Utils.appendContextPath(options.data.contextPath, options.ids[0]) + '.';
                }

                if (isFunction(context)) {
                    context = context.call(this);
                }

                if (options.data) {
                    data = createFrame(options.data);
                }

                if (context && typeof context === 'object') {
                    if (isArray(context)) {
                        for (var j = context.length; i < j; i++) {
                            if (data) {
                                data.index = i;
                                data.first = (i === 0);
                                data.last = (i === (context.length - 1));

                                if (contextPath) {
                                    data.contextPath = contextPath + i;
                                }
                            }
                            ret = ret + fn(context[i], {
                                data: data
                            });
                        }
                    } else {
                        for (var key in context) {
                            if (context.hasOwnProperty(key)) {
                                if (data) {
                                    data.key = key;
                                    data.index = i;
                                    data.first = (i === 0);

                                    if (contextPath) {
                                        data.contextPath = contextPath + key;
                                    }
                                }
                                ret = ret + fn(context[key], {
                                    data: data
                                });
                                i++;
                            }
                        }
                    }
                }

                if (i === 0) {
                    ret = inverse(this);
                }

                return ret;
            });

            instance.registerHelper('if', function(conditional, options) {
                if (isFunction(conditional)) {
                    conditional = conditional.call(this);
                }

                // Default behavior is to render the positive path if the value is truthy and not empty.
                // The `includeZero` option may be set to treat the condtional as purely not empty based on the
                // behavior of isEmpty. Effectively this determines if 0 is handled by the positive path or negative.
                if ((!options.hash.includeZero && !conditional) || Utils.isEmpty(conditional)) {
                    return options.inverse(this);
                } else {
                    return options.fn(this);
                }
            });

            instance.registerHelper('unless', function(conditional, options) {
                return instance.helpers['if'].call(this, conditional, {
                    fn: options.inverse,
                    inverse: options.fn,
                    hash: options.hash
                });
            });

            instance.registerHelper('with', function(context, options) {
                if (isFunction(context)) {
                    context = context.call(this);
                }

                var fn = options.fn;

                if (!Utils.isEmpty(context)) {
                    if (options.data && options.ids) {
                        var data = createFrame(options.data);
                        data.contextPath = Utils.appendContextPath(options.data.contextPath, options.ids[0]);
                        options = {
                            data: data
                        };
                    }

                    return fn(context, options);
                } else {
                    return options.inverse(this);
                }
            });

            instance.registerHelper('log', function(message, options) {
                var level = options.data && options.data.level != null ? parseInt(options.data.level, 10) : 1;
                instance.log(level, message);
            });

            instance.registerHelper('lookup', function(obj, field) {
                return obj && obj[field];
            });
        }

        var logger = {
            methodMap: {
                0: 'debug',
                1: 'info',
                2: 'warn',
                3: 'error'
            },

            // State enum
            DEBUG: 0,
            INFO: 1,
            WARN: 2,
            ERROR: 3,
            level: 3,

            // can be overridden in the host environment
            log: function(level, message) {
                if (logger.level <= level) {
                    var method = logger.methodMap[level];
                    if (typeof console !== 'undefined' && console[method]) {
                        console[method].call(console, message);
                    }
                }
            }
        };
        __exports__.logger = logger;
        var log = logger.log;
        __exports__.log = log;
        var createFrame = function(object) {
            var frame = Utils.extend({}, object);
            frame._parent = object;
            return frame;
        };
        __exports__.createFrame = createFrame;
        return __exports__;
    })(__module3__, __module5__);

    // handlebars/runtime.js
    var __module6__ = (function(__dependency1__, __dependency2__, __dependency3__) {
        "use strict";
        var __exports__ = {};
        var Utils = __dependency1__;
        var Exception = __dependency2__;
        var COMPILER_REVISION = __dependency3__.COMPILER_REVISION;
        var REVISION_CHANGES = __dependency3__.REVISION_CHANGES;
        var createFrame = __dependency3__.createFrame;

        function checkRevision(compilerInfo) {
            var compilerRevision = compilerInfo && compilerInfo[0] || 1,
                currentRevision = COMPILER_REVISION;

            if (compilerRevision !== currentRevision) {
                if (compilerRevision < currentRevision) {
                    var runtimeVersions = REVISION_CHANGES[currentRevision],
                        compilerVersions = REVISION_CHANGES[compilerRevision];
                    throw new Exception("Template was precompiled with an older version of Handlebars than the current runtime. " +
                        "Please update your precompiler to a newer version (" + runtimeVersions + ") or downgrade your runtime to an older version (" + compilerVersions + ").");
                } else {
                    // Use the embedded version info since the runtime doesn't know about this revision yet
                    throw new Exception("Template was precompiled with a newer version of Handlebars than the current runtime. " +
                        "Please update your runtime to a newer version (" + compilerInfo[1] + ").");
                }
            }
        }

        __exports__.checkRevision = checkRevision; // TODO: Remove this line and break up compilePartial

        function template(templateSpec, env) {
            /* istanbul ignore next */
            if (!env) {
                throw new Exception("No environment passed to template");
            }
            if (!templateSpec || !templateSpec.main) {
                throw new Exception('Unknown template object: ' + typeof templateSpec);
            }

            // Note: Using env.VM references rather than local var references throughout this section to allow
            // for external users to override these as psuedo-supported APIs.
            env.VM.checkRevision(templateSpec.compiler);

            var invokePartialWrapper = function(partial, indent, name, context, hash, helpers, partials, data, depths) {
                if (hash) {
                    context = Utils.extend({}, context, hash);
                }

                var result = env.VM.invokePartial.call(this, partial, name, context, helpers, partials, data, depths);

                if (result == null && env.compile) {
                    var options = {
                        helpers: helpers,
                        partials: partials,
                        data: data,
                        depths: depths
                    };
                    partials[name] = env.compile(partial, {
                        data: data !== undefined,
                        compat: templateSpec.compat
                    }, env);
                    result = partials[name](context, options);
                }
                if (result != null) {
                    if (indent) {
                        var lines = result.split('\n');
                        for (var i = 0, l = lines.length; i < l; i++) {
                            if (!lines[i] && i + 1 === l) {
                                break;
                            }

                            lines[i] = indent + lines[i];
                        }
                        result = lines.join('\n');
                    }
                    return result;
                } else {
                    throw new Exception("The partial " + name + " could not be compiled when running in runtime-only mode");
                }
            };

            // Just add water
            var container = {
                lookup: function(depths, name) {
                    var len = depths.length;
                    for (var i = 0; i < len; i++) {
                        if (depths[i] && depths[i][name] != null) {
                            return depths[i][name];
                        }
                    }
                },
                lambda: function(current, context) {
                    return typeof current === 'function' ? current.call(context) : current;
                },

                escapeExpression: Utils.escapeExpression,
                invokePartial: invokePartialWrapper,

                fn: function(i) {
                    return templateSpec[i];
                },

                programs: [],
                program: function(i, data, depths) {
                    var programWrapper = this.programs[i],
                        fn = this.fn(i);
                    if (data || depths) {
                        programWrapper = program(this, i, fn, data, depths);
                    } else if (!programWrapper) {
                        programWrapper = this.programs[i] = program(this, i, fn);
                    }
                    return programWrapper;
                },

                data: function(data, depth) {
                    while (data && depth--) {
                        data = data._parent;
                    }
                    return data;
                },
                merge: function(param, common) {
                    var ret = param || common;

                    if (param && common && (param !== common)) {
                        ret = Utils.extend({}, common, param);
                    }

                    return ret;
                },

                noop: env.VM.noop,
                compilerInfo: templateSpec.compiler
            };

            var ret = function(context, options) {
                options = options || {};
                var data = options.data;

                ret._setup(options);
                if (!options.partial && templateSpec.useData) {
                    data = initData(context, data);
                }
                var depths;
                if (templateSpec.useDepths) {
                    depths = options.depths ? [context].concat(options.depths) : [context];
                }

                return templateSpec.main.call(container, context, container.helpers, container.partials, data, depths);
            };
            ret.isTop = true;

            ret._setup = function(options) {
                if (!options.partial) {
                    container.helpers = container.merge(options.helpers, env.helpers);

                    if (templateSpec.usePartial) {
                        container.partials = container.merge(options.partials, env.partials);
                    }
                } else {
                    container.helpers = options.helpers;
                    container.partials = options.partials;
                }
            };

            ret._child = function(i, data, depths) {
                if (templateSpec.useDepths && !depths) {
                    throw new Exception('must pass parent depths');
                }

                return program(container, i, templateSpec[i], data, depths);
            };
            return ret;
        }

        __exports__.template = template;

        function program(container, i, fn, data, depths) {
            var prog = function(context, options) {
                options = options || {};

                return fn.call(container, context, container.helpers, container.partials, options.data || data, depths && [context].concat(depths));
            };
            prog.program = i;
            prog.depth = depths ? depths.length : 0;
            return prog;
        }

        __exports__.program = program;

        function invokePartial(partial, name, context, helpers, partials, data, depths) {
            var options = {
                partial: true,
                helpers: helpers,
                partials: partials,
                data: data,
                depths: depths
            };

            if (partial === undefined) {
                throw new Exception("The partial " + name + " could not be found");
            } else if (partial instanceof Function) {
                return partial(context, options);
            }
        }

        __exports__.invokePartial = invokePartial;

        function noop() {
            return "";
        }

        __exports__.noop = noop;

        function initData(context, data) {
            if (!data || !('root' in data)) {
                data = data ? createFrame(data) : {};
                data.root = context;
            }
            return data;
        }
        return __exports__;
    })(__module3__, __module5__, __module2__);

    // handlebars.runtime.js
    var __module1__ = (function(__dependency1__, __dependency2__, __dependency3__, __dependency4__, __dependency5__) {
        "use strict";
        var __exports__;
        /*globals Handlebars: true */
        var base = __dependency1__;

        // Each of these augment the Handlebars object. No need to setup here.
        // (This is done to easily share code between commonjs and browse envs)
        var SafeString = __dependency2__;
        var Exception = __dependency3__;
        var Utils = __dependency4__;
        var runtime = __dependency5__;

        // For compatibility and usage outside of module systems, make the Handlebars object a namespace
        var create = function() {
            var hb = new base.HandlebarsEnvironment();

            Utils.extend(hb, base);
            hb.SafeString = SafeString;
            hb.Exception = Exception;
            hb.Utils = Utils;
            hb.escapeExpression = Utils.escapeExpression;

            hb.VM = runtime;
            hb.template = function(spec) {
                return runtime.template(spec, hb);
            };

            return hb;
        };

        var Handlebars = create();
        Handlebars.create = create;

        Handlebars['default'] = Handlebars;

        __exports__ = Handlebars;
        return __exports__;
    })(__module2__, __module4__, __module5__, __module3__, __module6__);

    // handlebars/compiler/ast.js
    var __module7__ = (function(__dependency1__) {
        "use strict";
        var __exports__;
        var Exception = __dependency1__;

        function LocationInfo(locInfo) {
            locInfo = locInfo || {};
            this.firstLine = locInfo.first_line;
            this.firstColumn = locInfo.first_column;
            this.lastColumn = locInfo.last_column;
            this.lastLine = locInfo.last_line;
        }

        var AST = {
            ProgramNode: function(statements, strip, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "program";
                this.statements = statements;
                this.strip = strip;
            },

            MustacheNode: function(rawParams, hash, open, strip, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "mustache";
                this.strip = strip;

                // Open may be a string parsed from the parser or a passed boolean flag
                if (open != null && open.charAt) {
                    // Must use charAt to support IE pre-10
                    var escapeFlag = open.charAt(3) || open.charAt(2);
                    this.escaped = escapeFlag !== '{' && escapeFlag !== '&';
                } else {
                    this.escaped = !!open;
                }

                if (rawParams instanceof AST.SexprNode) {
                    this.sexpr = rawParams;
                } else {
                    // Support old AST API
                    this.sexpr = new AST.SexprNode(rawParams, hash);
                }

                // Support old AST API that stored this info in MustacheNode
                this.id = this.sexpr.id;
                this.params = this.sexpr.params;
                this.hash = this.sexpr.hash;
                this.eligibleHelper = this.sexpr.eligibleHelper;
                this.isHelper = this.sexpr.isHelper;
            },

            SexprNode: function(rawParams, hash, locInfo) {
                LocationInfo.call(this, locInfo);

                this.type = "sexpr";
                this.hash = hash;

                var id = this.id = rawParams[0];
                var params = this.params = rawParams.slice(1);

                // a mustache is definitely a helper if:
                // * it is an eligible helper, and
                // * it has at least one parameter or hash segment
                this.isHelper = !!(params.length || hash);

                // a mustache is an eligible helper if:
                // * its id is simple (a single part, not `this` or `..`)
                this.eligibleHelper = this.isHelper || id.isSimple;

                // if a mustache is an eligible helper but not a definite
                // helper, it is ambiguous, and will be resolved in a later
                // pass or at runtime.
            },

            PartialNode: function(partialName, context, hash, strip, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "partial";
                this.partialName = partialName;
                this.context = context;
                this.hash = hash;
                this.strip = strip;

                this.strip.inlineStandalone = true;
            },

            BlockNode: function(mustache, program, inverse, strip, locInfo) {
                LocationInfo.call(this, locInfo);

                this.type = 'block';
                this.mustache = mustache;
                this.program = program;
                this.inverse = inverse;
                this.strip = strip;

                if (inverse && !program) {
                    this.isInverse = true;
                }
            },

            RawBlockNode: function(mustache, content, close, locInfo) {
                LocationInfo.call(this, locInfo);

                if (mustache.sexpr.id.original !== close) {
                    throw new Exception(mustache.sexpr.id.original + " doesn't match " + close, this);
                }

                content = new AST.ContentNode(content, locInfo);

                this.type = 'block';
                this.mustache = mustache;
                this.program = new AST.ProgramNode([content], {}, locInfo);
            },

            ContentNode: function(string, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "content";
                this.original = this.string = string;
            },

            HashNode: function(pairs, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "hash";
                this.pairs = pairs;
            },

            IdNode: function(parts, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "ID";

                var original = "",
                    dig = [],
                    depth = 0,
                    depthString = '';

                for (var i = 0, l = parts.length; i < l; i++) {
                    var part = parts[i].part;
                    original += (parts[i].separator || '') + part;

                    if (part === ".." || part === "." || part === "this") {
                        if (dig.length > 0) {
                            throw new Exception("Invalid path: " + original, this);
                        } else if (part === "..") {
                            depth++;
                            depthString += '../';
                        } else {
                            this.isScoped = true;
                        }
                    } else {
                        dig.push(part);
                    }
                }

                this.original = original;
                this.parts = dig;
                this.string = dig.join('.');
                this.depth = depth;
                this.idName = depthString + this.string;

                // an ID is simple if it only has one part, and that part is not
                // `..` or `this`.
                this.isSimple = parts.length === 1 && !this.isScoped && depth === 0;

                this.stringModeValue = this.string;
            },

            PartialNameNode: function(name, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "PARTIAL_NAME";
                this.name = name.original;
            },

            DataNode: function(id, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "DATA";
                this.id = id;
                this.stringModeValue = id.stringModeValue;
                this.idName = '@' + id.stringModeValue;
            },

            StringNode: function(string, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "STRING";
                this.original =
                    this.string =
                    this.stringModeValue = string;
            },

            NumberNode: function(number, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "NUMBER";
                this.original =
                    this.number = number;
                this.stringModeValue = Number(number);
            },

            BooleanNode: function(bool, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "BOOLEAN";
                this.bool = bool;
                this.stringModeValue = bool === "true";
            },

            CommentNode: function(comment, locInfo) {
                LocationInfo.call(this, locInfo);
                this.type = "comment";
                this.comment = comment;

                this.strip = {
                    inlineStandalone: true
                };
            }
        };


        // Must be exported as an object rather than the root of the module as the jison lexer
        // most modify the object to operate properly.
        __exports__ = AST;
        return __exports__;
    })(__module5__);

    // handlebars/compiler/parser.js
    var __module9__ = (function() {
        "use strict";
        var __exports__;
        /* jshint ignore:start */
        /* istanbul ignore next */
        /* Jison generated parser */
        var handlebars = (function() {
            var parser = {
                trace: function trace() {},
                yy: {},
                symbols_: {
                    "error": 2,
                    "root": 3,
                    "program": 4,
                    "EOF": 5,
                    "program_repetition0": 6,
                    "statement": 7,
                    "mustache": 8,
                    "block": 9,
                    "rawBlock": 10,
                    "partial": 11,
                    "CONTENT": 12,
                    "COMMENT": 13,
                    "openRawBlock": 14,
                    "END_RAW_BLOCK": 15,
                    "OPEN_RAW_BLOCK": 16,
                    "sexpr": 17,
                    "CLOSE_RAW_BLOCK": 18,
                    "openBlock": 19,
                    "block_option0": 20,
                    "closeBlock": 21,
                    "openInverse": 22,
                    "block_option1": 23,
                    "OPEN_BLOCK": 24,
                    "CLOSE": 25,
                    "OPEN_INVERSE": 26,
                    "inverseAndProgram": 27,
                    "INVERSE": 28,
                    "OPEN_ENDBLOCK": 29,
                    "path": 30,
                    "OPEN": 31,
                    "OPEN_UNESCAPED": 32,
                    "CLOSE_UNESCAPED": 33,
                    "OPEN_PARTIAL": 34,
                    "partialName": 35,
                    "param": 36,
                    "partial_option0": 37,
                    "partial_option1": 38,
                    "sexpr_repetition0": 39,
                    "sexpr_option0": 40,
                    "dataName": 41,
                    "STRING": 42,
                    "NUMBER": 43,
                    "BOOLEAN": 44,
                    "OPEN_SEXPR": 45,
                    "CLOSE_SEXPR": 46,
                    "hash": 47,
                    "hash_repetition_plus0": 48,
                    "hashSegment": 49,
                    "ID": 50,
                    "EQUALS": 51,
                    "DATA": 52,
                    "pathSegments": 53,
                    "SEP": 54,
                    "$accept": 0,
                    "$end": 1
                },
                terminals_: {
                    2: "error",
                    5: "EOF",
                    12: "CONTENT",
                    13: "COMMENT",
                    15: "END_RAW_BLOCK",
                    16: "OPEN_RAW_BLOCK",
                    18: "CLOSE_RAW_BLOCK",
                    24: "OPEN_BLOCK",
                    25: "CLOSE",
                    26: "OPEN_INVERSE",
                    28: "INVERSE",
                    29: "OPEN_ENDBLOCK",
                    31: "OPEN",
                    32: "OPEN_UNESCAPED",
                    33: "CLOSE_UNESCAPED",
                    34: "OPEN_PARTIAL",
                    42: "STRING",
                    43: "NUMBER",
                    44: "BOOLEAN",
                    45: "OPEN_SEXPR",
                    46: "CLOSE_SEXPR",
                    50: "ID",
                    51: "EQUALS",
                    52: "DATA",
                    54: "SEP"
                },
                productions_: [0, [3, 2],
                    [4, 1],
                    [7, 1],
                    [7, 1],
                    [7, 1],
                    [7, 1],
                    [7, 1],
                    [7, 1],
                    [10, 3],
                    [14, 3],
                    [9, 4],
                    [9, 4],
                    [19, 3],
                    [22, 3],
                    [27, 2],
                    [21, 3],
                    [8, 3],
                    [8, 3],
                    [11, 5],
                    [11, 4],
                    [17, 3],
                    [17, 1],
                    [36, 1],
                    [36, 1],
                    [36, 1],
                    [36, 1],
                    [36, 1],
                    [36, 3],
                    [47, 1],
                    [49, 3],
                    [35, 1],
                    [35, 1],
                    [35, 1],
                    [41, 2],
                    [30, 1],
                    [53, 3],
                    [53, 1],
                    [6, 0],
                    [6, 2],
                    [20, 0],
                    [20, 1],
                    [23, 0],
                    [23, 1],
                    [37, 0],
                    [37, 1],
                    [38, 0],
                    [38, 1],
                    [39, 0],
                    [39, 2],
                    [40, 0],
                    [40, 1],
                    [48, 1],
                    [48, 2]
                ],
                performAction: function anonymous(yytext, yyleng, yylineno, yy, yystate, $$, _$) {

                    var $0 = $$.length - 1;
                    switch (yystate) {
                        case 1:
                            yy.prepareProgram($$[$0 - 1].statements, true);
                            return $$[$0 - 1];
                            break;
                        case 2:
                            this.$ = new yy.ProgramNode(yy.prepareProgram($$[$0]), {}, this._$);
                            break;
                        case 3:
                            this.$ = $$[$0];
                            break;
                        case 4:
                            this.$ = $$[$0];
                            break;
                        case 5:
                            this.$ = $$[$0];
                            break;
                        case 6:
                            this.$ = $$[$0];
                            break;
                        case 7:
                            this.$ = new yy.ContentNode($$[$0], this._$);
                            break;
                        case 8:
                            this.$ = new yy.CommentNode($$[$0], this._$);
                            break;
                        case 9:
                            this.$ = new yy.RawBlockNode($$[$0 - 2], $$[$0 - 1], $$[$0], this._$);
                            break;
                        case 10:
                            this.$ = new yy.MustacheNode($$[$0 - 1], null, '', '', this._$);
                            break;
                        case 11:
                            this.$ = yy.prepareBlock($$[$0 - 3], $$[$0 - 2], $$[$0 - 1], $$[$0], false, this._$);
                            break;
                        case 12:
                            this.$ = yy.prepareBlock($$[$0 - 3], $$[$0 - 2], $$[$0 - 1], $$[$0], true, this._$);
                            break;
                        case 13:
                            this.$ = new yy.MustacheNode($$[$0 - 1], null, $$[$0 - 2], yy.stripFlags($$[$0 - 2], $$[$0]), this._$);
                            break;
                        case 14:
                            this.$ = new yy.MustacheNode($$[$0 - 1], null, $$[$0 - 2], yy.stripFlags($$[$0 - 2], $$[$0]), this._$);
                            break;
                        case 15:
                            this.$ = {
                                strip: yy.stripFlags($$[$0 - 1], $$[$0 - 1]),
                                program: $$[$0]
                            };
                            break;
                        case 16:
                            this.$ = {
                                path: $$[$0 - 1],
                                strip: yy.stripFlags($$[$0 - 2], $$[$0])
                            };
                            break;
                        case 17:
                            this.$ = new yy.MustacheNode($$[$0 - 1], null, $$[$0 - 2], yy.stripFlags($$[$0 - 2], $$[$0]), this._$);
                            break;
                        case 18:
                            this.$ = new yy.MustacheNode($$[$0 - 1], null, $$[$0 - 2], yy.stripFlags($$[$0 - 2], $$[$0]), this._$);
                            break;
                        case 19:
                            this.$ = new yy.PartialNode($$[$0 - 3], $$[$0 - 2], $$[$0 - 1], yy.stripFlags($$[$0 - 4], $$[$0]), this._$);
                            break;
                        case 20:
                            this.$ = new yy.PartialNode($$[$0 - 2], undefined, $$[$0 - 1], yy.stripFlags($$[$0 - 3], $$[$0]), this._$);
                            break;
                        case 21:
                            this.$ = new yy.SexprNode([$$[$0 - 2]].concat($$[$0 - 1]), $$[$0], this._$);
                            break;
                        case 22:
                            this.$ = new yy.SexprNode([$$[$0]], null, this._$);
                            break;
                        case 23:
                            this.$ = $$[$0];
                            break;
                        case 24:
                            this.$ = new yy.StringNode($$[$0], this._$);
                            break;
                        case 25:
                            this.$ = new yy.NumberNode($$[$0], this._$);
                            break;
                        case 26:
                            this.$ = new yy.BooleanNode($$[$0], this._$);
                            break;
                        case 27:
                            this.$ = $$[$0];
                            break;
                        case 28:
                            $$[$0 - 1].isHelper = true;
                            this.$ = $$[$0 - 1];
                            break;
                        case 29:
                            this.$ = new yy.HashNode($$[$0], this._$);
                            break;
                        case 30:
                            this.$ = [$$[$0 - 2], $$[$0]];
                            break;
                        case 31:
                            this.$ = new yy.PartialNameNode($$[$0], this._$);
                            break;
                        case 32:
                            this.$ = new yy.PartialNameNode(new yy.StringNode($$[$0], this._$), this._$);
                            break;
                        case 33:
                            this.$ = new yy.PartialNameNode(new yy.NumberNode($$[$0], this._$));
                            break;
                        case 34:
                            this.$ = new yy.DataNode($$[$0], this._$);
                            break;
                        case 35:
                            this.$ = new yy.IdNode($$[$0], this._$);
                            break;
                        case 36:
                            $$[$0 - 2].push({
                                part: $$[$0],
                                separator: $$[$0 - 1]
                            });
                            this.$ = $$[$0 - 2];
                            break;
                        case 37:
                            this.$ = [{
                                part: $$[$0]
                            }];
                            break;
                        case 38:
                            this.$ = [];
                            break;
                        case 39:
                            $$[$0 - 1].push($$[$0]);
                            break;
                        case 48:
                            this.$ = [];
                            break;
                        case 49:
                            $$[$0 - 1].push($$[$0]);
                            break;
                        case 52:
                            this.$ = [$$[$0]];
                            break;
                        case 53:
                            $$[$0 - 1].push($$[$0]);
                            break;
                    }
                },
                table: [{
                    3: 1,
                    4: 2,
                    5: [2, 38],
                    6: 3,
                    12: [2, 38],
                    13: [2, 38],
                    16: [2, 38],
                    24: [2, 38],
                    26: [2, 38],
                    31: [2, 38],
                    32: [2, 38],
                    34: [2, 38]
                }, {
                    1: [3]
                }, {
                    5: [1, 4]
                }, {
                    5: [2, 2],
                    7: 5,
                    8: 6,
                    9: 7,
                    10: 8,
                    11: 9,
                    12: [1, 10],
                    13: [1, 11],
                    14: 16,
                    16: [1, 20],
                    19: 14,
                    22: 15,
                    24: [1, 18],
                    26: [1, 19],
                    28: [2, 2],
                    29: [2, 2],
                    31: [1, 12],
                    32: [1, 13],
                    34: [1, 17]
                }, {
                    1: [2, 1]
                }, {
                    5: [2, 39],
                    12: [2, 39],
                    13: [2, 39],
                    16: [2, 39],
                    24: [2, 39],
                    26: [2, 39],
                    28: [2, 39],
                    29: [2, 39],
                    31: [2, 39],
                    32: [2, 39],
                    34: [2, 39]
                }, {
                    5: [2, 3],
                    12: [2, 3],
                    13: [2, 3],
                    16: [2, 3],
                    24: [2, 3],
                    26: [2, 3],
                    28: [2, 3],
                    29: [2, 3],
                    31: [2, 3],
                    32: [2, 3],
                    34: [2, 3]
                }, {
                    5: [2, 4],
                    12: [2, 4],
                    13: [2, 4],
                    16: [2, 4],
                    24: [2, 4],
                    26: [2, 4],
                    28: [2, 4],
                    29: [2, 4],
                    31: [2, 4],
                    32: [2, 4],
                    34: [2, 4]
                }, {
                    5: [2, 5],
                    12: [2, 5],
                    13: [2, 5],
                    16: [2, 5],
                    24: [2, 5],
                    26: [2, 5],
                    28: [2, 5],
                    29: [2, 5],
                    31: [2, 5],
                    32: [2, 5],
                    34: [2, 5]
                }, {
                    5: [2, 6],
                    12: [2, 6],
                    13: [2, 6],
                    16: [2, 6],
                    24: [2, 6],
                    26: [2, 6],
                    28: [2, 6],
                    29: [2, 6],
                    31: [2, 6],
                    32: [2, 6],
                    34: [2, 6]
                }, {
                    5: [2, 7],
                    12: [2, 7],
                    13: [2, 7],
                    16: [2, 7],
                    24: [2, 7],
                    26: [2, 7],
                    28: [2, 7],
                    29: [2, 7],
                    31: [2, 7],
                    32: [2, 7],
                    34: [2, 7]
                }, {
                    5: [2, 8],
                    12: [2, 8],
                    13: [2, 8],
                    16: [2, 8],
                    24: [2, 8],
                    26: [2, 8],
                    28: [2, 8],
                    29: [2, 8],
                    31: [2, 8],
                    32: [2, 8],
                    34: [2, 8]
                }, {
                    17: 21,
                    30: 22,
                    41: 23,
                    50: [1, 26],
                    52: [1, 25],
                    53: 24
                }, {
                    17: 27,
                    30: 22,
                    41: 23,
                    50: [1, 26],
                    52: [1, 25],
                    53: 24
                }, {
                    4: 28,
                    6: 3,
                    12: [2, 38],
                    13: [2, 38],
                    16: [2, 38],
                    24: [2, 38],
                    26: [2, 38],
                    28: [2, 38],
                    29: [2, 38],
                    31: [2, 38],
                    32: [2, 38],
                    34: [2, 38]
                }, {
                    4: 29,
                    6: 3,
                    12: [2, 38],
                    13: [2, 38],
                    16: [2, 38],
                    24: [2, 38],
                    26: [2, 38],
                    28: [2, 38],
                    29: [2, 38],
                    31: [2, 38],
                    32: [2, 38],
                    34: [2, 38]
                }, {
                    12: [1, 30]
                }, {
                    30: 32,
                    35: 31,
                    42: [1, 33],
                    43: [1, 34],
                    50: [1, 26],
                    53: 24
                }, {
                    17: 35,
                    30: 22,
                    41: 23,
                    50: [1, 26],
                    52: [1, 25],
                    53: 24
                }, {
                    17: 36,
                    30: 22,
                    41: 23,
                    50: [1, 26],
                    52: [1, 25],
                    53: 24
                }, {
                    17: 37,
                    30: 22,
                    41: 23,
                    50: [1, 26],
                    52: [1, 25],
                    53: 24
                }, {
                    25: [1, 38]
                }, {
                    18: [2, 48],
                    25: [2, 48],
                    33: [2, 48],
                    39: 39,
                    42: [2, 48],
                    43: [2, 48],
                    44: [2, 48],
                    45: [2, 48],
                    46: [2, 48],
                    50: [2, 48],
                    52: [2, 48]
                }, {
                    18: [2, 22],
                    25: [2, 22],
                    33: [2, 22],
                    46: [2, 22]
                }, {
                    18: [2, 35],
                    25: [2, 35],
                    33: [2, 35],
                    42: [2, 35],
                    43: [2, 35],
                    44: [2, 35],
                    45: [2, 35],
                    46: [2, 35],
                    50: [2, 35],
                    52: [2, 35],
                    54: [1, 40]
                }, {
                    30: 41,
                    50: [1, 26],
                    53: 24
                }, {
                    18: [2, 37],
                    25: [2, 37],
                    33: [2, 37],
                    42: [2, 37],
                    43: [2, 37],
                    44: [2, 37],
                    45: [2, 37],
                    46: [2, 37],
                    50: [2, 37],
                    52: [2, 37],
                    54: [2, 37]
                }, {
                    33: [1, 42]
                }, {
                    20: 43,
                    27: 44,
                    28: [1, 45],
                    29: [2, 40]
                }, {
                    23: 46,
                    27: 47,
                    28: [1, 45],
                    29: [2, 42]
                }, {
                    15: [1, 48]
                }, {
                    25: [2, 46],
                    30: 51,
                    36: 49,
                    38: 50,
                    41: 55,
                    42: [1, 52],
                    43: [1, 53],
                    44: [1, 54],
                    45: [1, 56],
                    47: 57,
                    48: 58,
                    49: 60,
                    50: [1, 59],
                    52: [1, 25],
                    53: 24
                }, {
                    25: [2, 31],
                    42: [2, 31],
                    43: [2, 31],
                    44: [2, 31],
                    45: [2, 31],
                    50: [2, 31],
                    52: [2, 31]
                }, {
                    25: [2, 32],
                    42: [2, 32],
                    43: [2, 32],
                    44: [2, 32],
                    45: [2, 32],
                    50: [2, 32],
                    52: [2, 32]
                }, {
                    25: [2, 33],
                    42: [2, 33],
                    43: [2, 33],
                    44: [2, 33],
                    45: [2, 33],
                    50: [2, 33],
                    52: [2, 33]
                }, {
                    25: [1, 61]
                }, {
                    25: [1, 62]
                }, {
                    18: [1, 63]
                }, {
                    5: [2, 17],
                    12: [2, 17],
                    13: [2, 17],
                    16: [2, 17],
                    24: [2, 17],
                    26: [2, 17],
                    28: [2, 17],
                    29: [2, 17],
                    31: [2, 17],
                    32: [2, 17],
                    34: [2, 17]
                }, {
                    18: [2, 50],
                    25: [2, 50],
                    30: 51,
                    33: [2, 50],
                    36: 65,
                    40: 64,
                    41: 55,
                    42: [1, 52],
                    43: [1, 53],
                    44: [1, 54],
                    45: [1, 56],
                    46: [2, 50],
                    47: 66,
                    48: 58,
                    49: 60,
                    50: [1, 59],
                    52: [1, 25],
                    53: 24
                }, {
                    50: [1, 67]
                }, {
                    18: [2, 34],
                    25: [2, 34],
                    33: [2, 34],
                    42: [2, 34],
                    43: [2, 34],
                    44: [2, 34],
                    45: [2, 34],
                    46: [2, 34],
                    50: [2, 34],
                    52: [2, 34]
                }, {
                    5: [2, 18],
                    12: [2, 18],
                    13: [2, 18],
                    16: [2, 18],
                    24: [2, 18],
                    26: [2, 18],
                    28: [2, 18],
                    29: [2, 18],
                    31: [2, 18],
                    32: [2, 18],
                    34: [2, 18]
                }, {
                    21: 68,
                    29: [1, 69]
                }, {
                    29: [2, 41]
                }, {
                    4: 70,
                    6: 3,
                    12: [2, 38],
                    13: [2, 38],
                    16: [2, 38],
                    24: [2, 38],
                    26: [2, 38],
                    29: [2, 38],
                    31: [2, 38],
                    32: [2, 38],
                    34: [2, 38]
                }, {
                    21: 71,
                    29: [1, 69]
                }, {
                    29: [2, 43]
                }, {
                    5: [2, 9],
                    12: [2, 9],
                    13: [2, 9],
                    16: [2, 9],
                    24: [2, 9],
                    26: [2, 9],
                    28: [2, 9],
                    29: [2, 9],
                    31: [2, 9],
                    32: [2, 9],
                    34: [2, 9]
                }, {
                    25: [2, 44],
                    37: 72,
                    47: 73,
                    48: 58,
                    49: 60,
                    50: [1, 74]
                }, {
                    25: [1, 75]
                }, {
                    18: [2, 23],
                    25: [2, 23],
                    33: [2, 23],
                    42: [2, 23],
                    43: [2, 23],
                    44: [2, 23],
                    45: [2, 23],
                    46: [2, 23],
                    50: [2, 23],
                    52: [2, 23]
                }, {
                    18: [2, 24],
                    25: [2, 24],
                    33: [2, 24],
                    42: [2, 24],
                    43: [2, 24],
                    44: [2, 24],
                    45: [2, 24],
                    46: [2, 24],
                    50: [2, 24],
                    52: [2, 24]
                }, {
                    18: [2, 25],
                    25: [2, 25],
                    33: [2, 25],
                    42: [2, 25],
                    43: [2, 25],
                    44: [2, 25],
                    45: [2, 25],
                    46: [2, 25],
                    50: [2, 25],
                    52: [2, 25]
                }, {
                    18: [2, 26],
                    25: [2, 26],
                    33: [2, 26],
                    42: [2, 26],
                    43: [2, 26],
                    44: [2, 26],
                    45: [2, 26],
                    46: [2, 26],
                    50: [2, 26],
                    52: [2, 26]
                }, {
                    18: [2, 27],
                    25: [2, 27],
                    33: [2, 27],
                    42: [2, 27],
                    43: [2, 27],
                    44: [2, 27],
                    45: [2, 27],
                    46: [2, 27],
                    50: [2, 27],
                    52: [2, 27]
                }, {
                    17: 76,
                    30: 22,
                    41: 23,
                    50: [1, 26],
                    52: [1, 25],
                    53: 24
                }, {
                    25: [2, 47]
                }, {
                    18: [2, 29],
                    25: [2, 29],
                    33: [2, 29],
                    46: [2, 29],
                    49: 77,
                    50: [1, 74]
                }, {
                    18: [2, 37],
                    25: [2, 37],
                    33: [2, 37],
                    42: [2, 37],
                    43: [2, 37],
                    44: [2, 37],
                    45: [2, 37],
                    46: [2, 37],
                    50: [2, 37],
                    51: [1, 78],
                    52: [2, 37],
                    54: [2, 37]
                }, {
                    18: [2, 52],
                    25: [2, 52],
                    33: [2, 52],
                    46: [2, 52],
                    50: [2, 52]
                }, {
                    12: [2, 13],
                    13: [2, 13],
                    16: [2, 13],
                    24: [2, 13],
                    26: [2, 13],
                    28: [2, 13],
                    29: [2, 13],
                    31: [2, 13],
                    32: [2, 13],
                    34: [2, 13]
                }, {
                    12: [2, 14],
                    13: [2, 14],
                    16: [2, 14],
                    24: [2, 14],
                    26: [2, 14],
                    28: [2, 14],
                    29: [2, 14],
                    31: [2, 14],
                    32: [2, 14],
                    34: [2, 14]
                }, {
                    12: [2, 10]
                }, {
                    18: [2, 21],
                    25: [2, 21],
                    33: [2, 21],
                    46: [2, 21]
                }, {
                    18: [2, 49],
                    25: [2, 49],
                    33: [2, 49],
                    42: [2, 49],
                    43: [2, 49],
                    44: [2, 49],
                    45: [2, 49],
                    46: [2, 49],
                    50: [2, 49],
                    52: [2, 49]
                }, {
                    18: [2, 51],
                    25: [2, 51],
                    33: [2, 51],
                    46: [2, 51]
                }, {
                    18: [2, 36],
                    25: [2, 36],
                    33: [2, 36],
                    42: [2, 36],
                    43: [2, 36],
                    44: [2, 36],
                    45: [2, 36],
                    46: [2, 36],
                    50: [2, 36],
                    52: [2, 36],
                    54: [2, 36]
                }, {
                    5: [2, 11],
                    12: [2, 11],
                    13: [2, 11],
                    16: [2, 11],
                    24: [2, 11],
                    26: [2, 11],
                    28: [2, 11],
                    29: [2, 11],
                    31: [2, 11],
                    32: [2, 11],
                    34: [2, 11]
                }, {
                    30: 79,
                    50: [1, 26],
                    53: 24
                }, {
                    29: [2, 15]
                }, {
                    5: [2, 12],
                    12: [2, 12],
                    13: [2, 12],
                    16: [2, 12],
                    24: [2, 12],
                    26: [2, 12],
                    28: [2, 12],
                    29: [2, 12],
                    31: [2, 12],
                    32: [2, 12],
                    34: [2, 12]
                }, {
                    25: [1, 80]
                }, {
                    25: [2, 45]
                }, {
                    51: [1, 78]
                }, {
                    5: [2, 20],
                    12: [2, 20],
                    13: [2, 20],
                    16: [2, 20],
                    24: [2, 20],
                    26: [2, 20],
                    28: [2, 20],
                    29: [2, 20],
                    31: [2, 20],
                    32: [2, 20],
                    34: [2, 20]
                }, {
                    46: [1, 81]
                }, {
                    18: [2, 53],
                    25: [2, 53],
                    33: [2, 53],
                    46: [2, 53],
                    50: [2, 53]
                }, {
                    30: 51,
                    36: 82,
                    41: 55,
                    42: [1, 52],
                    43: [1, 53],
                    44: [1, 54],
                    45: [1, 56],
                    50: [1, 26],
                    52: [1, 25],
                    53: 24
                }, {
                    25: [1, 83]
                }, {
                    5: [2, 19],
                    12: [2, 19],
                    13: [2, 19],
                    16: [2, 19],
                    24: [2, 19],
                    26: [2, 19],
                    28: [2, 19],
                    29: [2, 19],
                    31: [2, 19],
                    32: [2, 19],
                    34: [2, 19]
                }, {
                    18: [2, 28],
                    25: [2, 28],
                    33: [2, 28],
                    42: [2, 28],
                    43: [2, 28],
                    44: [2, 28],
                    45: [2, 28],
                    46: [2, 28],
                    50: [2, 28],
                    52: [2, 28]
                }, {
                    18: [2, 30],
                    25: [2, 30],
                    33: [2, 30],
                    46: [2, 30],
                    50: [2, 30]
                }, {
                    5: [2, 16],
                    12: [2, 16],
                    13: [2, 16],
                    16: [2, 16],
                    24: [2, 16],
                    26: [2, 16],
                    28: [2, 16],
                    29: [2, 16],
                    31: [2, 16],
                    32: [2, 16],
                    34: [2, 16]
                }],
                defaultActions: {
                    4: [2, 1],
                    44: [2, 41],
                    47: [2, 43],
                    57: [2, 47],
                    63: [2, 10],
                    70: [2, 15],
                    73: [2, 45]
                },
                parseError: function parseError(str, hash) {
                    throw new Error(str);
                },
                parse: function parse(input) {
                    var self = this,
                        stack = [0],
                        vstack = [null],
                        lstack = [],
                        table = this.table,
                        yytext = "",
                        yylineno = 0,
                        yyleng = 0,
                        recovering = 0,
                        TERROR = 2,
                        EOF = 1;
                    this.lexer.setInput(input);
                    this.lexer.yy = this.yy;
                    this.yy.lexer = this.lexer;
                    this.yy.parser = this;
                    if (typeof this.lexer.yylloc == "undefined")
                        this.lexer.yylloc = {};
                    var yyloc = this.lexer.yylloc;
                    lstack.push(yyloc);
                    var ranges = this.lexer.options && this.lexer.options.ranges;
                    if (typeof this.yy.parseError === "function")
                        this.parseError = this.yy.parseError;

                    function popStack(n) {
                        stack.length = stack.length - 2 * n;
                        vstack.length = vstack.length - n;
                        lstack.length = lstack.length - n;
                    }

                    function lex() {
                        var token;
                        token = self.lexer.lex() || 1;
                        if (typeof token !== "number") {
                            token = self.symbols_[token] || token;
                        }
                        return token;
                    }
                    var symbol, preErrorSymbol, state, action, a, r, yyval = {},
                        p, len, newState, expected;
                    while (true) {
                        state = stack[stack.length - 1];
                        if (this.defaultActions[state]) {
                            action = this.defaultActions[state];
                        } else {
                            if (symbol === null || typeof symbol == "undefined") {
                                symbol = lex();
                            }
                            action = table[state] && table[state][symbol];
                        }
                        if (typeof action === "undefined" || !action.length || !action[0]) {
                            var errStr = "";
                            if (!recovering) {
                                expected = [];
                                for (p in table[state])
                                    if (this.terminals_[p] && p > 2) {
                                        expected.push("'" + this.terminals_[p] + "'");
                                    }
                                if (this.lexer.showPosition) {
                                    errStr = "Parse error on line " + (yylineno + 1) + ":\n" + this.lexer.showPosition() + "\nExpecting " + expected.join(", ") + ", got '" + (this.terminals_[symbol] || symbol) + "'";
                                } else {
                                    errStr = "Parse error on line " + (yylineno + 1) + ": Unexpected " + (symbol == 1 ? "end of input" : "'" + (this.terminals_[symbol] || symbol) + "'");
                                }
                                this.parseError(errStr, {
                                    text: this.lexer.match,
                                    token: this.terminals_[symbol] || symbol,
                                    line: this.lexer.yylineno,
                                    loc: yyloc,
                                    expected: expected
                                });
                            }
                        }
                        if (action[0] instanceof Array && action.length > 1) {
                            throw new Error("Parse Error: multiple actions possible at state: " + state + ", token: " + symbol);
                        }
                        switch (action[0]) {
                            case 1:
                                stack.push(symbol);
                                vstack.push(this.lexer.yytext);
                                lstack.push(this.lexer.yylloc);
                                stack.push(action[1]);
                                symbol = null;
                                if (!preErrorSymbol) {
                                    yyleng = this.lexer.yyleng;
                                    yytext = this.lexer.yytext;
                                    yylineno = this.lexer.yylineno;
                                    yyloc = this.lexer.yylloc;
                                    if (recovering > 0)
                                        recovering--;
                                } else {
                                    symbol = preErrorSymbol;
                                    preErrorSymbol = null;
                                }
                                break;
                            case 2:
                                len = this.productions_[action[1]][1];
                                yyval.$ = vstack[vstack.length - len];
                                yyval._$ = {
                                    first_line: lstack[lstack.length - (len || 1)].first_line,
                                    last_line: lstack[lstack.length - 1].last_line,
                                    first_column: lstack[lstack.length - (len || 1)].first_column,
                                    last_column: lstack[lstack.length - 1].last_column
                                };
                                if (ranges) {
                                    yyval._$.range = [lstack[lstack.length - (len || 1)].range[0], lstack[lstack.length - 1].range[1]];
                                }
                                r = this.performAction.call(yyval, yytext, yyleng, yylineno, this.yy, action[1], vstack, lstack);
                                if (typeof r !== "undefined") {
                                    return r;
                                }
                                if (len) {
                                    stack = stack.slice(0, -1 * len * 2);
                                    vstack = vstack.slice(0, -1 * len);
                                    lstack = lstack.slice(0, -1 * len);
                                }
                                stack.push(this.productions_[action[1]][0]);
                                vstack.push(yyval.$);
                                lstack.push(yyval._$);
                                newState = table[stack[stack.length - 2]][stack[stack.length - 1]];
                                stack.push(newState);
                                break;
                            case 3:
                                return true;
                        }
                    }
                    return true;
                }
            };
            /* Jison generated lexer */
            var lexer = (function() {
                var lexer = ({
                    EOF: 1,
                    parseError: function parseError(str, hash) {
                        if (this.yy.parser) {
                            this.yy.parser.parseError(str, hash);
                        } else {
                            throw new Error(str);
                        }
                    },
                    setInput: function(input) {
                        this._input = input;
                        this._more = this._less = this.done = false;
                        this.yylineno = this.yyleng = 0;
                        this.yytext = this.matched = this.match = '';
                        this.conditionStack = ['INITIAL'];
                        this.yylloc = {
                            first_line: 1,
                            first_column: 0,
                            last_line: 1,
                            last_column: 0
                        };
                        if (this.options.ranges) this.yylloc.range = [0, 0];
                        this.offset = 0;
                        return this;
                    },
                    input: function() {
                        var ch = this._input[0];
                        this.yytext += ch;
                        this.yyleng++;
                        this.offset++;
                        this.match += ch;
                        this.matched += ch;
                        var lines = ch.match(/(?:\r\n?|\n).*/g);
                        if (lines) {
                            this.yylineno++;
                            this.yylloc.last_line++;
                        } else {
                            this.yylloc.last_column++;
                        }
                        if (this.options.ranges) this.yylloc.range[1] ++;

                        this._input = this._input.slice(1);
                        return ch;
                    },
                    unput: function(ch) {
                        var len = ch.length;
                        var lines = ch.split(/(?:\r\n?|\n)/g);

                        this._input = ch + this._input;
                        this.yytext = this.yytext.substr(0, this.yytext.length - len - 1);
                        //this.yyleng -= len;
                        this.offset -= len;
                        var oldLines = this.match.split(/(?:\r\n?|\n)/g);
                        this.match = this.match.substr(0, this.match.length - 1);
                        this.matched = this.matched.substr(0, this.matched.length - 1);

                        if (lines.length - 1) this.yylineno -= lines.length - 1;
                        var r = this.yylloc.range;

                        this.yylloc = {
                            first_line: this.yylloc.first_line,
                            last_line: this.yylineno + 1,
                            first_column: this.yylloc.first_column,
                            last_column: lines ?
                                (lines.length === oldLines.length ? this.yylloc.first_column : 0) + oldLines[oldLines.length - lines.length].length - lines[0].length : this.yylloc.first_column - len
                        };

                        if (this.options.ranges) {
                            this.yylloc.range = [r[0], r[0] + this.yyleng - len];
                        }
                        return this;
                    },
                    more: function() {
                        this._more = true;
                        return this;
                    },
                    less: function(n) {
                        this.unput(this.match.slice(n));
                    },
                    pastInput: function() {
                        var past = this.matched.substr(0, this.matched.length - this.match.length);
                        return (past.length > 20 ? '...' : '') + past.substr(-20).replace(/\n/g, "");
                    },
                    upcomingInput: function() {
                        var next = this.match;
                        if (next.length < 20) {
                            next += this._input.substr(0, 20 - next.length);
                        }
                        return (next.substr(0, 20) + (next.length > 20 ? '...' : '')).replace(/\n/g, "");
                    },
                    showPosition: function() {
                        var pre = this.pastInput();
                        var c = new Array(pre.length + 1).join("-");
                        return pre + this.upcomingInput() + "\n" + c + "^";
                    },
                    next: function() {
                        if (this.done) {
                            return this.EOF;
                        }
                        if (!this._input) this.done = true;

                        var token,
                            match,
                            tempMatch,
                            index,
                            col,
                            lines;
                        if (!this._more) {
                            this.yytext = '';
                            this.match = '';
                        }
                        var rules = this._currentRules();
                        for (var i = 0; i < rules.length; i++) {
                            tempMatch = this._input.match(this.rules[rules[i]]);
                            if (tempMatch && (!match || tempMatch[0].length > match[0].length)) {
                                match = tempMatch;
                                index = i;
                                if (!this.options.flex) break;
                            }
                        }
                        if (match) {
                            lines = match[0].match(/(?:\r\n?|\n).*/g);
                            if (lines) this.yylineno += lines.length;
                            this.yylloc = {
                                first_line: this.yylloc.last_line,
                                last_line: this.yylineno + 1,
                                first_column: this.yylloc.last_column,
                                last_column: lines ? lines[lines.length - 1].length - lines[lines.length - 1].match(/\r?\n?/)[0].length : this.yylloc.last_column + match[0].length
                            };
                            this.yytext += match[0];
                            this.match += match[0];
                            this.matches = match;
                            this.yyleng = this.yytext.length;
                            if (this.options.ranges) {
                                this.yylloc.range = [this.offset, this.offset += this.yyleng];
                            }
                            this._more = false;
                            this._input = this._input.slice(match[0].length);
                            this.matched += match[0];
                            token = this.performAction.call(this, this.yy, this, rules[index], this.conditionStack[this.conditionStack.length - 1]);
                            if (this.done && this._input) this.done = false;
                            if (token) return token;
                            else return;
                        }
                        if (this._input === "") {
                            return this.EOF;
                        } else {
                            return this.parseError('Lexical error on line ' + (this.yylineno + 1) + '. Unrecognized text.\n' + this.showPosition(), {
                                text: "",
                                token: null,
                                line: this.yylineno
                            });
                        }
                    },
                    lex: function lex() {
                        var r = this.next();
                        if (typeof r !== 'undefined') {
                            return r;
                        } else {
                            return this.lex();
                        }
                    },
                    begin: function begin(condition) {
                        this.conditionStack.push(condition);
                    },
                    popState: function popState() {
                        return this.conditionStack.pop();
                    },
                    _currentRules: function _currentRules() {
                        return this.conditions[this.conditionStack[this.conditionStack.length - 1]].rules;
                    },
                    topState: function() {
                        return this.conditionStack[this.conditionStack.length - 2];
                    },
                    pushState: function begin(condition) {
                        this.begin(condition);
                    }
                });
                lexer.options = {};
                lexer.performAction = function anonymous(yy, yy_, $avoiding_name_collisions, YY_START) {


                    function strip(start, end) {
                        return yy_.yytext = yy_.yytext.substr(start, yy_.yyleng - end);
                    }


                    var YYSTATE = YY_START
                    switch ($avoiding_name_collisions) {
                        case 0:
                            if (yy_.yytext.slice(-2) === "\\\\") {
                                strip(0, 1);
                                this.begin("mu");
                            } else if (yy_.yytext.slice(-1) === "\\") {
                                strip(0, 1);
                                this.begin("emu");
                            } else {
                                this.begin("mu");
                            }
                            if (yy_.yytext) return 12;

                            break;
                        case 1:
                            return 12;
                            break;
                        case 2:
                            this.popState();
                            return 12;

                            break;
                        case 3:
                            yy_.yytext = yy_.yytext.substr(5, yy_.yyleng - 9);
                            this.popState();
                            return 15;

                            break;
                        case 4:
                            return 12;
                            break;
                        case 5:
                            strip(0, 4);
                            this.popState();
                            return 13;
                            break;
                        case 6:
                            return 45;
                            break;
                        case 7:
                            return 46;
                            break;
                        case 8:
                            return 16;
                            break;
                        case 9:
                            this.popState();
                            this.begin('raw');
                            return 18;

                            break;
                        case 10:
                            return 34;
                            break;
                        case 11:
                            return 24;
                            break;
                        case 12:
                            return 29;
                            break;
                        case 13:
                            this.popState();
                            return 28;
                            break;
                        case 14:
                            this.popState();
                            return 28;
                            break;
                        case 15:
                            return 26;
                            break;
                        case 16:
                            return 26;
                            break;
                        case 17:
                            return 32;
                            break;
                        case 18:
                            return 31;
                            break;
                        case 19:
                            this.popState();
                            this.begin('com');
                            break;
                        case 20:
                            strip(3, 5);
                            this.popState();
                            return 13;
                            break;
                        case 21:
                            return 31;
                            break;
                        case 22:
                            return 51;
                            break;
                        case 23:
                            return 50;
                            break;
                        case 24:
                            return 50;
                            break;
                        case 25:
                            return 54;
                            break;
                        case 26: // ignore whitespace
                            break;
                        case 27:
                            this.popState();
                            return 33;
                            break;
                        case 28:
                            this.popState();
                            return 25;
                            break;
                        case 29:
                            yy_.yytext = strip(1, 2).replace(/\\"/g, '"');
                            return 42;
                            break;
                        case 30:
                            yy_.yytext = strip(1, 2).replace(/\\'/g, "'");
                            return 42;
                            break;
                        case 31:
                            return 52;
                            break;
                        case 32:
                            return 44;
                            break;
                        case 33:
                            return 44;
                            break;
                        case 34:
                            return 43;
                            break;
                        case 35:
                            return 50;
                            break;
                        case 36:
                            yy_.yytext = strip(1, 2);
                            return 50;
                            break;
                        case 37:
                            return 'INVALID';
                            break;
                        case 38:
                            return 5;
                            break;
                    }
                };
                lexer.rules = [/^(?:[^\x00]*?(?=(\{\{)))/, /^(?:[^\x00]+)/, /^(?:[^\x00]{2,}?(?=(\{\{|\\\{\{|\\\\\{\{|$)))/, /^(?:\{\{\{\{\/[^\s!"#%-,\.\/;->@\[-\^`\{-~]+(?=[=}\s\/.])\}\}\}\})/, /^(?:[^\x00]*?(?=(\{\{\{\{\/)))/, /^(?:[\s\S]*?--\}\})/, /^(?:\()/, /^(?:\))/, /^(?:\{\{\{\{)/, /^(?:\}\}\}\})/, /^(?:\{\{(~)?>)/, /^(?:\{\{(~)?#)/, /^(?:\{\{(~)?\/)/, /^(?:\{\{(~)?\^\s*(~)?\}\})/, /^(?:\{\{(~)?\s*else\s*(~)?\}\})/, /^(?:\{\{(~)?\^)/, /^(?:\{\{(~)?\s*else\b)/, /^(?:\{\{(~)?\{)/, /^(?:\{\{(~)?&)/, /^(?:\{\{!--)/, /^(?:\{\{![\s\S]*?\}\})/, /^(?:\{\{(~)?)/, /^(?:=)/, /^(?:\.\.)/, /^(?:\.(?=([=~}\s\/.)])))/, /^(?:[\/.])/, /^(?:\s+)/, /^(?:\}(~)?\}\})/, /^(?:(~)?\}\})/, /^(?:"(\\["]|[^"])*")/, /^(?:'(\\[']|[^'])*')/, /^(?:@)/, /^(?:true(?=([~}\s)])))/, /^(?:false(?=([~}\s)])))/, /^(?:-?[0-9]+(?:\.[0-9]+)?(?=([~}\s)])))/, /^(?:([^\s!"#%-,\.\/;->@\[-\^`\{-~]+(?=([=~}\s\/.)]))))/, /^(?:\[[^\]]*\])/, /^(?:.)/, /^(?:$)/];
                lexer.conditions = {
                    "mu": {
                        "rules": [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38],
                        "inclusive": false
                    },
                    "emu": {
                        "rules": [2],
                        "inclusive": false
                    },
                    "com": {
                        "rules": [5],
                        "inclusive": false
                    },
                    "raw": {
                        "rules": [3, 4],
                        "inclusive": false
                    },
                    "INITIAL": {
                        "rules": [0, 1, 38],
                        "inclusive": true
                    }
                };
                return lexer;
            })()
            parser.lexer = lexer;

            function Parser() {
                this.yy = {};
            }
            Parser.prototype = parser;
            parser.Parser = Parser;
            return new Parser;
        })();
        __exports__ = handlebars;
        /* jshint ignore:end */
        return __exports__;
    })();

    // handlebars/compiler/helpers.js
    var __module10__ = (function(__dependency1__) {
        "use strict";
        var __exports__ = {};
        var Exception = __dependency1__;

        function stripFlags(open, close) {
            return {
                left: open.charAt(2) === '~',
                right: close.charAt(close.length - 3) === '~'
            };
        }

        __exports__.stripFlags = stripFlags;

        function prepareBlock(mustache, program, inverseAndProgram, close, inverted, locInfo) {
            /*jshint -W040 */
            if (mustache.sexpr.id.original !== close.path.original) {
                throw new Exception(mustache.sexpr.id.original + ' doesn\'t match ' + close.path.original, mustache);
            }

            var inverse = inverseAndProgram && inverseAndProgram.program;

            var strip = {
                left: mustache.strip.left,
                right: close.strip.right,

                // Determine the standalone candiacy. Basically flag our content as being possibly standalone
                // so our parent can determine if we actually are standalone
                openStandalone: isNextWhitespace(program.statements),
                closeStandalone: isPrevWhitespace((inverse || program).statements)
            };

            if (mustache.strip.right) {
                omitRight(program.statements, null, true);
            }

            if (inverse) {
                var inverseStrip = inverseAndProgram.strip;

                if (inverseStrip.left) {
                    omitLeft(program.statements, null, true);
                }
                if (inverseStrip.right) {
                    omitRight(inverse.statements, null, true);
                }
                if (close.strip.left) {
                    omitLeft(inverse.statements, null, true);
                }

                // Find standalone else statments
                if (isPrevWhitespace(program.statements) && isNextWhitespace(inverse.statements)) {

                    omitLeft(program.statements);
                    omitRight(inverse.statements);
                }
            } else {
                if (close.strip.left) {
                    omitLeft(program.statements, null, true);
                }
            }

            if (inverted) {
                return new this.BlockNode(mustache, inverse, program, strip, locInfo);
            } else {
                return new this.BlockNode(mustache, program, inverse, strip, locInfo);
            }
        }

        __exports__.prepareBlock = prepareBlock;

        function prepareProgram(statements, isRoot) {
            for (var i = 0, l = statements.length; i < l; i++) {
                var current = statements[i],
                    strip = current.strip;

                if (!strip) {
                    continue;
                }

                var _isPrevWhitespace = isPrevWhitespace(statements, i, isRoot, current.type === 'partial'),
                    _isNextWhitespace = isNextWhitespace(statements, i, isRoot),

                    openStandalone = strip.openStandalone && _isPrevWhitespace,
                    closeStandalone = strip.closeStandalone && _isNextWhitespace,
                    inlineStandalone = strip.inlineStandalone && _isPrevWhitespace && _isNextWhitespace;

                if (strip.right) {
                    omitRight(statements, i, true);
                }
                if (strip.left) {
                    omitLeft(statements, i, true);
                }

                if (inlineStandalone) {
                    omitRight(statements, i);

                    if (omitLeft(statements, i)) {
                        // If we are on a standalone node, save the indent info for partials
                        if (current.type === 'partial') {
                            current.indent = (/([ \t]+$)/).exec(statements[i - 1].original) ? RegExp.$1 : '';
                        }
                    }
                }
                if (openStandalone) {
                    omitRight((current.program || current.inverse).statements);

                    // Strip out the previous content node if it's whitespace only
                    omitLeft(statements, i);
                }
                if (closeStandalone) {
                    // Always strip the next node
                    omitRight(statements, i);

                    omitLeft((current.inverse || current.program).statements);
                }
            }

            return statements;
        }

        __exports__.prepareProgram = prepareProgram;

        function isPrevWhitespace(statements, i, isRoot) {
            if (i === undefined) {
                i = statements.length;
            }

            // Nodes that end with newlines are considered whitespace (but are special
            // cased for strip operations)
            var prev = statements[i - 1],
                sibling = statements[i - 2];
            if (!prev) {
                return isRoot;
            }

            if (prev.type === 'content') {
                return (sibling || !isRoot ? (/\r?\n\s*?$/) : (/(^|\r?\n)\s*?$/)).test(prev.original);
            }
        }

        function isNextWhitespace(statements, i, isRoot) {
            if (i === undefined) {
                i = -1;
            }

            var next = statements[i + 1],
                sibling = statements[i + 2];
            if (!next) {
                return isRoot;
            }

            if (next.type === 'content') {
                return (sibling || !isRoot ? (/^\s*?\r?\n/) : (/^\s*?(\r?\n|$)/)).test(next.original);
            }
        }

        // Marks the node to the right of the position as omitted.
        // I.e. {{foo}}' ' will mark the ' ' node as omitted.
        //
        // If i is undefined, then the first child will be marked as such.
        //
        // If mulitple is truthy then all whitespace will be stripped out until non-whitespace
        // content is met.
        function omitRight(statements, i, multiple) {
            var current = statements[i == null ? 0 : i + 1];
            if (!current || current.type !== 'content' || (!multiple && current.rightStripped)) {
                return;
            }

            var original = current.string;
            current.string = current.string.replace(multiple ? (/^\s+/) : (/^[ \t]*\r?\n?/), '');
            current.rightStripped = current.string !== original;
        }

        // Marks the node to the left of the position as omitted.
        // I.e. ' '{{foo}} will mark the ' ' node as omitted.
        //
        // If i is undefined then the last child will be marked as such.
        //
        // If mulitple is truthy then all whitespace will be stripped out until non-whitespace
        // content is met.
        function omitLeft(statements, i, multiple) {
            var current = statements[i == null ? statements.length - 1 : i - 1];
            if (!current || current.type !== 'content' || (!multiple && current.leftStripped)) {
                return;
            }

            // We omit the last node if it's whitespace only and not preceeded by a non-content node.
            var original = current.string;
            current.string = current.string.replace(multiple ? (/\s+$/) : (/[ \t]+$/), '');
            current.leftStripped = current.string !== original;
            return current.leftStripped;
        }
        return __exports__;
    })(__module5__);

    // handlebars/compiler/base.js
    var __module8__ = (function(__dependency1__, __dependency2__, __dependency3__, __dependency4__) {
        "use strict";
        var __exports__ = {};
        var parser = __dependency1__;
        var AST = __dependency2__;
        var Helpers = __dependency3__;
        var extend = __dependency4__.extend;

        __exports__.parser = parser;

        var yy = {};
        extend(yy, Helpers, AST);

        function parse(input) {
            // Just return if an already-compile AST was passed in.
            if (input.constructor === AST.ProgramNode) {
                return input;
            }

            parser.yy = yy;

            return parser.parse(input);
        }

        __exports__.parse = parse;
        return __exports__;
    })(__module9__, __module7__, __module10__, __module3__);

    // handlebars/compiler/compiler.js
    var __module11__ = (function(__dependency1__, __dependency2__) {
        "use strict";
        var __exports__ = {};
        var Exception = __dependency1__;
        var isArray = __dependency2__.isArray;

        var slice = [].slice;

        function Compiler() {}

        __exports__.Compiler = Compiler; // the foundHelper register will disambiguate helper lookup from finding a
        // function in a context. This is necessary for mustache compatibility, which
        // requires that context functions in blocks are evaluated by blockHelperMissing,
        // and then proceed as if the resulting value was provided to blockHelperMissing.

        Compiler.prototype = {
            compiler: Compiler,

            equals: function(other) {
                var len = this.opcodes.length;
                if (other.opcodes.length !== len) {
                    return false;
                }

                for (var i = 0; i < len; i++) {
                    var opcode = this.opcodes[i],
                        otherOpcode = other.opcodes[i];
                    if (opcode.opcode !== otherOpcode.opcode || !argEquals(opcode.args, otherOpcode.args)) {
                        return false;
                    }
                }

                // We know that length is the same between the two arrays because they are directly tied
                // to the opcode behavior above.
                len = this.children.length;
                for (i = 0; i < len; i++) {
                    if (!this.children[i].equals(other.children[i])) {
                        return false;
                    }
                }

                return true;
            },

            guid: 0,

            compile: function(program, options) {
                this.opcodes = [];
                this.children = [];
                this.depths = {
                    list: []
                };
                this.options = options;
                this.stringParams = options.stringParams;
                this.trackIds = options.trackIds;

                // These changes will propagate to the other compiler components
                var knownHelpers = this.options.knownHelpers;
                this.options.knownHelpers = {
                    'helperMissing': true,
                    'blockHelperMissing': true,
                    'each': true,
                    'if': true,
                    'unless': true,
                    'with': true,
                    'log': true,
                    'lookup': true
                };
                if (knownHelpers) {
                    for (var name in knownHelpers) {
                        this.options.knownHelpers[name] = knownHelpers[name];
                    }
                }

                return this.accept(program);
            },

            accept: function(node) {
                return this[node.type](node);
            },

            program: function(program) {
                var statements = program.statements;

                for (var i = 0, l = statements.length; i < l; i++) {
                    this.accept(statements[i]);
                }
                this.isSimple = l === 1;

                this.depths.list = this.depths.list.sort(function(a, b) {
                    return a - b;
                });

                return this;
            },

            compileProgram: function(program) {
                var result = new this.compiler().compile(program, this.options);
                var guid = this.guid++,
                    depth;

                this.usePartial = this.usePartial || result.usePartial;

                this.children[guid] = result;

                for (var i = 0, l = result.depths.list.length; i < l; i++) {
                    depth = result.depths.list[i];

                    if (depth < 2) {
                        continue;
                    } else {
                        this.addDepth(depth - 1);
                    }
                }

                return guid;
            },

            block: function(block) {
                var mustache = block.mustache,
                    program = block.program,
                    inverse = block.inverse;

                if (program) {
                    program = this.compileProgram(program);
                }

                if (inverse) {
                    inverse = this.compileProgram(inverse);
                }

                var sexpr = mustache.sexpr;
                var type = this.classifySexpr(sexpr);

                if (type === "helper") {
                    this.helperSexpr(sexpr, program, inverse);
                } else if (type === "simple") {
                    this.simpleSexpr(sexpr);

                    // now that the simple mustache is resolved, we need to
                    // evaluate it by executing `blockHelperMissing`
                    this.opcode('pushProgram', program);
                    this.opcode('pushProgram', inverse);
                    this.opcode('emptyHash');
                    this.opcode('blockValue', sexpr.id.original);
                } else {
                    this.ambiguousSexpr(sexpr, program, inverse);

                    // now that the simple mustache is resolved, we need to
                    // evaluate it by executing `blockHelperMissing`
                    this.opcode('pushProgram', program);
                    this.opcode('pushProgram', inverse);
                    this.opcode('emptyHash');
                    this.opcode('ambiguousBlockValue');
                }

                this.opcode('append');
            },

            hash: function(hash) {
                var pairs = hash.pairs,
                    i, l;

                this.opcode('pushHash');

                for (i = 0, l = pairs.length; i < l; i++) {
                    this.pushParam(pairs[i][1]);
                }
                while (i--) {
                    this.opcode('assignToHash', pairs[i][0]);
                }
                this.opcode('popHash');
            },

            partial: function(partial) {
                var partialName = partial.partialName;
                this.usePartial = true;

                if (partial.hash) {
                    this.accept(partial.hash);
                } else {
                    this.opcode('push', 'undefined');
                }

                if (partial.context) {
                    this.accept(partial.context);
                } else {
                    this.opcode('getContext', 0);
                    this.opcode('pushContext');
                }

                this.opcode('invokePartial', partialName.name, partial.indent || '');
                this.opcode('append');
            },

            content: function(content) {
                if (content.string) {
                    this.opcode('appendContent', content.string);
                }
            },

            mustache: function(mustache) {
                this.sexpr(mustache.sexpr);

                if (mustache.escaped && !this.options.noEscape) {
                    this.opcode('appendEscaped');
                } else {
                    this.opcode('append');
                }
            },

            ambiguousSexpr: function(sexpr, program, inverse) {
                var id = sexpr.id,
                    name = id.parts[0],
                    isBlock = program != null || inverse != null;

                this.opcode('getContext', id.depth);

                this.opcode('pushProgram', program);
                this.opcode('pushProgram', inverse);

                this.ID(id);

                this.opcode('invokeAmbiguous', name, isBlock);
            },

            simpleSexpr: function(sexpr) {
                var id = sexpr.id;

                if (id.type === 'DATA') {
                    this.DATA(id);
                } else if (id.parts.length) {
                    this.ID(id);
                } else {
                    // Simplified ID for `this`
                    this.addDepth(id.depth);
                    this.opcode('getContext', id.depth);
                    this.opcode('pushContext');
                }

                this.opcode('resolvePossibleLambda');
            },

            helperSexpr: function(sexpr, program, inverse) {
                var params = this.setupFullMustacheParams(sexpr, program, inverse),
                    id = sexpr.id,
                    name = id.parts[0];

                if (this.options.knownHelpers[name]) {
                    this.opcode('invokeKnownHelper', params.length, name);
                } else if (this.options.knownHelpersOnly) {
                    throw new Exception("You specified knownHelpersOnly, but used the unknown helper " + name, sexpr);
                } else {
                    id.falsy = true;

                    this.ID(id);
                    this.opcode('invokeHelper', params.length, id.original, id.isSimple);
                }
            },

            sexpr: function(sexpr) {
                var type = this.classifySexpr(sexpr);

                if (type === "simple") {
                    this.simpleSexpr(sexpr);
                } else if (type === "helper") {
                    this.helperSexpr(sexpr);
                } else {
                    this.ambiguousSexpr(sexpr);
                }
            },

            ID: function(id) {
                this.addDepth(id.depth);
                this.opcode('getContext', id.depth);

                var name = id.parts[0];
                if (!name) {
                    // Context reference, i.e. `{{foo .}}` or `{{foo ..}}`
                    this.opcode('pushContext');
                } else {
                    this.opcode('lookupOnContext', id.parts, id.falsy, id.isScoped);
                }
            },

            DATA: function(data) {
                this.options.data = true;
                this.opcode('lookupData', data.id.depth, data.id.parts);
            },

            STRING: function(string) {
                this.opcode('pushString', string.string);
            },

            NUMBER: function(number) {
                this.opcode('pushLiteral', number.number);
            },

            BOOLEAN: function(bool) {
                this.opcode('pushLiteral', bool.bool);
            },

            comment: function() {},

            // HELPERS
            opcode: function(name) {
                this.opcodes.push({
                    opcode: name,
                    args: slice.call(arguments, 1)
                });
            },

            addDepth: function(depth) {
                if (depth === 0) {
                    return;
                }

                if (!this.depths[depth]) {
                    this.depths[depth] = true;
                    this.depths.list.push(depth);
                }
            },

            classifySexpr: function(sexpr) {
                var isHelper = sexpr.isHelper;
                var isEligible = sexpr.eligibleHelper;
                var options = this.options;

                // if ambiguous, we can possibly resolve the ambiguity now
                // An eligible helper is one that does not have a complex path, i.e. `this.foo`, `../foo` etc.
                if (isEligible && !isHelper) {
                    var name = sexpr.id.parts[0];

                    if (options.knownHelpers[name]) {
                        isHelper = true;
                    } else if (options.knownHelpersOnly) {
                        isEligible = false;
                    }
                }

                if (isHelper) {
                    return "helper";
                } else if (isEligible) {
                    return "ambiguous";
                } else {
                    return "simple";
                }
            },

            pushParams: function(params) {
                for (var i = 0, l = params.length; i < l; i++) {
                    this.pushParam(params[i]);
                }
            },

            pushParam: function(val) {
                if (this.stringParams) {
                    if (val.depth) {
                        this.addDepth(val.depth);
                    }
                    this.opcode('getContext', val.depth || 0);
                    this.opcode('pushStringParam', val.stringModeValue, val.type);

                    if (val.type === 'sexpr') {
                        // Subexpressions get evaluated and passed in
                        // in string params mode.
                        this.sexpr(val);
                    }
                } else {
                    if (this.trackIds) {
                        this.opcode('pushId', val.type, val.idName || val.stringModeValue);
                    }
                    this.accept(val);
                }
            },

            setupFullMustacheParams: function(sexpr, program, inverse) {
                var params = sexpr.params;
                this.pushParams(params);

                this.opcode('pushProgram', program);
                this.opcode('pushProgram', inverse);

                if (sexpr.hash) {
                    this.hash(sexpr.hash);
                } else {
                    this.opcode('emptyHash');
                }

                return params;
            }
        };

        function precompile(input, options, env) {
            if (input == null || (typeof input !== 'string' && input.constructor !== env.AST.ProgramNode)) {
                throw new Exception("You must pass a string or Handlebars AST to Handlebars.precompile. You passed " + input);
            }

            options = options || {};
            if (!('data' in options)) {
                options.data = true;
            }
            if (options.compat) {
                options.useDepths = true;
            }

            var ast = env.parse(input);
            var environment = new env.Compiler().compile(ast, options);
            return new env.JavaScriptCompiler().compile(environment, options);
        }

        __exports__.precompile = precompile;

        function compile(input, options, env) {
            if (input == null || (typeof input !== 'string' && input.constructor !== env.AST.ProgramNode)) {
                throw new Exception("You must pass a string or Handlebars AST to Handlebars.compile. You passed " + input);
            }

            options = options || {};

            if (!('data' in options)) {
                options.data = true;
            }
            if (options.compat) {
                options.useDepths = true;
            }

            var compiled;

            function compileInput() {
                var ast = env.parse(input);
                var environment = new env.Compiler().compile(ast, options);
                var templateSpec = new env.JavaScriptCompiler().compile(environment, options, undefined, true);
                return env.template(templateSpec);
            }

            // Template is only compiled on first use and cached after that point.
            var ret = function(context, options) {
                if (!compiled) {
                    compiled = compileInput();
                }
                return compiled.call(this, context, options);
            };
            ret._setup = function(options) {
                if (!compiled) {
                    compiled = compileInput();
                }
                return compiled._setup(options);
            };
            ret._child = function(i, data, depths) {
                if (!compiled) {
                    compiled = compileInput();
                }
                return compiled._child(i, data, depths);
            };
            return ret;
        }

        __exports__.compile = compile;

        function argEquals(a, b) {
            if (a === b) {
                return true;
            }

            if (isArray(a) && isArray(b) && a.length === b.length) {
                for (var i = 0; i < a.length; i++) {
                    if (!argEquals(a[i], b[i])) {
                        return false;
                    }
                }
                return true;
            }
        }
        return __exports__;
    })(__module5__, __module3__);

    // handlebars/compiler/javascript-compiler.js
    var __module12__ = (function(__dependency1__, __dependency2__) {
        "use strict";
        var __exports__;
        var COMPILER_REVISION = __dependency1__.COMPILER_REVISION;
        var REVISION_CHANGES = __dependency1__.REVISION_CHANGES;
        var Exception = __dependency2__;

        function Literal(value) {
            this.value = value;
        }

        function JavaScriptCompiler() {}

        JavaScriptCompiler.prototype = {
            // PUBLIC API: You can override these methods in a subclass to provide
            // alternative compiled forms for name lookup and buffering semantics
            nameLookup: function(parent, name /* , type*/ ) {
                if (JavaScriptCompiler.isValidJavaScriptVariableName(name)) {
                    return parent + "." + name;
                } else {
                    return parent + "['" + name + "']";
                }
            },
            depthedLookup: function(name) {
                this.aliases.lookup = 'this.lookup';

                return 'lookup(depths, "' + name + '")';
            },

            compilerInfo: function() {
                var revision = COMPILER_REVISION,
                    versions = REVISION_CHANGES[revision];
                return [revision, versions];
            },

            appendToBuffer: function(string) {
                if (this.environment.isSimple) {
                    return "return " + string + ";";
                } else {
                    return {
                        appendToBuffer: true,
                        content: string,
                        toString: function() {
                            return "buffer += " + string + ";";
                        }
                    };
                }
            },

            initializeBuffer: function() {
                return this.quotedString("");
            },

            namespace: "Handlebars",
            // END PUBLIC API

            compile: function(environment, options, context, asObject) {
                this.environment = environment;
                this.options = options;
                this.stringParams = this.options.stringParams;
                this.trackIds = this.options.trackIds;
                this.precompile = !asObject;

                this.name = this.environment.name;
                this.isChild = !!context;
                this.context = context || {
                    programs: [],
                    environments: []
                };

                this.preamble();

                this.stackSlot = 0;
                this.stackVars = [];
                this.aliases = {};
                this.registers = {
                    list: []
                };
                this.hashes = [];
                this.compileStack = [];
                this.inlineStack = [];

                this.compileChildren(environment, options);

                this.useDepths = this.useDepths || environment.depths.list.length || this.options.compat;

                var opcodes = environment.opcodes,
                    opcode,
                    i,
                    l;

                for (i = 0, l = opcodes.length; i < l; i++) {
                    opcode = opcodes[i];

                    this[opcode.opcode].apply(this, opcode.args);
                }

                // Flush any trailing content that might be pending.
                this.pushSource('');

                /* istanbul ignore next */
                if (this.stackSlot || this.inlineStack.length || this.compileStack.length) {
                    throw new Exception('Compile completed with content left on stack');
                }

                var fn = this.createFunctionContext(asObject);
                if (!this.isChild) {
                    var ret = {
                        compiler: this.compilerInfo(),
                        main: fn
                    };
                    var programs = this.context.programs;
                    for (i = 0, l = programs.length; i < l; i++) {
                        if (programs[i]) {
                            ret[i] = programs[i];
                        }
                    }

                    if (this.environment.usePartial) {
                        ret.usePartial = true;
                    }
                    if (this.options.data) {
                        ret.useData = true;
                    }
                    if (this.useDepths) {
                        ret.useDepths = true;
                    }
                    if (this.options.compat) {
                        ret.compat = true;
                    }

                    if (!asObject) {
                        ret.compiler = JSON.stringify(ret.compiler);
                        ret = this.objectLiteral(ret);
                    }

                    return ret;
                } else {
                    return fn;
                }
            },

            preamble: function() {
                // track the last context pushed into place to allow skipping the
                // getContext opcode when it would be a noop
                this.lastContext = 0;
                this.source = [];
            },

            createFunctionContext: function(asObject) {
                var varDeclarations = '';

                var locals = this.stackVars.concat(this.registers.list);
                if (locals.length > 0) {
                    varDeclarations += ", " + locals.join(", ");
                }

                // Generate minimizer alias mappings
                for (var alias in this.aliases) {
                    if (this.aliases.hasOwnProperty(alias)) {
                        varDeclarations += ', ' + alias + '=' + this.aliases[alias];
                    }
                }

                var params = ["depth0", "helpers", "partials", "data"];

                if (this.useDepths) {
                    params.push('depths');
                }

                // Perform a second pass over the output to merge content when possible
                var source = this.mergeSource(varDeclarations);

                if (asObject) {
                    params.push(source);

                    return Function.apply(this, params);
                } else {
                    return 'function(' + params.join(',') + ') {\n  ' + source + '}';
                }
            },
            mergeSource: function(varDeclarations) {
                var source = '',
                    buffer,
                    appendOnly = !this.forceBuffer,
                    appendFirst;

                for (var i = 0, len = this.source.length; i < len; i++) {
                    var line = this.source[i];
                    if (line.appendToBuffer) {
                        if (buffer) {
                            buffer = buffer + '\n    + ' + line.content;
                        } else {
                            buffer = line.content;
                        }
                    } else {
                        if (buffer) {
                            if (!source) {
                                appendFirst = true;
                                source = buffer + ';\n  ';
                            } else {
                                source += 'buffer += ' + buffer + ';\n  ';
                            }
                            buffer = undefined;
                        }
                        source += line + '\n  ';

                        if (!this.environment.isSimple) {
                            appendOnly = false;
                        }
                    }
                }

                if (appendOnly) {
                    if (buffer || !source) {
                        source += 'return ' + (buffer || '""') + ';\n';
                    }
                } else {
                    varDeclarations += ", buffer = " + (appendFirst ? '' : this.initializeBuffer());
                    if (buffer) {
                        source += 'return buffer + ' + buffer + ';\n';
                    } else {
                        source += 'return buffer;\n';
                    }
                }

                if (varDeclarations) {
                    source = 'var ' + varDeclarations.substring(2) + (appendFirst ? '' : ';\n  ') + source;
                }

                return source;
            },

            // [blockValue]
            //
            // On stack, before: hash, inverse, program, value
            // On stack, after: return value of blockHelperMissing
            //
            // The purpose of this opcode is to take a block of the form
            // `{{#this.foo}}...{{/this.foo}}`, resolve the value of `foo`, and
            // replace it on the stack with the result of properly
            // invoking blockHelperMissing.
            blockValue: function(name) {
                this.aliases.blockHelperMissing = 'helpers.blockHelperMissing';

                var params = [this.contextName(0)];
                this.setupParams(name, 0, params);

                var blockName = this.popStack();
                params.splice(1, 0, blockName);

                this.push('blockHelperMissing.call(' + params.join(', ') + ')');
            },

            // [ambiguousBlockValue]
            //
            // On stack, before: hash, inverse, program, value
            // Compiler value, before: lastHelper=value of last found helper, if any
            // On stack, after, if no lastHelper: same as [blockValue]
            // On stack, after, if lastHelper: value
            ambiguousBlockValue: function() {
                this.aliases.blockHelperMissing = 'helpers.blockHelperMissing';

                // We're being a bit cheeky and reusing the options value from the prior exec
                var params = [this.contextName(0)];
                this.setupParams('', 0, params, true);

                this.flushInline();

                var current = this.topStack();
                params.splice(1, 0, current);

                this.pushSource("if (!" + this.lastHelper + ") { " + current + " = blockHelperMissing.call(" + params.join(", ") + "); }");
            },

            // [appendContent]
            //
            // On stack, before: ...
            // On stack, after: ...
            //
            // Appends the string value of `content` to the current buffer
            appendContent: function(content) {
                if (this.pendingContent) {
                    content = this.pendingContent + content;
                }

                this.pendingContent = content;
            },

            // [append]
            //
            // On stack, before: value, ...
            // On stack, after: ...
            //
            // Coerces `value` to a String and appends it to the current buffer.
            //
            // If `value` is truthy, or 0, it is coerced into a string and appended
            // Otherwise, the empty string is appended
            append: function() {
                // Force anything that is inlined onto the stack so we don't have duplication
                // when we examine local
                this.flushInline();
                var local = this.popStack();
                this.pushSource('if (' + local + ' != null) { ' + this.appendToBuffer(local) + ' }');
                if (this.environment.isSimple) {
                    this.pushSource("else { " + this.appendToBuffer("''") + " }");
                }
            },

            // [appendEscaped]
            //
            // On stack, before: value, ...
            // On stack, after: ...
            //
            // Escape `value` and append it to the buffer
            appendEscaped: function() {
                this.aliases.escapeExpression = 'this.escapeExpression';

                this.pushSource(this.appendToBuffer("escapeExpression(" + this.popStack() + ")"));
            },

            // [getContext]
            //
            // On stack, before: ...
            // On stack, after: ...
            // Compiler value, after: lastContext=depth
            //
            // Set the value of the `lastContext` compiler value to the depth
            getContext: function(depth) {
                this.lastContext = depth;
            },

            // [pushContext]
            //
            // On stack, before: ...
            // On stack, after: currentContext, ...
            //
            // Pushes the value of the current context onto the stack.
            pushContext: function() {
                this.pushStackLiteral(this.contextName(this.lastContext));
            },

            // [lookupOnContext]
            //
            // On stack, before: ...
            // On stack, after: currentContext[name], ...
            //
            // Looks up the value of `name` on the current context and pushes
            // it onto the stack.
            lookupOnContext: function(parts, falsy, scoped) {
                /*jshint -W083 */
                var i = 0,
                    len = parts.length;

                if (!scoped && this.options.compat && !this.lastContext) {
                    // The depthed query is expected to handle the undefined logic for the root level that
                    // is implemented below, so we evaluate that directly in compat mode
                    this.push(this.depthedLookup(parts[i++]));
                } else {
                    this.pushContext();
                }

                for (; i < len; i++) {
                    this.replaceStack(function(current) {
                        var lookup = this.nameLookup(current, parts[i], 'context');
                        // We want to ensure that zero and false are handled properly if the context (falsy flag)
                        // needs to have the special handling for these values.
                        if (!falsy) {
                            return ' != null ? ' + lookup + ' : ' + current;
                        } else {
                            // Otherwise we can use generic falsy handling
                            return ' && ' + lookup;
                        }
                    });
                }
            },

            // [lookupData]
            //
            // On stack, before: ...
            // On stack, after: data, ...
            //
            // Push the data lookup operator
            lookupData: function(depth, parts) {
                /*jshint -W083 */
                if (!depth) {
                    this.pushStackLiteral('data');
                } else {
                    this.pushStackLiteral('this.data(data, ' + depth + ')');
                }

                var len = parts.length;
                for (var i = 0; i < len; i++) {
                    this.replaceStack(function(current) {
                        return ' && ' + this.nameLookup(current, parts[i], 'data');
                    });
                }
            },

            // [resolvePossibleLambda]
            //
            // On stack, before: value, ...
            // On stack, after: resolved value, ...
            //
            // If the `value` is a lambda, replace it on the stack by
            // the return value of the lambda
            resolvePossibleLambda: function() {
                this.aliases.lambda = 'this.lambda';

                this.push('lambda(' + this.popStack() + ', ' + this.contextName(0) + ')');
            },

            // [pushStringParam]
            //
            // On stack, before: ...
            // On stack, after: string, currentContext, ...
            //
            // This opcode is designed for use in string mode, which
            // provides the string value of a parameter along with its
            // depth rather than resolving it immediately.
            pushStringParam: function(string, type) {
                this.pushContext();
                this.pushString(type);

                // If it's a subexpression, the string result
                // will be pushed after this opcode.
                if (type !== 'sexpr') {
                    if (typeof string === 'string') {
                        this.pushString(string);
                    } else {
                        this.pushStackLiteral(string);
                    }
                }
            },

            emptyHash: function() {
                this.pushStackLiteral('{}');

                if (this.trackIds) {
                    this.push('{}'); // hashIds
                }
                if (this.stringParams) {
                    this.push('{}'); // hashContexts
                    this.push('{}'); // hashTypes
                }
            },
            pushHash: function() {
                if (this.hash) {
                    this.hashes.push(this.hash);
                }
                this.hash = {
                    values: [],
                    types: [],
                    contexts: [],
                    ids: []
                };
            },
            popHash: function() {
                var hash = this.hash;
                this.hash = this.hashes.pop();

                if (this.trackIds) {
                    this.push('{' + hash.ids.join(',') + '}');
                }
                if (this.stringParams) {
                    this.push('{' + hash.contexts.join(',') + '}');
                    this.push('{' + hash.types.join(',') + '}');
                }

                this.push('{\n    ' + hash.values.join(',\n    ') + '\n  }');
            },

            // [pushString]
            //
            // On stack, before: ...
            // On stack, after: quotedString(string), ...
            //
            // Push a quoted version of `string` onto the stack
            pushString: function(string) {
                this.pushStackLiteral(this.quotedString(string));
            },

            // [push]
            //
            // On stack, before: ...
            // On stack, after: expr, ...
            //
            // Push an expression onto the stack
            push: function(expr) {
                this.inlineStack.push(expr);
                return expr;
            },

            // [pushLiteral]
            //
            // On stack, before: ...
            // On stack, after: value, ...
            //
            // Pushes a value onto the stack. This operation prevents
            // the compiler from creating a temporary variable to hold
            // it.
            pushLiteral: function(value) {
                this.pushStackLiteral(value);
            },

            // [pushProgram]
            //
            // On stack, before: ...
            // On stack, after: program(guid), ...
            //
            // Push a program expression onto the stack. This takes
            // a compile-time guid and converts it into a runtime-accessible
            // expression.
            pushProgram: function(guid) {
                if (guid != null) {
                    this.pushStackLiteral(this.programExpression(guid));
                } else {
                    this.pushStackLiteral(null);
                }
            },

            // [invokeHelper]
            //
            // On stack, before: hash, inverse, program, params..., ...
            // On stack, after: result of helper invocation
            //
            // Pops off the helper's parameters, invokes the helper,
            // and pushes the helper's return value onto the stack.
            //
            // If the helper is not found, `helperMissing` is called.
            invokeHelper: function(paramSize, name, isSimple) {
                this.aliases.helperMissing = 'helpers.helperMissing';

                var nonHelper = this.popStack();
                var helper = this.setupHelper(paramSize, name);

                var lookup = (isSimple ? helper.name + ' || ' : '') + nonHelper + ' || helperMissing';
                this.push('((' + lookup + ').call(' + helper.callParams + '))');
            },

            // [invokeKnownHelper]
            //
            // On stack, before: hash, inverse, program, params..., ...
            // On stack, after: result of helper invocation
            //
            // This operation is used when the helper is known to exist,
            // so a `helperMissing` fallback is not required.
            invokeKnownHelper: function(paramSize, name) {
                var helper = this.setupHelper(paramSize, name);
                this.push(helper.name + ".call(" + helper.callParams + ")");
            },

            // [invokeAmbiguous]
            //
            // On stack, before: hash, inverse, program, params..., ...
            // On stack, after: result of disambiguation
            //
            // This operation is used when an expression like `{{foo}}`
            // is provided, but we don't know at compile-time whether it
            // is a helper or a path.
            //
            // This operation emits more code than the other options,
            // and can be avoided by passing the `knownHelpers` and
            // `knownHelpersOnly` flags at compile-time.
            invokeAmbiguous: function(name, helperCall) {
                this.aliases.functionType = '"function"';
                this.aliases.helperMissing = 'helpers.helperMissing';
                this.useRegister('helper');

                var nonHelper = this.popStack();

                this.emptyHash();
                var helper = this.setupHelper(0, name, helperCall);

                var helperName = this.lastHelper = this.nameLookup('helpers', name, 'helper');

                this.push(
                    '((helper = (helper = ' + helperName + ' || ' + nonHelper + ') != null ? helper : helperMissing' + (helper.paramsInit ? '),(' + helper.paramsInit : '') + '),' + '(typeof helper === functionType ? helper.call(' + helper.callParams + ') : helper))');
            },

            // [invokePartial]
            //
            // On stack, before: context, ...
            // On stack after: result of partial invocation
            //
            // This operation pops off a context, invokes a partial with that context,
            // and pushes the result of the invocation back.
            invokePartial: function(name, indent) {
                var params = [this.nameLookup('partials', name, 'partial'), "'" + indent + "'", "'" + name + "'", this.popStack(), this.popStack(), "helpers", "partials"];

                if (this.options.data) {
                    params.push("data");
                } else if (this.options.compat) {
                    params.push('undefined');
                }
                if (this.options.compat) {
                    params.push('depths');
                }

                this.push("this.invokePartial(" + params.join(", ") + ")");
            },

            // [assignToHash]
            //
            // On stack, before: value, ..., hash, ...
            // On stack, after: ..., hash, ...
            //
            // Pops a value off the stack and assigns it to the current hash
            assignToHash: function(key) {
                var value = this.popStack(),
                    context,
                    type,
                    id;

                if (this.trackIds) {
                    id = this.popStack();
                }
                if (this.stringParams) {
                    type = this.popStack();
                    context = this.popStack();
                }

                var hash = this.hash;
                if (context) {
                    hash.contexts.push("'" + key + "': " + context);
                }
                if (type) {
                    hash.types.push("'" + key + "': " + type);
                }
                if (id) {
                    hash.ids.push("'" + key + "': " + id);
                }
                hash.values.push("'" + key + "': (" + value + ")");
            },

            pushId: function(type, name) {
                if (type === 'ID' || type === 'DATA') {
                    this.pushString(name);
                } else if (type === 'sexpr') {
                    this.pushStackLiteral('true');
                } else {
                    this.pushStackLiteral('null');
                }
            },

            // HELPERS

            compiler: JavaScriptCompiler,

            compileChildren: function(environment, options) {
                var children = environment.children,
                    child, compiler;

                for (var i = 0, l = children.length; i < l; i++) {
                    child = children[i];
                    compiler = new this.compiler();

                    var index = this.matchExistingProgram(child);

                    if (index == null) {
                        this.context.programs.push(''); // Placeholder to prevent name conflicts for nested children
                        index = this.context.programs.length;
                        child.index = index;
                        child.name = 'program' + index;
                        this.context.programs[index] = compiler.compile(child, options, this.context, !this.precompile);
                        this.context.environments[index] = child;

                        this.useDepths = this.useDepths || compiler.useDepths;
                    } else {
                        child.index = index;
                        child.name = 'program' + index;
                    }
                }
            },
            matchExistingProgram: function(child) {
                for (var i = 0, len = this.context.environments.length; i < len; i++) {
                    var environment = this.context.environments[i];
                    if (environment && environment.equals(child)) {
                        return i;
                    }
                }
            },

            programExpression: function(guid) {
                var child = this.environment.children[guid],
                    depths = child.depths.list,
                    useDepths = this.useDepths,
                    depth;

                var programParams = [child.index, 'data'];

                if (useDepths) {
                    programParams.push('depths');
                }

                return 'this.program(' + programParams.join(', ') + ')';
            },

            useRegister: function(name) {
                if (!this.registers[name]) {
                    this.registers[name] = true;
                    this.registers.list.push(name);
                }
            },

            pushStackLiteral: function(item) {
                return this.push(new Literal(item));
            },

            pushSource: function(source) {
                if (this.pendingContent) {
                    this.source.push(this.appendToBuffer(this.quotedString(this.pendingContent)));
                    this.pendingContent = undefined;
                }

                if (source) {
                    this.source.push(source);
                }
            },

            pushStack: function(item) {
                this.flushInline();

                var stack = this.incrStack();
                this.pushSource(stack + " = " + item + ";");
                this.compileStack.push(stack);
                return stack;
            },

            replaceStack: function(callback) {
                var prefix = '',
                    inline = this.isInline(),
                    stack,
                    createdStack,
                    usedLiteral;

                /* istanbul ignore next */
                if (!this.isInline()) {
                    throw new Exception('replaceStack on non-inline');
                }

                // We want to merge the inline statement into the replacement statement via ','
                var top = this.popStack(true);

                if (top instanceof Literal) {
                    // Literals do not need to be inlined
                    prefix = stack = top.value;
                    usedLiteral = true;
                } else {
                    // Get or create the current stack name for use by the inline
                    createdStack = !this.stackSlot;
                    var name = !createdStack ? this.topStackName() : this.incrStack();

                    prefix = '(' + this.push(name) + ' = ' + top + ')';
                    stack = this.topStack();
                }

                var item = callback.call(this, stack);

                if (!usedLiteral) {
                    this.popStack();
                }
                if (createdStack) {
                    this.stackSlot--;
                }
                this.push('(' + prefix + item + ')');
            },

            incrStack: function() {
                this.stackSlot++;
                if (this.stackSlot > this.stackVars.length) {
                    this.stackVars.push("stack" + this.stackSlot);
                }
                return this.topStackName();
            },
            topStackName: function() {
                return "stack" + this.stackSlot;
            },
            flushInline: function() {
                var inlineStack = this.inlineStack;
                if (inlineStack.length) {
                    this.inlineStack = [];
                    for (var i = 0, len = inlineStack.length; i < len; i++) {
                        var entry = inlineStack[i];
                        if (entry instanceof Literal) {
                            this.compileStack.push(entry);
                        } else {
                            this.pushStack(entry);
                        }
                    }
                }
            },
            isInline: function() {
                return this.inlineStack.length;
            },

            popStack: function(wrapped) {
                var inline = this.isInline(),
                    item = (inline ? this.inlineStack : this.compileStack).pop();

                if (!wrapped && (item instanceof Literal)) {
                    return item.value;
                } else {
                    if (!inline) {
                        /* istanbul ignore next */
                        if (!this.stackSlot) {
                            throw new Exception('Invalid stack pop');
                        }
                        this.stackSlot--;
                    }
                    return item;
                }
            },

            topStack: function() {
                var stack = (this.isInline() ? this.inlineStack : this.compileStack),
                    item = stack[stack.length - 1];

                if (item instanceof Literal) {
                    return item.value;
                } else {
                    return item;
                }
            },

            contextName: function(context) {
                if (this.useDepths && context) {
                    return 'depths[' + context + ']';
                } else {
                    return 'depth' + context;
                }
            },

            quotedString: function(str) {
                return '"' + str
                    .replace(/\\/g, '\\\\')
                    .replace(/"/g, '\\"')
                    .replace(/\n/g, '\\n')
                    .replace(/\r/g, '\\r')
                    .replace(/\u2028/g, '\\u2028') // Per Ecma-262 7.3 + 7.8.4
                    .replace(/\u2029/g, '\\u2029') + '"';
            },

            objectLiteral: function(obj) {
                var pairs = [];

                for (var key in obj) {
                    if (obj.hasOwnProperty(key)) {
                        pairs.push(this.quotedString(key) + ':' + obj[key]);
                    }
                }

                return '{' + pairs.join(',') + '}';
            },

            setupHelper: function(paramSize, name, blockHelper) {
                var params = [],
                    paramsInit = this.setupParams(name, paramSize, params, blockHelper);
                var foundHelper = this.nameLookup('helpers', name, 'helper');

                return {
                    params: params,
                    paramsInit: paramsInit,
                    name: foundHelper,
                    callParams: [this.contextName(0)].concat(params).join(", ")
                };
            },

            setupOptions: function(helper, paramSize, params) {
                var options = {},
                    contexts = [],
                    types = [],
                    ids = [],
                    param, inverse, program;

                options.name = this.quotedString(helper);
                options.hash = this.popStack();

                if (this.trackIds) {
                    options.hashIds = this.popStack();
                }
                if (this.stringParams) {
                    options.hashTypes = this.popStack();
                    options.hashContexts = this.popStack();
                }

                inverse = this.popStack();
                program = this.popStack();

                // Avoid setting fn and inverse if neither are set. This allows
                // helpers to do a check for `if (options.fn)`
                if (program || inverse) {
                    if (!program) {
                        program = 'this.noop';
                    }

                    if (!inverse) {
                        inverse = 'this.noop';
                    }

                    options.fn = program;
                    options.inverse = inverse;
                }

                // The parameters go on to the stack in order (making sure that they are evaluated in order)
                // so we need to pop them off the stack in reverse order
                var i = paramSize;
                while (i--) {
                    param = this.popStack();
                    params[i] = param;

                    if (this.trackIds) {
                        ids[i] = this.popStack();
                    }
                    if (this.stringParams) {
                        types[i] = this.popStack();
                        contexts[i] = this.popStack();
                    }
                }

                if (this.trackIds) {
                    options.ids = "[" + ids.join(",") + "]";
                }
                if (this.stringParams) {
                    options.types = "[" + types.join(",") + "]";
                    options.contexts = "[" + contexts.join(",") + "]";
                }

                if (this.options.data) {
                    options.data = "data";
                }

                return options;
            },

            // the params and contexts arguments are passed in arrays
            // to fill in
            setupParams: function(helperName, paramSize, params, useRegister) {
                var options = this.objectLiteral(this.setupOptions(helperName, paramSize, params));

                if (useRegister) {
                    this.useRegister('options');
                    params.push('options');
                    return 'options=' + options;
                } else {
                    params.push(options);
                    return '';
                }
            }
        };

        var reservedWords = (
            "break else new var" +
            " case finally return void" +
            " catch for switch while" +
            " continue function this with" +
            " default if throw" +
            " delete in try" +
            " do instanceof typeof" +
            " abstract enum int short" +
            " boolean export interface static" +
            " byte extends long super" +
            " char final native synchronized" +
            " class float package throws" +
            " const goto private transient" +
            " debugger implements protected volatile" +
            " double import public let yield"
        ).split(" ");

        var compilerWords = JavaScriptCompiler.RESERVED_WORDS = {};

        for (var i = 0, l = reservedWords.length; i < l; i++) {
            compilerWords[reservedWords[i]] = true;
        }

        JavaScriptCompiler.isValidJavaScriptVariableName = function(name) {
            return !JavaScriptCompiler.RESERVED_WORDS[name] && /^[a-zA-Z_$][0-9a-zA-Z_$]*$/.test(name);
        };

        __exports__ = JavaScriptCompiler;
        return __exports__;
    })(__module2__, __module5__);

    // handlebars.js
    var __module0__ = (function(__dependency1__, __dependency2__, __dependency3__, __dependency4__, __dependency5__) {
        "use strict";
        var __exports__;
        /*globals Handlebars: true */
        var Handlebars = __dependency1__;

        // Compiler imports
        var AST = __dependency2__;
        var Parser = __dependency3__.parser;
        var parse = __dependency3__.parse;
        var Compiler = __dependency4__.Compiler;
        var compile = __dependency4__.compile;
        var precompile = __dependency4__.precompile;
        var JavaScriptCompiler = __dependency5__;

        var _create = Handlebars.create;
        var create = function() {
            var hb = _create();

            hb.compile = function(input, options) {
                return compile(input, options, hb);
            };
            hb.precompile = function(input, options) {
                return precompile(input, options, hb);
            };

            hb.AST = AST;
            hb.Compiler = Compiler;
            hb.JavaScriptCompiler = JavaScriptCompiler;
            hb.Parser = Parser;
            hb.parse = parse;

            return hb;
        };

        Handlebars = create();
        Handlebars.create = create;

        Handlebars['default'] = Handlebars;

        __exports__ = Handlebars;
        return __exports__;
    })(__module1__, __module7__, __module8__, __module11__, __module12__);

    return __module0__;
}));

(function(a) {
    function b(a, b, c) {
        switch (arguments.length) {
            case 2:
                return null != a ? a : b;
            case 3:
                return null != a ? a : null != b ? b : c;
            default:
                throw new Error("Implement me")
        }
    }

    function c() {
        return {
            empty: !1,
            unusedTokens: [],
            unusedInput: [],
            overflow: -2,
            charsLeftOver: 0,
            nullInput: !1,
            invalidMonth: null,
            invalidFormat: !1,
            userInvalidated: !1,
            iso: !1
        }
    }

    function d(a) {
        rb.suppressDeprecationWarnings === !1 && "undefined" != typeof console && console.warn && console.warn("Deprecation warning: " + a)
    }

    function e(a, b) {
        var c = !0;
        return l(function() {
            return c && (d(a), c = !1), b.apply(this, arguments)
        }, b)
    }

    function f(a, b) {
        nc[a] || (d(b), nc[a] = !0)
    }

    function g(a, b) {
        return function(c) {
            return o(a.call(this, c), b)
        }
    }

    function h(a, b) {
        return function(c) {
            return this.localeData().ordinal(a.call(this, c), b)
        }
    }

    function i() {}

    function j(a, b) {
        b !== !1 && E(a), m(this, a), this._d = new Date(+a._d)
    }

    function k(a) {
        var b = x(a),
            c = b.year || 0,
            d = b.quarter || 0,
            e = b.month || 0,
            f = b.week || 0,
            g = b.day || 0,
            h = b.hour || 0,
            i = b.minute || 0,
            j = b.second || 0,
            k = b.millisecond || 0;
        this._milliseconds = +k + 1e3 * j + 6e4 * i + 36e5 * h, this._days = +g + 7 * f, this._months = +e + 3 * d + 12 * c, this._data = {}, this._locale = rb.localeData(), this._bubble()
    }

    function l(a, b) {
        for (var c in b) b.hasOwnProperty(c) && (a[c] = b[c]);
        return b.hasOwnProperty("toString") && (a.toString = b.toString), b.hasOwnProperty("valueOf") && (a.valueOf = b.valueOf), a
    }

    function m(a, b) {
        var c, d, e;
        if ("undefined" != typeof b._isAMomentObject && (a._isAMomentObject = b._isAMomentObject), "undefined" != typeof b._i && (a._i = b._i), "undefined" != typeof b._f && (a._f = b._f), "undefined" != typeof b._l && (a._l = b._l), "undefined" != typeof b._strict && (a._strict = b._strict), "undefined" != typeof b._tzm && (a._tzm = b._tzm), "undefined" != typeof b._isUTC && (a._isUTC = b._isUTC), "undefined" != typeof b._offset && (a._offset = b._offset), "undefined" != typeof b._pf && (a._pf = b._pf), "undefined" != typeof b._locale && (a._locale = b._locale), Fb.length > 0)
            for (c in Fb) d = Fb[c], e = b[d], "undefined" != typeof e && (a[d] = e);
        return a
    }

    function n(a) {
        return 0 > a ? Math.ceil(a) : Math.floor(a)
    }

    function o(a, b, c) {
        for (var d = "" + Math.abs(a), e = a >= 0; d.length < b;) d = "0" + d;
        return (e ? c ? "+" : "" : "-") + d
    }

    function p(a, b) {
        var c = {
            milliseconds: 0,
            months: 0
        };
        return c.months = b.month() - a.month() + 12 * (b.year() - a.year()), a.clone().add(c.months, "M").isAfter(b) && --c.months, c.milliseconds = +b - +a.clone().add(c.months, "M"), c
    }

    function q(a, b) {
        var c;
        return b = J(b, a), a.isBefore(b) ? c = p(a, b) : (c = p(b, a), c.milliseconds = -c.milliseconds, c.months = -c.months), c
    }

    function r(a, b) {
        return function(c, d) {
            var e, g;
            return null === d || isNaN(+d) || (f(b, "moment()." + b + "(period, number) is deprecated. Please use moment()." + b + "(number, period)."), g = c, c = d, d = g), c = "string" == typeof c ? +c : c, e = rb.duration(c, d), s(this, e, a), this
        }
    }

    function s(a, b, c, d) {
        var e = b._milliseconds,
            f = b._days,
            g = b._months;
        d = null == d ? !0 : d, e && a._d.setTime(+a._d + e * c), f && lb(a, "Date", kb(a, "Date") + f * c), g && jb(a, kb(a, "Month") + g * c), d && rb.updateOffset(a, f || g)
    }

    function t(a) {
        return "[object Array]" === Object.prototype.toString.call(a)
    }

    function u(a) {
        return "[object Date]" === Object.prototype.toString.call(a) || a instanceof Date
    }

    function v(a, b, c) {
        var d, e = Math.min(a.length, b.length),
            f = Math.abs(a.length - b.length),
            g = 0;
        for (d = 0; e > d; d++)(c && a[d] !== b[d] || !c && z(a[d]) !== z(b[d])) && g++;
        return g + f
    }

    function w(a) {
        if (a) {
            var b = a.toLowerCase().replace(/(.)s$/, "$1");
            a = gc[a] || hc[b] || b
        }
        return a
    }

    function x(a) {
        var b, c, d = {};
        for (c in a) a.hasOwnProperty(c) && (b = w(c), b && (d[b] = a[c]));
        return d
    }

    function y(b) {
        var c, d;
        if (0 === b.indexOf("week")) c = 7, d = "day";
        else {
            if (0 !== b.indexOf("month")) return;
            c = 12, d = "month"
        }
        rb[b] = function(e, f) {
            var g, h, i = rb._locale[b],
                j = [];
            if ("number" == typeof e && (f = e, e = a), h = function(a) {
                    var b = rb().utc().set(d, a);
                    return i.call(rb._locale, b, e || "")
                }, null != f) return h(f);
            for (g = 0; c > g; g++) j.push(h(g));
            return j
        }
    }

    function z(a) {
        var b = +a,
            c = 0;
        return 0 !== b && isFinite(b) && (c = b >= 0 ? Math.floor(b) : Math.ceil(b)), c
    }

    function A(a, b) {
        return new Date(Date.UTC(a, b + 1, 0)).getUTCDate()
    }

    function B(a, b, c) {
        return fb(rb([a, 11, 31 + b - c]), b, c).week
    }

    function C(a) {
        return D(a) ? 366 : 365
    }

    function D(a) {
        return a % 4 === 0 && a % 100 !== 0 || a % 400 === 0
    }

    function E(a) {
        var b;
        a._a && -2 === a._pf.overflow && (b = a._a[yb] < 0 || a._a[yb] > 11 ? yb : a._a[zb] < 1 || a._a[zb] > A(a._a[xb], a._a[yb]) ? zb : a._a[Ab] < 0 || a._a[Ab] > 23 ? Ab : a._a[Bb] < 0 || a._a[Bb] > 59 ? Bb : a._a[Cb] < 0 || a._a[Cb] > 59 ? Cb : a._a[Db] < 0 || a._a[Db] > 999 ? Db : -1, a._pf._overflowDayOfYear && (xb > b || b > zb) && (b = zb), a._pf.overflow = b)
    }

    function F(a) {
        return null == a._isValid && (a._isValid = !isNaN(a._d.getTime()) && a._pf.overflow < 0 && !a._pf.empty && !a._pf.invalidMonth && !a._pf.nullInput && !a._pf.invalidFormat && !a._pf.userInvalidated, a._strict && (a._isValid = a._isValid && 0 === a._pf.charsLeftOver && 0 === a._pf.unusedTokens.length)), a._isValid
    }

    function G(a) {
        return a ? a.toLowerCase().replace("_", "-") : a
    }

    function H(a) {
        for (var b, c, d, e, f = 0; f < a.length;) {
            for (e = G(a[f]).split("-"), b = e.length, c = G(a[f + 1]), c = c ? c.split("-") : null; b > 0;) {
                if (d = I(e.slice(0, b).join("-"))) return d;
                if (c && c.length >= b && v(e, c, !0) >= b - 1) break;
                b--
            }
            f++
        }
        return null
    }

    function I(a) {
        var b = null;
        if (!Eb[a] && Gb) try {
            b = rb.locale(), require("./locale/" + a), rb.locale(b)
        } catch (c) {}
        return Eb[a]
    }

    function J(a, b) {
        return b._isUTC ? rb(a).zone(b._offset || 0) : rb(a).local()
    }

    function K(a) {
        return a.match(/\[[\s\S]/) ? a.replace(/^\[|\]$/g, "") : a.replace(/\\/g, "")
    }

    function L(a) {
        var b, c, d = a.match(Kb);
        for (b = 0, c = d.length; c > b; b++) d[b] = mc[d[b]] ? mc[d[b]] : K(d[b]);
        return function(e) {
            var f = "";
            for (b = 0; c > b; b++) f += d[b] instanceof Function ? d[b].call(e, a) : d[b];
            return f
        }
    }

    function M(a, b) {
        return a.isValid() ? (b = N(b, a.localeData()), ic[b] || (ic[b] = L(b)), ic[b](a)) : a.localeData().invalidDate()
    }

    function N(a, b) {
        function c(a) {
            return b.longDateFormat(a) || a
        }
        var d = 5;
        for (Lb.lastIndex = 0; d >= 0 && Lb.test(a);) a = a.replace(Lb, c), Lb.lastIndex = 0, d -= 1;
        return a
    }

    function O(a, b) {
        var c, d = b._strict;
        switch (a) {
            case "Q":
                return Wb;
            case "DDDD":
                return Yb;
            case "YYYY":
            case "GGGG":
            case "gggg":
                return d ? Zb : Ob;
            case "Y":
            case "G":
            case "g":
                return _b;
            case "YYYYYY":
            case "YYYYY":
            case "GGGGG":
            case "ggggg":
                return d ? $b : Pb;
            case "S":
                if (d) return Wb;
            case "SS":
                if (d) return Xb;
            case "SSS":
                if (d) return Yb;
            case "DDD":
                return Nb;
            case "MMM":
            case "MMMM":
            case "dd":
            case "ddd":
            case "dddd":
                return Rb;
            case "a":
            case "A":
                return b._locale._meridiemParse;
            case "X":
                return Ub;
            case "Z":
            case "ZZ":
                return Sb;
            case "T":
                return Tb;
            case "SSSS":
                return Qb;
            case "MM":
            case "DD":
            case "YY":
            case "GG":
            case "gg":
            case "HH":
            case "hh":
            case "mm":
            case "ss":
            case "ww":
            case "WW":
                return d ? Xb : Mb;
            case "M":
            case "D":
            case "d":
            case "H":
            case "h":
            case "m":
            case "s":
            case "w":
            case "W":
            case "e":
            case "E":
                return Mb;
            case "Do":
                return Vb;
            default:
                return c = new RegExp(X(W(a.replace("\\", "")), "i"))
        }
    }

    function P(a) {
        a = a || "";
        var b = a.match(Sb) || [],
            c = b[b.length - 1] || [],
            d = (c + "").match(ec) || ["-", 0, 0],
            e = +(60 * d[1]) + z(d[2]);
        return "+" === d[0] ? -e : e
    }

    function Q(a, b, c) {
        var d, e = c._a;
        switch (a) {
            case "Q":
                null != b && (e[yb] = 3 * (z(b) - 1));
                break;
            case "M":
            case "MM":
                null != b && (e[yb] = z(b) - 1);
                break;
            case "MMM":
            case "MMMM":
                d = c._locale.monthsParse(b), null != d ? e[yb] = d : c._pf.invalidMonth = b;
                break;
            case "D":
            case "DD":
                null != b && (e[zb] = z(b));
                break;
            case "Do":
                null != b && (e[zb] = z(parseInt(b, 10)));
                break;
            case "DDD":
            case "DDDD":
                null != b && (c._dayOfYear = z(b));
                break;
            case "YY":
                e[xb] = rb.parseTwoDigitYear(b);
                break;
            case "YYYY":
            case "YYYYY":
            case "YYYYYY":
                e[xb] = z(b);
                break;
            case "a":
            case "A":
                c._isPm = c._locale.isPM(b);
                break;
            case "H":
            case "HH":
            case "h":
            case "hh":
                e[Ab] = z(b);
                break;
            case "m":
            case "mm":
                e[Bb] = z(b);
                break;
            case "s":
            case "ss":
                e[Cb] = z(b);
                break;
            case "S":
            case "SS":
            case "SSS":
            case "SSSS":
                e[Db] = z(1e3 * ("0." + b));
                break;
            case "X":
                c._d = new Date(1e3 * parseFloat(b));
                break;
            case "Z":
            case "ZZ":
                c._useUTC = !0, c._tzm = P(b);
                break;
            case "dd":
            case "ddd":
            case "dddd":
                d = c._locale.weekdaysParse(b), null != d ? (c._w = c._w || {}, c._w.d = d) : c._pf.invalidWeekday = b;
                break;
            case "w":
            case "ww":
            case "W":
            case "WW":
            case "d":
            case "e":
            case "E":
                a = a.substr(0, 1);
            case "gggg":
            case "GGGG":
            case "GGGGG":
                a = a.substr(0, 2), b && (c._w = c._w || {}, c._w[a] = z(b));
                break;
            case "gg":
            case "GG":
                c._w = c._w || {}, c._w[a] = rb.parseTwoDigitYear(b)
        }
    }

    function R(a) {
        var c, d, e, f, g, h, i;
        c = a._w, null != c.GG || null != c.W || null != c.E ? (g = 1, h = 4, d = b(c.GG, a._a[xb], fb(rb(), 1, 4).year), e = b(c.W, 1), f = b(c.E, 1)) : (g = a._locale._week.dow, h = a._locale._week.doy, d = b(c.gg, a._a[xb], fb(rb(), g, h).year), e = b(c.w, 1), null != c.d ? (f = c.d, g > f && ++e) : f = null != c.e ? c.e + g : g), i = gb(d, e, f, h, g), a._a[xb] = i.year, a._dayOfYear = i.dayOfYear
    }

    function S(a) {
        var c, d, e, f, g = [];
        if (!a._d) {
            for (e = U(a), a._w && null == a._a[zb] && null == a._a[yb] && R(a), a._dayOfYear && (f = b(a._a[xb], e[xb]), a._dayOfYear > C(f) && (a._pf._overflowDayOfYear = !0), d = bb(f, 0, a._dayOfYear), a._a[yb] = d.getUTCMonth(), a._a[zb] = d.getUTCDate()), c = 0; 3 > c && null == a._a[c]; ++c) a._a[c] = g[c] = e[c];
            for (; 7 > c; c++) a._a[c] = g[c] = null == a._a[c] ? 2 === c ? 1 : 0 : a._a[c];
            a._d = (a._useUTC ? bb : ab).apply(null, g), null != a._tzm && a._d.setUTCMinutes(a._d.getUTCMinutes() + a._tzm)
        }
    }

    function T(a) {
        var b;
        a._d || (b = x(a._i), a._a = [b.year, b.month, b.day, b.hour, b.minute, b.second, b.millisecond], S(a))
    }

    function U(a) {
        var b = new Date;
        return a._useUTC ? [b.getUTCFullYear(), b.getUTCMonth(), b.getUTCDate()] : [b.getFullYear(), b.getMonth(), b.getDate()]
    }

    function V(a) {
        if (a._f === rb.ISO_8601) return void Z(a);
        a._a = [], a._pf.empty = !0;
        var b, c, d, e, f, g = "" + a._i,
            h = g.length,
            i = 0;
        for (d = N(a._f, a._locale).match(Kb) || [], b = 0; b < d.length; b++) e = d[b], c = (g.match(O(e, a)) || [])[0], c && (f = g.substr(0, g.indexOf(c)), f.length > 0 && a._pf.unusedInput.push(f), g = g.slice(g.indexOf(c) + c.length), i += c.length), mc[e] ? (c ? a._pf.empty = !1 : a._pf.unusedTokens.push(e), Q(e, c, a)) : a._strict && !c && a._pf.unusedTokens.push(e);
        a._pf.charsLeftOver = h - i, g.length > 0 && a._pf.unusedInput.push(g), a._isPm && a._a[Ab] < 12 && (a._a[Ab] += 12), a._isPm === !1 && 12 === a._a[Ab] && (a._a[Ab] = 0), S(a), E(a)
    }

    function W(a) {
        return a.replace(/\\(\[)|\\(\])|\[([^\]\[]*)\]|\\(.)/g, function(a, b, c, d, e) {
            return b || c || d || e
        })
    }

    function X(a) {
        return a.replace(/[-\/\\^$*+?.()|[\]{}]/g, "\\$&")
    }

    function Y(a) {
        var b, d, e, f, g;
        if (0 === a._f.length) return a._pf.invalidFormat = !0, void(a._d = new Date(0 / 0));
        for (f = 0; f < a._f.length; f++) g = 0, b = m({}, a), b._pf = c(), b._f = a._f[f], V(b), F(b) && (g += b._pf.charsLeftOver, g += 10 * b._pf.unusedTokens.length, b._pf.score = g, (null == e || e > g) && (e = g, d = b));
        l(a, d || b)
    }

    function Z(a) {
        var b, c, d = a._i,
            e = ac.exec(d);
        if (e) {
            for (a._pf.iso = !0, b = 0, c = cc.length; c > b; b++)
                if (cc[b][1].exec(d)) {
                    a._f = cc[b][0] + (e[6] || " ");
                    break
                }
            for (b = 0, c = dc.length; c > b; b++)
                if (dc[b][1].exec(d)) {
                    a._f += dc[b][0];
                    break
                }
            d.match(Sb) && (a._f += "Z"), V(a)
        } else a._isValid = !1
    }

    function $(a) {
        Z(a), a._isValid === !1 && (delete a._isValid, rb.createFromInputFallback(a))
    }

    function _(b) {
        var c, d = b._i;
        d === a ? b._d = new Date : u(d) ? b._d = new Date(+d) : null !== (c = Hb.exec(d)) ? b._d = new Date(+c[1]) : "string" == typeof d ? $(b) : t(d) ? (b._a = d.slice(0), S(b)) : "object" == typeof d ? T(b) : "number" == typeof d ? b._d = new Date(d) : rb.createFromInputFallback(b)
    }

    function ab(a, b, c, d, e, f, g) {
        var h = new Date(a, b, c, d, e, f, g);
        return 1970 > a && h.setFullYear(a), h
    }

    function bb(a) {
        var b = new Date(Date.UTC.apply(null, arguments));
        return 1970 > a && b.setUTCFullYear(a), b
    }

    function cb(a, b) {
        if ("string" == typeof a)
            if (isNaN(a)) {
                if (a = b.weekdaysParse(a), "number" != typeof a) return null
            } else a = parseInt(a, 10);
        return a
    }

    function db(a, b, c, d, e) {
        return e.relativeTime(b || 1, !!c, a, d)
    }

    function eb(a, b, c) {
        var d = rb.duration(a).abs(),
            e = wb(d.as("s")),
            f = wb(d.as("m")),
            g = wb(d.as("h")),
            h = wb(d.as("d")),
            i = wb(d.as("M")),
            j = wb(d.as("y")),
            k = e < jc.s && ["s", e] || 1 === f && ["m"] || f < jc.m && ["mm", f] || 1 === g && ["h"] || g < jc.h && ["hh", g] || 1 === h && ["d"] || h < jc.d && ["dd", h] || 1 === i && ["M"] || i < jc.M && ["MM", i] || 1 === j && ["y"] || ["yy", j];
        return k[2] = b, k[3] = +a > 0, k[4] = c, db.apply({}, k)
    }

    function fb(a, b, c) {
        var d, e = c - b,
            f = c - a.day();
        return f > e && (f -= 7), e - 7 > f && (f += 7), d = rb(a).add(f, "d"), {
            week: Math.ceil(d.dayOfYear() / 7),
            year: d.year()
        }
    }

    function gb(a, b, c, d, e) {
        var f, g, h = bb(a, 0, 1).getUTCDay();
        return h = 0 === h ? 7 : h, c = null != c ? c : e, f = e - h + (h > d ? 7 : 0) - (e > h ? 7 : 0), g = 7 * (b - 1) + (c - e) + f + 1, {
            year: g > 0 ? a : a - 1,
            dayOfYear: g > 0 ? g : C(a - 1) + g
        }
    }

    function hb(b) {
        var c = b._i,
            d = b._f;
        return b._locale = b._locale || rb.localeData(b._l), null === c || d === a && "" === c ? rb.invalid({
            nullInput: !0
        }) : ("string" == typeof c && (b._i = c = b._locale.preparse(c)), rb.isMoment(c) ? new j(c, !0) : (d ? t(d) ? Y(b) : V(b) : _(b), new j(b)))
    }

    function ib(a, b) {
        var c, d;
        if (1 === b.length && t(b[0]) && (b = b[0]), !b.length) return rb();
        for (c = b[0], d = 1; d < b.length; ++d) b[d][a](c) && (c = b[d]);
        return c
    }

    function jb(a, b) {
        var c;
        return "string" == typeof b && (b = a.localeData().monthsParse(b), "number" != typeof b) ? a : (c = Math.min(a.date(), A(a.year(), b)), a._d["set" + (a._isUTC ? "UTC" : "") + "Month"](b, c), a)
    }

    function kb(a, b) {
        return a._d["get" + (a._isUTC ? "UTC" : "") + b]()
    }

    function lb(a, b, c) {
        return "Month" === b ? jb(a, c) : a._d["set" + (a._isUTC ? "UTC" : "") + b](c)
    }

    function mb(a, b) {
        return function(c) {
            return null != c ? (lb(this, a, c), rb.updateOffset(this, b), this) : kb(this, a)
        }
    }

    function nb(a) {
        return 400 * a / 146097
    }

    function ob(a) {
        return 146097 * a / 400
    }

    function pb(a) {
        rb.duration.fn[a] = function() {
            return this._data[a]
        }
    }

    function qb(a) {
        "undefined" == typeof ender && (sb = vb.moment, vb.moment = a ? e("Accessing Moment through the global scope is deprecated, and will be removed in an upcoming release.", rb) : rb)
    }
    for (var rb, sb, tb, ub = "2.8.1", vb = "undefined" != typeof global ? global : this, wb = Math.round, xb = 0, yb = 1, zb = 2, Ab = 3, Bb = 4, Cb = 5, Db = 6, Eb = {}, Fb = [], Gb = "undefined" != typeof module && module.exports, Hb = /^\/?Date\((\-?\d+)/i, Ib = /(\-)?(?:(\d*)\.)?(\d+)\:(\d+)(?:\:(\d+)\.?(\d{3})?)?/, Jb = /^(-)?P(?:(?:([0-9,.]*)Y)?(?:([0-9,.]*)M)?(?:([0-9,.]*)D)?(?:T(?:([0-9,.]*)H)?(?:([0-9,.]*)M)?(?:([0-9,.]*)S)?)?|([0-9,.]*)W)$/, Kb = /(\[[^\[]*\])|(\\)?(Mo|MM?M?M?|Do|DDDo|DD?D?D?|ddd?d?|do?|w[o|w]?|W[o|W]?|Q|YYYYYY|YYYYY|YYYY|YY|gg(ggg?)?|GG(GGG?)?|e|E|a|A|hh?|HH?|mm?|ss?|S{1,4}|X|zz?|ZZ?|.)/g, Lb = /(\[[^\[]*\])|(\\)?(LT|LL?L?L?|l{1,4})/g, Mb = /\d\d?/, Nb = /\d{1,3}/, Ob = /\d{1,4}/, Pb = /[+\-]?\d{1,6}/, Qb = /\d+/, Rb = /[0-9]*['a-z\u00A0-\u05FF\u0700-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+|[\u0600-\u06FF\/]+(\s*?[\u0600-\u06FF]+){1,2}/i, Sb = /Z|[\+\-]\d\d:?\d\d/gi, Tb = /T/i, Ub = /[\+\-]?\d+(\.\d{1,3})?/, Vb = /\d{1,2}/, Wb = /\d/, Xb = /\d\d/, Yb = /\d{3}/, Zb = /\d{4}/, $b = /[+-]?\d{6}/, _b = /[+-]?\d+/, ac = /^\s*(?:[+-]\d{6}|\d{4})-(?:(\d\d-\d\d)|(W\d\d$)|(W\d\d-\d)|(\d\d\d))((T| )(\d\d(:\d\d(:\d\d(\.\d+)?)?)?)?([\+\-]\d\d(?::?\d\d)?|\s*Z)?)?$/, bc = "YYYY-MM-DDTHH:mm:ssZ", cc = [
            ["YYYYYY-MM-DD", /[+-]\d{6}-\d{2}-\d{2}/],
            ["YYYY-MM-DD", /\d{4}-\d{2}-\d{2}/],
            ["GGGG-[W]WW-E", /\d{4}-W\d{2}-\d/],
            ["GGGG-[W]WW", /\d{4}-W\d{2}/],
            ["YYYY-DDD", /\d{4}-\d{3}/]
        ], dc = [
            ["HH:mm:ss.SSSS", /(T| )\d\d:\d\d:\d\d\.\d+/],
            ["HH:mm:ss", /(T| )\d\d:\d\d:\d\d/],
            ["HH:mm", /(T| )\d\d:\d\d/],
            ["HH", /(T| )\d\d/]
        ], ec = /([\+\-]|\d\d)/gi, fc = ("Date|Hours|Minutes|Seconds|Milliseconds".split("|"), {
            Milliseconds: 1,
            Seconds: 1e3,
            Minutes: 6e4,
            Hours: 36e5,
            Days: 864e5,
            Months: 2592e6,
            Years: 31536e6
        }), gc = {
            ms: "millisecond",
            s: "second",
            m: "minute",
            h: "hour",
            d: "day",
            D: "date",
            w: "week",
            W: "isoWeek",
            M: "month",
            Q: "quarter",
            y: "year",
            DDD: "dayOfYear",
            e: "weekday",
            E: "isoWeekday",
            gg: "weekYear",
            GG: "isoWeekYear"
        }, hc = {
            dayofyear: "dayOfYear",
            isoweekday: "isoWeekday",
            isoweek: "isoWeek",
            weekyear: "weekYear",
            isoweekyear: "isoWeekYear"
        }, ic = {}, jc = {
            s: 45,
            m: 45,
            h: 22,
            d: 26,
            M: 11
        }, kc = "DDD w W M D d".split(" "), lc = "M D H h m s w W".split(" "), mc = {
            M: function() {
                return this.month() + 1
            },
            MMM: function(a) {
                return this.localeData().monthsShort(this, a)
            },
            MMMM: function(a) {
                return this.localeData().months(this, a)
            },
            D: function() {
                return this.date()
            },
            DDD: function() {
                return this.dayOfYear()
            },
            d: function() {
                return this.day()
            },
            dd: function(a) {
                return this.localeData().weekdaysMin(this, a)
            },
            ddd: function(a) {
                return this.localeData().weekdaysShort(this, a)
            },
            dddd: function(a) {
                return this.localeData().weekdays(this, a)
            },
            w: function() {
                return this.week()
            },
            W: function() {
                return this.isoWeek()
            },
            YY: function() {
                return o(this.year() % 100, 2)
            },
            YYYY: function() {
                return o(this.year(), 4)
            },
            YYYYY: function() {
                return o(this.year(), 5)
            },
            YYYYYY: function() {
                var a = this.year(),
                    b = a >= 0 ? "+" : "-";
                return b + o(Math.abs(a), 6)
            },
            gg: function() {
                return o(this.weekYear() % 100, 2)
            },
            gggg: function() {
                return o(this.weekYear(), 4)
            },
            ggggg: function() {
                return o(this.weekYear(), 5)
            },
            GG: function() {
                return o(this.isoWeekYear() % 100, 2)
            },
            GGGG: function() {
                return o(this.isoWeekYear(), 4)
            },
            GGGGG: function() {
                return o(this.isoWeekYear(), 5)
            },
            e: function() {
                return this.weekday()
            },
            E: function() {
                return this.isoWeekday()
            },
            a: function() {
                return this.localeData().meridiem(this.hours(), this.minutes(), !0)
            },
            A: function() {
                return this.localeData().meridiem(this.hours(), this.minutes(), !1)
            },
            H: function() {
                return this.hours()
            },
            h: function() {
                return this.hours() % 12 || 12
            },
            m: function() {
                return this.minutes()
            },
            s: function() {
                return this.seconds()
            },
            S: function() {
                return z(this.milliseconds() / 100)
            },
            SS: function() {
                return o(z(this.milliseconds() / 10), 2)
            },
            SSS: function() {
                return o(this.milliseconds(), 3)
            },
            SSSS: function() {
                return o(this.milliseconds(), 3)
            },
            Z: function() {
                var a = -this.zone(),
                    b = "+";
                return 0 > a && (a = -a, b = "-"), b + o(z(a / 60), 2) + ":" + o(z(a) % 60, 2)
            },
            ZZ: function() {
                var a = -this.zone(),
                    b = "+";
                return 0 > a && (a = -a, b = "-"), b + o(z(a / 60), 2) + o(z(a) % 60, 2)
            },
            z: function() {
                return this.zoneAbbr()
            },
            zz: function() {
                return this.zoneName()
            },
            X: function() {
                return this.unix()
            },
            Q: function() {
                return this.quarter()
            }
        }, nc = {}, oc = ["months", "monthsShort", "weekdays", "weekdaysShort", "weekdaysMin"]; kc.length;) tb = kc.pop(), mc[tb + "o"] = h(mc[tb], tb);
    for (; lc.length;) tb = lc.pop(), mc[tb + tb] = g(mc[tb], 2);
    mc.DDDD = g(mc.DDD, 3), l(i.prototype, {
        set: function(a) {
            var b, c;
            for (c in a) b = a[c], "function" == typeof b ? this[c] = b : this["_" + c] = b
        },
        _months: "January_February_March_April_May_June_July_August_September_October_November_December".split("_"),
        months: function(a) {
            return this._months[a.month()]
        },
        _monthsShort: "Jan_Feb_Mar_Apr_May_Jun_Jul_Aug_Sep_Oct_Nov_Dec".split("_"),
        monthsShort: function(a) {
            return this._monthsShort[a.month()]
        },
        monthsParse: function(a) {
            var b, c, d;
            for (this._monthsParse || (this._monthsParse = []), b = 0; 12 > b; b++)
                if (this._monthsParse[b] || (c = rb.utc([2e3, b]), d = "^" + this.months(c, "") + "|^" + this.monthsShort(c, ""), this._monthsParse[b] = new RegExp(d.replace(".", ""), "i")), this._monthsParse[b].test(a)) return b
        },
        _weekdays: "Sunday_Monday_Tuesday_Wednesday_Thursday_Friday_Saturday".split("_"),
        weekdays: function(a) {
            return this._weekdays[a.day()]
        },
        _weekdaysShort: "Sun_Mon_Tue_Wed_Thu_Fri_Sat".split("_"),
        weekdaysShort: function(a) {
            return this._weekdaysShort[a.day()]
        },
        _weekdaysMin: "Su_Mo_Tu_We_Th_Fr_Sa".split("_"),
        weekdaysMin: function(a) {
            return this._weekdaysMin[a.day()]
        },
        weekdaysParse: function(a) {
            var b, c, d;
            for (this._weekdaysParse || (this._weekdaysParse = []), b = 0; 7 > b; b++)
                if (this._weekdaysParse[b] || (c = rb([2e3, 1]).day(b), d = "^" + this.weekdays(c, "") + "|^" + this.weekdaysShort(c, "") + "|^" + this.weekdaysMin(c, ""), this._weekdaysParse[b] = new RegExp(d.replace(".", ""), "i")), this._weekdaysParse[b].test(a)) return b
        },
        _longDateFormat: {
            LT: "h:mm A",
            L: "MM/DD/YYYY",
            LL: "MMMM D, YYYY",
            LLL: "MMMM D, YYYY LT",
            LLLL: "dddd, MMMM D, YYYY LT"
        },
        longDateFormat: function(a) {
            var b = this._longDateFormat[a];
            return !b && this._longDateFormat[a.toUpperCase()] && (b = this._longDateFormat[a.toUpperCase()].replace(/MMMM|MM|DD|dddd/g, function(a) {
                return a.slice(1)
            }), this._longDateFormat[a] = b), b
        },
        isPM: function(a) {
            return "p" === (a + "").toLowerCase().charAt(0)
        },
        _meridiemParse: /[ap]\.?m?\.?/i,
        meridiem: function(a, b, c) {
            return a > 11 ? c ? "pm" : "PM" : c ? "am" : "AM"
        },
        _calendar: {
            sameDay: "[Today at] LT",
            nextDay: "[Tomorrow at] LT",
            nextWeek: "dddd [at] LT",
            lastDay: "[Yesterday at] LT",
            lastWeek: "[Last] dddd [at] LT",
            sameElse: "L"
        },
        calendar: function(a, b) {
            var c = this._calendar[a];
            return "function" == typeof c ? c.apply(b) : c
        },
        _relativeTime: {
            future: "in %s",
            past: "%s ago",
            s: "a few seconds",
            m: "a minute",
            mm: "%d minutes",
            h: "an hour",
            hh: "%d hours",
            d: "a day",
            dd: "%d days",
            M: "a month",
            MM: "%d months",
            y: "a year",
            yy: "%d years"
        },
        relativeTime: function(a, b, c, d) {
            var e = this._relativeTime[c];
            return "function" == typeof e ? e(a, b, c, d) : e.replace(/%d/i, a)
        },
        pastFuture: function(a, b) {
            var c = this._relativeTime[a > 0 ? "future" : "past"];
            return "function" == typeof c ? c(b) : c.replace(/%s/i, b)
        },
        ordinal: function(a) {
            return this._ordinal.replace("%d", a)
        },
        _ordinal: "%d",
        preparse: function(a) {
            return a
        },
        postformat: function(a) {
            return a
        },
        week: function(a) {
            return fb(a, this._week.dow, this._week.doy).week
        },
        _week: {
            dow: 0,
            doy: 6
        },
        _invalidDate: "Invalid date",
        invalidDate: function() {
            return this._invalidDate
        }
    }), rb = function(b, d, e, f) {
        var g;
        return "boolean" == typeof e && (f = e, e = a), g = {}, g._isAMomentObject = !0, g._i = b, g._f = d, g._l = e, g._strict = f, g._isUTC = !1, g._pf = c(), hb(g)
    }, rb.suppressDeprecationWarnings = !1, rb.createFromInputFallback = e("moment construction falls back to js Date. This is discouraged and will be removed in upcoming major release. Please refer to https://github.com/moment/moment/issues/1407 for more info.", function(a) {
        a._d = new Date(a._i)
    }), rb.min = function() {
        var a = [].slice.call(arguments, 0);
        return ib("isBefore", a)
    }, rb.max = function() {
        var a = [].slice.call(arguments, 0);
        return ib("isAfter", a)
    }, rb.utc = function(b, d, e, f) {
        var g;
        return "boolean" == typeof e && (f = e, e = a), g = {}, g._isAMomentObject = !0, g._useUTC = !0, g._isUTC = !0, g._l = e, g._i = b, g._f = d, g._strict = f, g._pf = c(), hb(g).utc()
    }, rb.unix = function(a) {
        return rb(1e3 * a)
    }, rb.duration = function(a, b) {
        var c, d, e, f, g = a,
            h = null;
        return rb.isDuration(a) ? g = {
            ms: a._milliseconds,
            d: a._days,
            M: a._months
        } : "number" == typeof a ? (g = {}, b ? g[b] = a : g.milliseconds = a) : (h = Ib.exec(a)) ? (c = "-" === h[1] ? -1 : 1, g = {
            y: 0,
            d: z(h[zb]) * c,
            h: z(h[Ab]) * c,
            m: z(h[Bb]) * c,
            s: z(h[Cb]) * c,
            ms: z(h[Db]) * c
        }) : (h = Jb.exec(a)) ? (c = "-" === h[1] ? -1 : 1, e = function(a) {
            var b = a && parseFloat(a.replace(",", "."));
            return (isNaN(b) ? 0 : b) * c
        }, g = {
            y: e(h[2]),
            M: e(h[3]),
            d: e(h[4]),
            h: e(h[5]),
            m: e(h[6]),
            s: e(h[7]),
            w: e(h[8])
        }) : "object" == typeof g && ("from" in g || "to" in g) && (f = q(rb(g.from), rb(g.to)), g = {}, g.ms = f.milliseconds, g.M = f.months), d = new k(g), rb.isDuration(a) && a.hasOwnProperty("_locale") && (d._locale = a._locale), d
    }, rb.version = ub, rb.defaultFormat = bc, rb.ISO_8601 = function() {}, rb.momentProperties = Fb, rb.updateOffset = function() {}, rb.relativeTimeThreshold = function(b, c) {
        return jc[b] === a ? !1 : c === a ? jc[b] : (jc[b] = c, !0)
    }, rb.lang = e("moment.lang is deprecated. Use moment.locale instead.", function(a, b) {
        return rb.locale(a, b)
    }), rb.locale = function(a, b) {
        var c;
        return a && (c = "undefined" != typeof b ? rb.defineLocale(a, b) : rb.localeData(a), c && (rb.duration._locale = rb._locale = c)), rb._locale._abbr
    }, rb.defineLocale = function(a, b) {
        return null !== b ? (b.abbr = a, Eb[a] || (Eb[a] = new i), Eb[a].set(b), rb.locale(a), Eb[a]) : (delete Eb[a], null)
    }, rb.langData = e("moment.langData is deprecated. Use moment.localeData instead.", function(a) {
        return rb.localeData(a)
    }), rb.localeData = function(a) {
        var b;
        if (a && a._locale && a._locale._abbr && (a = a._locale._abbr), !a) return rb._locale;
        if (!t(a)) {
            if (b = I(a)) return b;
            a = [a]
        }
        return H(a)
    }, rb.isMoment = function(a) {
        return a instanceof j || null != a && a.hasOwnProperty("_isAMomentObject")
    }, rb.isDuration = function(a) {
        return a instanceof k
    };
    for (tb = oc.length - 1; tb >= 0; --tb) y(oc[tb]);
    rb.normalizeUnits = function(a) {
        return w(a)
    }, rb.invalid = function(a) {
        var b = rb.utc(0 / 0);
        return null != a ? l(b._pf, a) : b._pf.userInvalidated = !0, b
    }, rb.parseZone = function() {
        return rb.apply(null, arguments).parseZone()
    }, rb.parseTwoDigitYear = function(a) {
        return z(a) + (z(a) > 68 ? 1900 : 2e3)
    }, l(rb.fn = j.prototype, {
        clone: function() {
            return rb(this)
        },
        valueOf: function() {
            return +this._d + 6e4 * (this._offset || 0)
        },
        unix: function() {
            return Math.floor(+this / 1e3)
        },
        toString: function() {
            return this.clone().locale("en").format("ddd MMM DD YYYY HH:mm:ss [GMT]ZZ")
        },
        toDate: function() {
            return this._offset ? new Date(+this) : this._d
        },
        toISOString: function() {
            var a = rb(this).utc();
            return 0 < a.year() && a.year() <= 9999 ? M(a, "YYYY-MM-DD[T]HH:mm:ss.SSS[Z]") : M(a, "YYYYYY-MM-DD[T]HH:mm:ss.SSS[Z]")
        },
        toArray: function() {
            var a = this;
            return [a.year(), a.month(), a.date(), a.hours(), a.minutes(), a.seconds(), a.milliseconds()]
        },
        isValid: function() {
            return F(this)
        },
        isDSTShifted: function() {
            return this._a ? this.isValid() && v(this._a, (this._isUTC ? rb.utc(this._a) : rb(this._a)).toArray()) > 0 : !1
        },
        parsingFlags: function() {
            return l({}, this._pf)
        },
        invalidAt: function() {
            return this._pf.overflow
        },
        utc: function(a) {
            return this.zone(0, a)
        },
        local: function(a) {
            return this._isUTC && (this.zone(0, a), this._isUTC = !1, a && this.add(this._d.getTimezoneOffset(), "m")), this
        },
        format: function(a) {
            var b = M(this, a || rb.defaultFormat);
            return this.localeData().postformat(b)
        },
        add: r(1, "add"),
        subtract: r(-1, "subtract"),
        diff: function(a, b, c) {
            var d, e, f = J(a, this),
                g = 6e4 * (this.zone() - f.zone());
            return b = w(b), "year" === b || "month" === b ? (d = 432e5 * (this.daysInMonth() + f.daysInMonth()), e = 12 * (this.year() - f.year()) + (this.month() - f.month()), e += (this - rb(this).startOf("month") - (f - rb(f).startOf("month"))) / d, e -= 6e4 * (this.zone() - rb(this).startOf("month").zone() - (f.zone() - rb(f).startOf("month").zone())) / d, "year" === b && (e /= 12)) : (d = this - f, e = "second" === b ? d / 1e3 : "minute" === b ? d / 6e4 : "hour" === b ? d / 36e5 : "day" === b ? (d - g) / 864e5 : "week" === b ? (d - g) / 6048e5 : d), c ? e : n(e)
        },
        from: function(a, b) {
            return rb.duration({
                to: this,
                from: a
            }).locale(this.locale()).humanize(!b)
        },
        fromNow: function(a) {
            return this.from(rb(), a)
        },
        calendar: function(a) {
            var b = a || rb(),
                c = J(b, this).startOf("day"),
                d = this.diff(c, "days", !0),
                e = -6 > d ? "sameElse" : -1 > d ? "lastWeek" : 0 > d ? "lastDay" : 1 > d ? "sameDay" : 2 > d ? "nextDay" : 7 > d ? "nextWeek" : "sameElse";
            return this.format(this.localeData().calendar(e, this))
        },
        isLeapYear: function() {
            return D(this.year())
        },
        isDST: function() {
            return this.zone() < this.clone().month(0).zone() || this.zone() < this.clone().month(5).zone()
        },
        day: function(a) {
            var b = this._isUTC ? this._d.getUTCDay() : this._d.getDay();
            return null != a ? (a = cb(a, this.localeData()), this.add(a - b, "d")) : b
        },
        month: mb("Month", !0),
        startOf: function(a) {
            switch (a = w(a)) {
                case "year":
                    this.month(0);
                case "quarter":
                case "month":
                    this.date(1);
                case "week":
                case "isoWeek":
                case "day":
                    this.hours(0);
                case "hour":
                    this.minutes(0);
                case "minute":
                    this.seconds(0);
                case "second":
                    this.milliseconds(0)
            }
            return "week" === a ? this.weekday(0) : "isoWeek" === a && this.isoWeekday(1), "quarter" === a && this.month(3 * Math.floor(this.month() / 3)), this
        },
        endOf: function(a) {
            return a = w(a), this.startOf(a).add(1, "isoWeek" === a ? "week" : a).subtract(1, "ms")
        },
        isAfter: function(a, b) {
            return b = "undefined" != typeof b ? b : "millisecond", +this.clone().startOf(b) > +rb(a).startOf(b)
        },
        isBefore: function(a, b) {
            return b = "undefined" != typeof b ? b : "millisecond", +this.clone().startOf(b) < +rb(a).startOf(b)
        },
        isSame: function(a, b) {
            return b = b || "ms", +this.clone().startOf(b) === +J(a, this).startOf(b)
        },
        min: e("moment().min is deprecated, use moment.min instead. https://github.com/moment/moment/issues/1548", function(a) {
            return a = rb.apply(null, arguments), this > a ? this : a
        }),
        max: e("moment().max is deprecated, use moment.max instead. https://github.com/moment/moment/issues/1548", function(a) {
            return a = rb.apply(null, arguments), a > this ? this : a
        }),
        zone: function(a, b) {
            var c, d = this._offset || 0;
            return null == a ? this._isUTC ? d : this._d.getTimezoneOffset() : ("string" == typeof a && (a = P(a)), Math.abs(a) < 16 && (a = 60 * a), !this._isUTC && b && (c = this._d.getTimezoneOffset()), this._offset = a, this._isUTC = !0, null != c && this.subtract(c, "m"), d !== a && (!b || this._changeInProgress ? s(this, rb.duration(d - a, "m"), 1, !1) : this._changeInProgress || (this._changeInProgress = !0, rb.updateOffset(this, !0), this._changeInProgress = null)), this)
        },
        zoneAbbr: function() {
            return this._isUTC ? "UTC" : ""
        },
        zoneName: function() {
            return this._isUTC ? "Coordinated Universal Time" : ""
        },
        parseZone: function() {
            return this._tzm ? this.zone(this._tzm) : "string" == typeof this._i && this.zone(this._i), this
        },
        hasAlignedHourOffset: function(a) {
            return a = a ? rb(a).zone() : 0, (this.zone() - a) % 60 === 0
        },
        daysInMonth: function() {
            return A(this.year(), this.month())
        },
        dayOfYear: function(a) {
            var b = wb((rb(this).startOf("day") - rb(this).startOf("year")) / 864e5) + 1;
            return null == a ? b : this.add(a - b, "d")
        },
        quarter: function(a) {
            return null == a ? Math.ceil((this.month() + 1) / 3) : this.month(3 * (a - 1) + this.month() % 3)
        },
        weekYear: function(a) {
            var b = fb(this, this.localeData()._week.dow, this.localeData()._week.doy).year;
            return null == a ? b : this.add(a - b, "y")
        },
        isoWeekYear: function(a) {
            var b = fb(this, 1, 4).year;
            return null == a ? b : this.add(a - b, "y")
        },
        week: function(a) {
            var b = this.localeData().week(this);
            return null == a ? b : this.add(7 * (a - b), "d")
        },
        isoWeek: function(a) {
            var b = fb(this, 1, 4).week;
            return null == a ? b : this.add(7 * (a - b), "d")
        },
        weekday: function(a) {
            var b = (this.day() + 7 - this.localeData()._week.dow) % 7;
            return null == a ? b : this.add(a - b, "d")
        },
        isoWeekday: function(a) {
            return null == a ? this.day() || 7 : this.day(this.day() % 7 ? a : a - 7)
        },
        isoWeeksInYear: function() {
            return B(this.year(), 1, 4)
        },
        weeksInYear: function() {
            var a = this.localeData()._week;
            return B(this.year(), a.dow, a.doy)
        },
        get: function(a) {
            return a = w(a), this[a]()
        },
        set: function(a, b) {
            return a = w(a), "function" == typeof this[a] && this[a](b), this
        },
        locale: function(b) {
            return b === a ? this._locale._abbr : (this._locale = rb.localeData(b), this)
        },
        lang: e("moment().lang() is deprecated. Use moment().localeData() instead.", function(b) {
            return b === a ? this.localeData() : (this._locale = rb.localeData(b), this)
        }),
        localeData: function() {
            return this._locale
        }
    }), rb.fn.millisecond = rb.fn.milliseconds = mb("Milliseconds", !1), rb.fn.second = rb.fn.seconds = mb("Seconds", !1), rb.fn.minute = rb.fn.minutes = mb("Minutes", !1), rb.fn.hour = rb.fn.hours = mb("Hours", !0), rb.fn.date = mb("Date", !0), rb.fn.dates = e("dates accessor is deprecated. Use date instead.", mb("Date", !0)), rb.fn.year = mb("FullYear", !0), rb.fn.years = e("years accessor is deprecated. Use year instead.", mb("FullYear", !0)), rb.fn.days = rb.fn.day, rb.fn.months = rb.fn.month, rb.fn.weeks = rb.fn.week, rb.fn.isoWeeks = rb.fn.isoWeek, rb.fn.quarters = rb.fn.quarter, rb.fn.toJSON = rb.fn.toISOString, l(rb.duration.fn = k.prototype, {
        _bubble: function() {
            var a, b, c, d = this._milliseconds,
                e = this._days,
                f = this._months,
                g = this._data,
                h = 0;
            g.milliseconds = d % 1e3, a = n(d / 1e3), g.seconds = a % 60, b = n(a / 60), g.minutes = b % 60, c = n(b / 60), g.hours = c % 24, e += n(c / 24), h = n(nb(e)), e -= n(ob(h)), f += n(e / 30), e %= 30, h += n(f / 12), f %= 12, g.days = e, g.months = f, g.years = h
        },
        abs: function() {
            return this._milliseconds = Math.abs(this._milliseconds), this._days = Math.abs(this._days), this._months = Math.abs(this._months), this._data.milliseconds = Math.abs(this._data.milliseconds), this._data.seconds = Math.abs(this._data.seconds), this._data.minutes = Math.abs(this._data.minutes), this._data.hours = Math.abs(this._data.hours), this._data.months = Math.abs(this._data.months), this._data.years = Math.abs(this._data.years), this
        },
        weeks: function() {
            return n(this.days() / 7)
        },
        valueOf: function() {
            return this._milliseconds + 864e5 * this._days + this._months % 12 * 2592e6 + 31536e6 * z(this._months / 12)
        },
        humanize: function(a) {
            var b = eb(this, !a, this.localeData());
            return a && (b = this.localeData().pastFuture(+this, b)), this.localeData().postformat(b)
        },
        add: function(a, b) {
            var c = rb.duration(a, b);
            return this._milliseconds += c._milliseconds, this._days += c._days, this._months += c._months, this._bubble(), this
        },
        subtract: function(a, b) {
            var c = rb.duration(a, b);
            return this._milliseconds -= c._milliseconds, this._days -= c._days, this._months -= c._months, this._bubble(), this
        },
        get: function(a) {
            return a = w(a), this[a.toLowerCase() + "s"]()
        },
        as: function(a) {
            var b, c;
            if (a = w(a), b = this._days + this._milliseconds / 864e5, "month" === a || "year" === a) return c = this._months + 12 * nb(b), "month" === a ? c : c / 12;
            switch (b += ob(this._months / 12), a) {
                case "week":
                    return b / 7;
                case "day":
                    return b;
                case "hour":
                    return 24 * b;
                case "minute":
                    return 24 * b * 60;
                case "second":
                    return 24 * b * 60 * 60;
                case "millisecond":
                    return 24 * b * 60 * 60 * 1e3;
                default:
                    throw new Error("Unknown unit " + a)
            }
        },
        lang: rb.fn.lang,
        locale: rb.fn.locale,
        toIsoString: e("toIsoString() is deprecated. Please use toISOString() instead (notice the capitals)", function() {
            return this.toISOString()
        }),
        toISOString: function() {
            var a = Math.abs(this.years()),
                b = Math.abs(this.months()),
                c = Math.abs(this.days()),
                d = Math.abs(this.hours()),
                e = Math.abs(this.minutes()),
                f = Math.abs(this.seconds() + this.milliseconds() / 1e3);
            return this.asSeconds() ? (this.asSeconds() < 0 ? "-" : "") + "P" + (a ? a + "Y" : "") + (b ? b + "M" : "") + (c ? c + "D" : "") + (d || e || f ? "T" : "") + (d ? d + "H" : "") + (e ? e + "M" : "") + (f ? f + "S" : "") : "P0D"
        },
        localeData: function() {
            return this._locale
        }
    });
    for (tb in fc) fc.hasOwnProperty(tb) && pb(tb.toLowerCase());
    rb.duration.fn.asMilliseconds = function() {
            return this.as("ms")
        }, rb.duration.fn.asSeconds = function() {
            return this.as("s")
        }, rb.duration.fn.asMinutes = function() {
            return this.as("m")
        }, rb.duration.fn.asHours = function() {
            return this.as("h")
        }, rb.duration.fn.asDays = function() {
            return this.as("d")
        }, rb.duration.fn.asWeeks = function() {
            return this.as("weeks")
        }, rb.duration.fn.asMonths = function() {
            return this.as("M")
        }, rb.duration.fn.asYears = function() {
            return this.as("y")
        }, rb.locale("en", {
            ordinal: function(a) {
                var b = a % 10,
                    c = 1 === z(a % 100 / 10) ? "th" : 1 === b ? "st" : 2 === b ? "nd" : 3 === b ? "rd" : "th";
                return a + c
            }
        }),
	function(a) {
            a(rb)
        }(function(a) {
            return a.defineLocale("sv", {
                months: "januari_februari_mars_april_maj_juni_juli_augusti_september_oktober_november_december".split("_"),
                monthsShort: "jan_feb_mar_apr_maj_jun_jul_aug_sep_okt_nov_dec".split("_"),
                weekdays: "s�ndag_m�ndag_tisdag_onsdag_torsdag_fredag_l�rdag".split("_"),
                weekdaysShort: "s�n_m�n_tis_ons_tor_fre_l�r".split("_"),
                weekdaysMin: "s�_m�_ti_on_to_fr_l�".split("_"),
                longDateFormat: {
                    LT: "HH:mm",
                    L: "YYYY-MM-DD",
                    LL: "D MMMM YYYY",
                    LLL: "D MMMM YYYY LT",
                    LLLL: "dddd D MMMM YYYY LT"
                },
                calendar: {
                    sameDay: "[Idag] LT",
                    nextDay: "[Imorgon] LT",
                    lastDay: "[Ig�r] LT",
                    nextWeek: "dddd LT",
                    lastWeek: "[F�rra] dddd[en] LT",
                    sameElse: "L"
                },
                relativeTime: {
                    future: "om %s",
                    past: "f�r %s sedan",
                    s: "n�gra sekunder",
                    m: "en minut",
                    mm: "%d minuter",
                    h: "en timme",
                    hh: "%d timmar",
                    d: "en dag",
                    dd: "%d dagar",
                    M: "en m�nad",
                    MM: "%d m�nader",
                    y: "ett �r",
                    yy: "%d �r"
                },
                ordinal: function(a) {
                    var b = a % 10,
                        c = 1 === ~~(a % 100 / 10) ? "e" : 1 === b ? "a" : 2 === b ? "a" : 3 === b ? "e" : "e";
                    return a + c
                },
                week: {
                    dow: 1,
                    doy: 4
                }
            })
        }),
	function(a) {
            a(rb)
        }(function(a) {
            return a.defineLocale("en-gb", {
                months: "January_February_March_April_May_June_July_August_September_October_November_December".split("_"),
                monthsShort: "Jan_Feb_Mar_Apr_May_Jun_Jul_Aug_Sep_Oct_Nov_Dec".split("_"),
                weekdays: "Sunday_Monday_Tuesday_Wednesday_Thursday_Friday_Saturday".split("_"),
                weekdaysShort: "Sun_Mon_Tue_Wed_Thu_Fri_Sat".split("_"),
                weekdaysMin: "Su_Mo_Tu_We_Th_Fr_Sa".split("_"),
                longDateFormat: {
                    LT: "HH:mm",
                    L: "DD/MM/YYYY",
                    LL: "D MMMM YYYY",
                    LLL: "D MMMM YYYY LT",
                    LLLL: "dddd, D MMMM YYYY LT"
                },
                calendar: {
                    sameDay: "[Today at] LT",
                    nextDay: "[Tomorrow at] LT",
                    nextWeek: "dddd [at] LT",
                    lastDay: "[Yesterday at] LT",
                    lastWeek: "[Last] dddd [at] LT",
                    sameElse: "L"
                },
                relativeTime: {
                    future: "in %s",
                    past: "%s ago",
                    s: "a few seconds",
                    m: "a minute",
                    mm: "%d minutes",
                    h: "an hour",
                    hh: "%d hours",
                    d: "a day",
                    dd: "%d days",
                    M: "a month",
                    MM: "%d months",
                    y: "a year",
                    yy: "%d years"
                },
                ordinal: function(a) {
                    var b = a % 10,
                        c = 1 === ~~(a % 100 / 10) ? "th" : 1 === b ? "st" : 2 === b ? "nd" : 3 === b ? "rd" : "th";
                    return a + c
                },
                week: {
                    dow: 1,
                    doy: 4
                }
            })
        }), rb.locale("en"), Gb ? module.exports = rb : "function" == typeof define && define.amd ? (define("moment", function(a, b, c) {
            return c.config && c.config() && c.config().noGlobal === !0 && (vb.moment = sb), rb
        }), qb(!0)) : qb()
}).call(this);
! function(a) {
    "function" == typeof define && define.amd ? define(["jquery", "moment"], a) : "object" == typeof exports ? a(require("jquery"), require("moment")) : a(jQuery, moment)
}(function(a, b) {
    function c(c, d) {
        if (this.element = c, this.options = a.extend(!0, {}, f, d), this.options.events.length && (this.options.events = this.options.multiDayEvents ? this.addMultiDayMomentObjectsToEvents(this.options.events) : this.addMomentObjectToEvents(this.options.events)), this.month = this.options.startWithMonth ? b(this.options.startWithMonth).startOf("month") : b().startOf("month"), this.options.constraints) {
            if (this.options.constraints.startDate) {
                var g = b(this.options.constraints.startDate);
                this.month.isBefore(g, "month") && (this.month.set("month", g.month()), this.month.set("year", g.year()))
            }
            if (this.options.constraints.endDate) {
                var h = b(this.options.constraints.endDate);
                this.month.isAfter(h, "month") && this.month.set("month", h.month()).set("year", h.year())
            }
        }
        this._defaults = f, this._name = e, this.init()
    }
    var d = "<div class='clndr-controls'><div class='clndr-control-button'><span class='clndr-previous-button'>previous</span></div><div class='month'><%= month %> <%= year %></div><div class='clndr-control-button rightalign'><span class='clndr-next-button'>next</span></div></div><table class='clndr-table' border='0' cellspacing='0' cellpadding='0'><thead><tr class='header-days'><% for(var i = 0; i < daysOfTheWeek.length; i++) { %><td class='header-day'><%= daysOfTheWeek[i] %></td><% } %></tr></thead><tbody><% for(var i = 0; i < numberOfRows; i++){ %><tr><% for(var j = 0; j < 7; j++){ %><% var d = j + i * 7; %><td class='<%= days[d].classes %>'><div class='day-contents'><%= days[d].day %></div></td><% } %></tr><% } %></tbody></table>",
        e = "clndr",
        f = {
            template: d,
            weekOffset: 0,
            startWithMonth: null,
            clickEvents: {
                click: null,
                nextMonth: null,
                previousMonth: null,
                nextYear: null,
                previousYear: null,
                today: null,
                onMonthChange: null,
                onYearChange: null
            },
            targets: {
                nextButton: "clndr-next-button",
                previousButton: "clndr-previous-button",
                nextYearButton: "clndr-next-year-button",
                previousYearButton: "clndr-previous-year-button",
                todayButton: "clndr-today-button",
                day: "day",
                empty: "empty"
            },
            events: [],
            extras: null,
            dateParameter: "date",
            multiDayEvents: null,
            doneRendering: null,
            render: null,
            daysOfTheWeek: null,
            showAdjacentMonths: !0,
            adjacentDaysChangeMonth: !1,
            ready: null,
            constraints: null,
            forceSixRows: null
        };
    c.prototype.init = function() {
        if (this.daysOfTheWeek = this.options.daysOfTheWeek || [], !this.options.daysOfTheWeek) {
            this.daysOfTheWeek = [];
            for (var c = 0; 7 > c; c++) this.daysOfTheWeek.push(b().weekday(c).format("dd").charAt(0))
        }
        if (this.options.weekOffset && (this.daysOfTheWeek = this.shiftWeekdayLabels(this.options.weekOffset)), !a.isFunction(this.options.render)) {
            if (this.options.render = null, "undefined" == typeof _) throw new Error("Underscore was not found. Please include underscore.js OR provide a custom render function.");
            this.compiledClndrTemplate = _.template(this.options.template)
        }
        a(this.element).html("<div class='clndr'></div>"), this.calendarContainer = a(".clndr", this.element), this.bindEvents(), this.render(), this.options.ready && this.options.ready.apply(this, [])
    }, c.prototype.shiftWeekdayLabels = function(a) {
        for (var b = this.daysOfTheWeek, c = 0; a > c; c++) b.push(b.shift());
        return b
    }, c.prototype.createDaysObject = function(c) {
        daysArray = [];
        var d = c.startOf("month");
        if (this.eventsLastMonth = [], this.eventsThisMonth = [], this.eventsNextMonth = [], this.options.events.length)
            if (this.options.multiDayEvents) {
                if (this.eventsThisMonth = a(this.options.events).filter(function() {
                        return this._clndrStartDateObject.format("YYYY-MM") === c.format("YYYY-MM") || this._clndrEndDateObject.format("YYYY-MM") === c.format("YYYY-MM") ? !0 : this._clndrStartDateObject.format("YYYY-MM") <= c.format("YYYY-MM") && this._clndrEndDateObject.format("YYYY-MM") >= c.format("YYYY-MM") ? !0 : !1
                    }).toArray(), this.options.showAdjacentMonths) {
                    var e = c.clone().subtract("months", 1),
                        f = c.clone().add("months", 1);
                    this.eventsLastMonth = a(this.options.events).filter(function() {
                        return this._clndrStartDateObject.format("YYYY-MM") === e.format("YYYY-MM") || this._clndrEndDateObject.format("YYYY-MM") === e.format("YYYY-MM") ? !0 : this._clndrStartDateObject.format("YYYY-MM") <= e.format("YYYY-MM") && this._clndrEndDateObject.format("YYYY-MM") >= e.format("YYYY-MM") ? !0 : !1
                    }).toArray(), this.eventsNextMonth = a(this.options.events).filter(function() {
                        return this._clndrStartDateObject.format("YYYY-MM") === f.format("YYYY-MM") || this._clndrEndDateObject.format("YYYY-MM") === f.format("YYYY-MM") ? !0 : this._clndrStartDateObject.format("YYYY-MM") <= f.format("YYYY-MM") && this._clndrEndDateObject.format("YYYY-MM") >= f.format("YYYY-MM") ? !0 : !1
                    }).toArray()
                }
            } else if (this.eventsThisMonth = a(this.options.events).filter(function() {
                return this._clndrDateObject.format("YYYY-MM") == c.format("YYYY-MM")
            }).toArray(), this.options.showAdjacentMonths) {
            var e = c.clone().subtract("months", 1),
                f = c.clone().add("months", 1);
            this.eventsLastMonth = a(this.options.events).filter(function() {
                return this._clndrDateObject.format("YYYY-MM") == e.format("YYYY-MM")
            }).toArray(), this.eventsNextMonth = a(this.options.events).filter(function() {
                return this._clndrDateObject.format("YYYY-MM") == f.format("YYYY-MM")
            }).toArray()
        }
        var g = d.weekday() - this.options.weekOffset;
        if (0 > g && (g += 7), this.options.showAdjacentMonths)
            for (var h = 0; g > h; h++) {
                var i = b([c.year(), c.month(), h - g + 1]);
                daysArray.push(this.createDayObject(i, this.eventsLastMonth))
            } else
                for (var h = 0; g > h; h++) daysArray.push(this.calendarDay({
                    classes: this.options.targets.empty + " last-month"
                }));
        for (var j = d.daysInMonth(), h = 1; j >= h; h++) {
            var i = b([c.year(), c.month(), h]);
            daysArray.push(this.createDayObject(i, this.eventsThisMonth))
        }
        for (var h = 1; daysArray.length % 7 !== 0;) {
            if (this.options.showAdjacentMonths) {
                var i = b([c.year(), c.month(), j + h]);
                daysArray.push(this.createDayObject(i, this.eventsNextMonth))
            } else daysArray.push(this.calendarDay({
                classes: this.options.targets.empty + " next-month"
            }));
            h++
        }
        if (this.options.forceSixRows && 42 !== daysArray.length)
            for (var k = b(daysArray[daysArray.length - 1].date).add("days", 1); daysArray.length < 42;) this.options.showAdjacentMonths ? (daysArray.push(this.createDayObject(b(k), this.eventsNextMonth)), k.add("days", 1)) : daysArray.push(this.calendarDay({
                classes: this.options.targets.empty + " next-month"
            }));
        return daysArray
    }, c.prototype.createDayObject = function(a, c) {
        var d = [],
            e = b(),
            f = this,
            g = 0,
            h = c.length;
        for (g; h > g; g++)
            if (f.options.multiDayEvents) {
                var i = c[g]._clndrStartDateObject,
                    j = c[g]._clndrEndDateObject;
                (a.isSame(i, "day") || a.isAfter(i, "day")) && (a.isSame(j, "day") || a.isBefore(j, "day")) && d.push(c[g])
            } else c[g]._clndrDateObject.date() == a.date() && d.push(c[g]);
        var k = "";
        return e.format("YYYY-MM-DD") == a.format("YYYY-MM-DD") && (k += " today"), a.isBefore(e, "day") && (k += " past"), d.length && (k += " event"), this.month.month() > a.month() ? (k += " adjacent-month", k += this.month.year() === a.year() ? " last-month" : " next-month") : this.month.month() < a.month() && (k += " adjacent-month", k += this.month.year() === a.year() ? " next-month" : " last-month"), this.options.constraints && (this.options.constraints.startDate && a.isBefore(b(this.options.constraints.startDate)) && (k += " inactive"), this.options.constraints.endDate && a.isAfter(b(this.options.constraints.endDate)) && (k += " inactive")), !a.isValid() && a.hasOwnProperty("_d") && void 0 != a._d && (a = b(a._d)), k += " calendar-day-" + a.format("YYYY-MM-DD"), k += " calendar-dow-" + a.weekday(), this.calendarDay({
            day: a.date(),
            classes: this.options.targets.day + k,
            events: d,
            date: a
        })
    }, c.prototype.render = function() {
        this.calendarContainer.children().remove();
        var a = this.createDaysObject(this.month),
            c = (this.month, {
                daysOfTheWeek: this.daysOfTheWeek,
                numberOfRows: Math.ceil(a.length / 7),
                days: a,
                month: this.month.format("MMMM"),
                year: this.month.year(),
                eventsThisMonth: this.eventsThisMonth,
                eventsLastMonth: this.eventsLastMonth,
                eventsNextMonth: this.eventsNextMonth,
                extras: this.options.extras
            });
        if (this.options.render ? this.calendarContainer.html(this.options.render.apply(this, [c])) : this.calendarContainer.html(this.compiledClndrTemplate(c)), this.options.constraints) {
            for (target in this.options.targets) target != this.options.targets.day && this.element.find("." + this.options.targets[target]).toggleClass("inactive", !1);
            var d = null,
                e = null;
            this.options.constraints.startDate && (d = b(this.options.constraints.startDate)), this.options.constraints.endDate && (e = b(this.options.constraints.endDate)), d && this.month.isSame(d, "month") && this.element.find("." + this.options.targets.previousButton).toggleClass("inactive", !0), e && this.month.isSame(e, "month") && this.element.find("." + this.options.targets.nextButton).toggleClass("inactive", !0), d && b(d).subtract("years", 1).isBefore(b(this.month).subtract("years", 1)) && this.element.find("." + this.options.targets.previousYearButton).toggleClass("inactive", !0), e && b(e).add("years", 1).isAfter(b(this.month).add("years", 1)) && this.element.find("." + this.options.targets.nextYearButton).toggleClass("inactive", !0), (d && d.isAfter(b(), "month") || e && e.isBefore(b(), "month")) && this.element.find("." + this.options.targets.today).toggleClass("inactive", !0)
        }
        this.options.doneRendering && this.options.doneRendering.apply(this, [])
    }, c.prototype.bindEvents = function() {
        var b = a(this.element),
            c = this;
        b.on("click", "." + this.options.targets.day, function(b) {
            if (c.options.clickEvents.click) {
                var d = c.buildTargetObject(b.currentTarget, !0);
                c.options.clickEvents.click.apply(c, [d])
            }
            c.options.adjacentDaysChangeMonth && (a(b.currentTarget).is(".last-month") ? c.backActionWithContext(c) : a(b.currentTarget).is(".next-month") && c.forwardActionWithContext(c))
        }), b.on("click", "." + this.options.targets.empty, function(b) {
            if (c.options.clickEvents.click) {
                var d = c.buildTargetObject(b.currentTarget, !1);
                c.options.clickEvents.click.apply(c, [d])
            }
            c.options.adjacentDaysChangeMonth && (a(b.currentTarget).is(".last-month") ? c.backActionWithContext(c) : a(b.currentTarget).is(".next-month") && c.forwardActionWithContext(c))
        }), b.on("click", "." + this.options.targets.previousButton, {
            context: this
        }, this.backAction).on("click", "." + this.options.targets.nextButton, {
            context: this
        }, this.forwardAction).on("click", "." + this.options.targets.todayButton, {
            context: this
        }, this.todayAction).on("click", "." + this.options.targets.nextYearButton, {
            context: this
        }, this.nextYearAction).on("click", "." + this.options.targets.previousYearButton, {
            context: this
        }, this.previousYearAction)
    }, c.prototype.buildTargetObject = function(c, d) {
        var e = {
            element: c,
            events: [],
            date: null
        };
        if (d) {
            var f, g = c.className.indexOf("calendar-day-");
            0 !== g ? (f = c.className.substring(g + 13, g + 23), e.date = b(f)) : e.date = null, this.options.events && (e.events = this.options.multiDayEvents ? a.makeArray(a(this.options.events).filter(function() {
                return (e.date.isSame(this._clndrStartDateObject, "day") || e.date.isAfter(this._clndrStartDateObject, "day")) && (e.date.isSame(this._clndrEndDateObject, "day") || e.date.isBefore(this._clndrEndDateObject, "day"))
            })) : a.makeArray(a(this.options.events).filter(function() {
                return this._clndrDateObject.format("YYYY-MM-DD") == f
            })))
        }
        return e
    }, c.prototype.forwardAction = function(a) {
        var b = a.data.context;
        b.forwardActionWithContext(b)
    }, c.prototype.backAction = function(a) {
        var b = a.data.context;
        b.backActionWithContext(b)
    }, c.prototype.backActionWithContext = function(a) {
        if (!a.element.find("." + a.options.targets.previousButton).hasClass("inactive")) {
            var c = !a.month.isSame(b(a.month).subtract("months", 1), "year");
            a.month.subtract("months", 1), a.render(), a.options.clickEvents.previousMonth && a.options.clickEvents.previousMonth.apply(a, [b(a.month)]), a.options.clickEvents.onMonthChange && a.options.clickEvents.onMonthChange.apply(a, [b(a.month)]), c && a.options.clickEvents.onYearChange && a.options.clickEvents.onYearChange.apply(a, [b(a.month)])
        }
    }, c.prototype.forwardActionWithContext = function(a) {
        if (!a.element.find("." + a.options.targets.nextButton).hasClass("inactive")) {
            var c = !a.month.isSame(b(a.month).add("months", 1), "year");
            a.month.add("months", 1), a.render(), a.options.clickEvents.nextMonth && a.options.clickEvents.nextMonth.apply(a, [b(a.month)]), a.options.clickEvents.onMonthChange && a.options.clickEvents.onMonthChange.apply(a, [b(a.month)]), c && a.options.clickEvents.onYearChange && a.options.clickEvents.onYearChange.apply(a, [b(a.month)])
        }
    }, c.prototype.todayAction = function(a) {
        var c = a.data.context,
            d = !c.month.isSame(b(), "month"),
            e = !c.month.isSame(b(), "year");
        c.month = b().startOf("month"), c.options.clickEvents.today && c.options.clickEvents.today.apply(c, [b(c.month)]), d && (c.render(), c.month = b(), c.options.clickEvents.onMonthChange && c.options.clickEvents.onMonthChange.apply(c, [b(c.month)]), e && c.options.clickEvents.onYearChange && c.options.clickEvents.onYearChange.apply(c, [b(c.month)]))
    }, c.prototype.nextYearAction = function(a) {
        var c = a.data.context;
        c.element.find("." + c.options.targets.nextYearButton).hasClass("inactive") || (c.month.add("years", 1), c.render(), c.options.clickEvents.nextYear && c.options.clickEvents.nextYear.apply(c, [b(c.month)]), c.options.clickEvents.onMonthChange && c.options.clickEvents.onMonthChange.apply(c, [b(c.month)]), c.options.clickEvents.onYearChange && c.options.clickEvents.onYearChange.apply(c, [b(c.month)]))
    }, c.prototype.previousYearAction = function(a) {
        var c = a.data.context;
        c.element.find("." + c.options.targets.previousYear).hasClass("inactive") || (c.month.subtract("years", 1), c.render(), c.options.clickEvents.previousYear && c.options.clickEvents.previousYear.apply(c, [b(c.month)]), c.options.clickEvents.onMonthChange && c.options.clickEvents.onMonthChange.apply(c, [b(c.month)]), c.options.clickEvents.onYearChange && c.options.clickEvents.onYearChange.apply(c, [b(c.month)]))
    }, c.prototype.forward = function(a) {
        return this.month.add("months", 1), this.render(), a && a.withCallbacks && (this.options.clickEvents.onMonthChange && this.options.clickEvents.onMonthChange.apply(this, [b(this.month)]), 0 === this.month.month() && this.options.clickEvents.onYearChange && this.options.clickEvents.onYearChange.apply(this, [b(this.month)])), this
    }, c.prototype.back = function(a) {
        return this.month.subtract("months", 1), this.render(), a && a.withCallbacks && (this.options.clickEvents.onMonthChange && this.options.clickEvents.onMonthChange.apply(this, [b(this.month)]), 11 === this.month.month() && this.options.clickEvents.onYearChange && this.options.clickEvents.onYearChange.apply(this, [b(this.month)])), this
    }, c.prototype.next = function(a) {
        return this.forward(a), this
    }, c.prototype.previous = function(a) {
        return this.back(a), this
    }, c.prototype.setMonth = function(a, c) {
        return this.month.month(a), this.render(), c && c.withCallbacks && this.options.clickEvents.onMonthChange && this.options.clickEvents.onMonthChange.apply(this, [b(this.month)]), this
    }, c.prototype.getMonth = function(a) {
        return this.month.month(a)
    }, c.prototype.nextYear = function(a) {
        return this.month.add("year", 1), this.render(), a && a.withCallbacks && this.options.clickEvents.onYearChange && this.options.clickEvents.onYearChange.apply(this, [b(this.month)]), this
    }, c.prototype.previousYear = function(a) {
        return this.month.subtract("year", 1), this.render(), a && a.withCallbacks && this.options.clickEvents.onYearChange && this.options.clickEvents.onYearChange.apply(this, [b(this.month)]), this
    }, c.prototype.setYear = function(a, c) {
        return this.month.year(a), this.render(), c && c.withCallbacks && this.options.clickEvents.onYearChange && this.options.clickEvents.onYearChange.apply(this, [b(this.month)]), this
    }, c.prototype.setEvents = function(a) {
        return this.options.events = this.options.multiDayEvents ? this.addMultiDayMomentObjectsToEvents(a) : this.addMomentObjectToEvents(a), this.render(), this
    }, c.prototype.addEvents = function(b) {
        return this.options.events = this.options.multiDayEvents ? a.merge(this.options.events, this.addMultiDayMomentObjectsToEvents(b)) : a.merge(this.options.events, this.addMomentObjectToEvents(b)), this.render(), this
    }, c.prototype.addMomentObjectToEvents = function(a) {
        var c = this,
            d = 0,
            e = a.length;
        for (d; e > d; d++) a[d]._clndrDateObject = b(a[d][c.options.dateParameter]);
        return a
    }, c.prototype.addMultiDayMomentObjectsToEvents = function(a) {
        var c = this,
            d = 0,
            e = a.length;
        for (d; e > d; d++) a[d]._clndrStartDateObject = b(a[d][c.options.multiDayEvents.startDate]), a[d]._clndrEndDateObject = b(a[d][c.options.multiDayEvents.endDate]);
        return a
    }, c.prototype.calendarDay = function(b) {
        var c = {
            day: "",
            classes: this.options.targets.empty,
            events: [],
            date: null
        };
        return a.extend({}, c, b)
    }, a.fn.clndr = function(a) {
        if (1 === this.length) {
            if (!this.data("plugin_clndr")) {
                var b = new c(this, a);
                return this.data("plugin_clndr", b), b
            }
        } else if (this.length > 1) throw new Error("CLNDR does not support multiple elements yet. Make sure your clndr selector returns only one element.")
    }
});

Handlebars.registerHelper('list', function(items, options) {

    var x = 0;
    var out = '<div class="calendar-row">';

    for (var i = 0, il = items.length; i < il; i++) {

        var data = items[i];

        if (x === 0) {
            if (i !== 0) {
                out += '<div class="calendar-row">';
            }
            out += '<div><span>' + new Date(data.date._d).getWeekNumber() + '</<span></div>';
        }


        if (data.events.length > 0) {
            data.classes += ' activities';
        }

        out += '<a class="' + data.classes + '" href="#"><span>' + data.day + '</span>'
        if (data.events.length > 0) {
            out += getEventHtml(data.events);
        }
        out += '</a>';

        if (x === 6) {
            out += '</div>';
            x = 0;
        } else {
            x++;
        }
    }

    return out + '</div>';
});

Handlebars.registerHelper('widget_list', function(items, options) {

    var x = 0;
    var out = '<li class="week">';
    for (var i = 0, il = items.length; i < il; i++) {

        var data = items[i];

        if (x === 0) {
            if (i !== 0) {
                out += '<li class="week">';
            }
            out += '<div><span><span>' + new Date(data.date._d).getWeekNumber() + '</span></span></div></li>';
        }


        if (data.events.length > 0) {
            data.classes += ' activities';
        }

        var thisDate = new Date(data.date._d);

        if ((thisDate.getTime() == activeDay.getTime())) {
            data.classes += ' active';
        }

        out += '<li class="' + data.classes + '"><div><span><span>' + data.day;
        if (data.events.length > 0) {
            out += getWidgetEventHtml(data.events);
        }
        out += '</span></li>';

        if (x === 6) {
            x = 0;
        } else {
            x++;
        }
    }

    return out + '</div>';
});

Handlebars.registerHelper('eventsList', function(items, options) {

    var x = 0;
    var out = '<ul class="of-feed-list">';

    for (var i = 0, il = items.length; i < il; i++) {

        var data = items[i];

        out += '<li>';
        out += '<a href="' + data.postURI + '">';
        out += '<h5>' + data.title + '</h5>';
        out += '<ul class="of-meta-line">';
        out += '<li>' + getTime(data.startTime, data.endTime, data.allDay) + '</li>';
        out += '<li>' + data.location + '</li>';
        if (typeof data.postedIn !== 'undefined') {
            out += '<li>' + data.postedIn + '</li>';
        }
        out += '</ul>';
        out += '</a>';
        out += '</li>';

    }

    return out + '</ul>';
});

Handlebars.registerHelper('currentEvents', function(items, options) {

    return new Handlebars.SafeString(getWidgetDay(items, true));
});

function getTime(startTime, endTime, allDay) {
    startTime = new Date(startTime / 1000),
        endTime = new Date(endTime / 1000);

    if (startTime.getMonth() !== endTime.getMonth())
        return moment.unix(startTime).format('HH:mm') + ' - ' + moment.unix(endTime).format('D MMMM HH:mm');

    if (allDay !== false)
        return 'Heldag';

    if (startTime.getTime() == endTime.getTime())
        return moment.unix(startTime).format('HH:mm');

    return moment.unix(startTime).format('HH:mm') + ' - ' + moment.unix(endTime).format('HH:mm');
}

function getWidgetEventHtml(events) {

    var out = '<span class="activites">'

    for (var i = 0, il = events.length; i < il; i++) {
        if (i > 2)
            break;

        out += '<b></b>';
    }

    return out + '</span>';
}

function getEventHtml(events) {

    var response = '<ul>';

    for (var i = 0, il = events.length; i < il; i++) {

        response += '<li>';
        response += '<span>';
        response += events[i].allDay !== false ? 'Heldag' : moment.unix(events[i].startTime / 1000).format('HH:mm');
        response += '</span>';
        response += '<h5>' + events[i].title + '</h5>';
        response += '</li>';

    }

    return response + '</ul>';

}

function getWidgetDay(events, html) {

    html = typeof html !== 'undefined' ? html : false;
    var out = '';

    console.log(events);

    if (typeof events === 'undefined' || events.length === 0) {

        out = '<li class="empty">Inga kalenderh�ndelser idag</li>';
        return html ? out : $(out);
    }

    for (var i = 0, il = events.length; i < il; i++) {
        var data = events[i];

        out += '<li>';
        out += '<a href="' + data.postURI + '">';
        out += '<h5>' + data.title + '</h5>';
        out += '<ul class="of-meta-line">';
        out += '<li>' + getTime(data.startTime, data.endTime, data.allDay) + '</li>';
        out += '<li>' + data.location + '</li>';
        out += '</ul>';
        out += '</a>';
        out += '</li>';
    }

    return html ? out : $(out);
}

function setupTodaysEvents(events, today) {

    var today = typeof today !== 'undefined' ? today : new Date(),
        matches = 0,
        tmpEvents = [];

    for (var i = 0, il = events.length; i < il; i++) {
        
    	var date = new Date(Date.parse(events[i].date));
    	
		if ((date.getDate() == today.getDate() && date.getMonth() == today.getMonth() && date.getFullYear() == today.getFullYear())) {

            tmpEvents.push(events[i]);
        }
    		
    }

    ofCalendarTodaysEvents = tmpEvents;

}

Handlebars.registerHelper('safe_string', function(context) {
    var html = context;
    // context variable is the HTML you will pass into the helper
    // Strip the script tags from the html, and return it as a Handlebars.SafeString
    return new Handlebars.SafeString(html);
});

Date.prototype.getWeekNumber = function() {
    var begin = new Date(this.getFullYear(), 0, 1),
        response = Math.ceil((((this - begin) / 86400000) + begin.getDay() + 1) / 7);
    return response > 52 ? 1 : response;
}

String.prototype.toUcFirst = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}
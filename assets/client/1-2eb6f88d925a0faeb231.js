webpackJsonp([1],{"1xar":function(t,e,o){"use strict";function r(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")}function n(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}function i(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}var u,a,l,s,c,p,f,h,y,b,_,v,g,d,w=function t(e,o,r){null===e&&(e=Function.prototype);var n=Object.getOwnPropertyDescriptor(e,o);if(void 0===n){var i=Object.getPrototypeOf(e);return null===i?void 0:t(i,o,r)}if("value"in n)return n.value;var u=n.get;if(void 0!==u)return u.call(r)},O=function(){function t(t,e){for(var o=0;o<e.length;o++){var r=e[o];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(t,r.key,r)}}return function(e,o,r){return o&&t(e.prototype,o),r&&t(e,r),e}}();u=o("aGLy"),o("y11e"),f=o("OhLM");var m=o("sJcH");a=m.BaseLocalStorageCollection,p=o("KIRP"),u.Radio.channel("global"),s=u.Radio.channel("bumblr"),b="//api.tumblr.com/v2",h=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),O(e,[{key:"url",value:function(){return b+"/"+this.id+"/posts/photo?callback=?"}}]),e}(u.Collection),l=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),O(e,[{key:"url",value:function(){return this.baseURL+"/blog/"+this.base_hostname+"/posts/photo?api_key="+this.api_key}},{key:"fetch",value:function(t){var o,r;return t||(t={}),t.data||{},o=this.state.currentPage,r=o*this.state.pageSize,t.offset=r,t.dataType="jsonp",w(e.prototype.__proto__||Object.getPrototypeOf(e.prototype),"fetch",this).call(this,t)}},{key:"parse",value:function(t){var o;return o=t.response.total_posts,this.state.totalRecords=o,w(e.prototype.__proto__||Object.getPrototypeOf(e.prototype),"parse",this).call(this,t.response.posts)}}]),e}(f);return t.prototype.mode="server",t.prototype.full=!0,t.prototype.baseURL=b,t.prototype.state={firstPage:0,pageSize:15},t.prototype.queryParams={pageSize:"limit",offset:function(){return this.state.currentPage*this.state.pageSize}},t}(),v=function(t){var e,o,r;return r=s.request("get_app_settings"),e=r.get("consumer_key"),o=new l,o.api_key=e,o.base_hostname=t,o},g="make_blog_post_collection",s.reply(g,function(t){return v(t)}),c=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),O(e,[{key:"add_blog",value:function(t){var e,o;return o=t+".tumblr.com",e=new p.BlogInfo,e.set("id",o),e.set("name",t),e.api_key=this.api_key,this.add(e),this.save(),e.fetch(),e}}]),e}(a);return t.prototype.model=p.BlogInfo,t}(),_=new c,d=s.request("get_app_settings"),y=d.get("consumer_key"),_.api_key=y,s.reply("get_local_blogs",function(){return _}),t.exports={PhotoPostCollection:h}},Gncq:function(t,e,o){"use strict";function r(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")}function n(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}function i(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}var u,a,l,s,c,p,f,h=function(){function t(t,e){for(var o=0;o<e.length;o++){var r=e[o];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(t,r.key,r)}}return function(e,o,r){return o&&t(e.prototype,o),r&&t(e,r),e}}(),y=function t(e,o,r){null===e&&(e=Function.prototype);var n=Object.getOwnPropertyDescriptor(e,o);if(void 0===n){var i=Object.getPrototypeOf(e);return null===i?void 0:t(i,o,r)}if("value"in n)return n.value;var u=n.get;if(void 0!==u)return u.call(r)};c=o("y11e"),f=o("agle"),l=o("iopH"),s=Backbone.Radio.channel("global"),a=Backbone.Radio.channel("bumblr"),p=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),e}(c.AppRouter);return t.prototype.appRoutes={bumblr:"start","bumblr/settings":"settings_page","bumblr/dashboard":"show_dashboard","bumblr/listblogs":"list_blogs","bumblr/viewblog/:id":"view_blog","bumblr/addblog":"add_new_blog"},t}(),u=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),h(e,[{key:"onBeforeStart",value:function(){var t;return t=a.request("get_local_blogs"),t.fetch(),y(e.prototype.__proto__||Object.getPrototypeOf(e.prototype),"onBeforeStart",this).call(this,arguments)}}]),e}(f);return t.prototype.Controller=l,t.prototype.Router=p,t}(),s.reply("applet:bumblr:route",function(){var t,e;return console.warn("Don't use applet:bumblr:route"),e=new l(s),t=a.request("get_local_blogs"),t.fetch(),new p({controller:e})}),t.exports=u},KIRP:function(t,e,o){"use strict";function r(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")}function n(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}function i(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}var u,a,l,s,c,p,f,h,y,b=function(){function t(t,e){for(var o=0;o<e.length;o++){var r=e[o];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(t,r.key,r)}}return function(e,o,r){return o&&t(e.prototype,o),r&&t(e,r),e}}();u=o("aGLy"),c=u.Radio.channel("bumblr"),a=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),b(e,[{key:"initialize",value:function(){return this.fetch(),this.on("change",this.save,this)}},{key:"fetch",value:function(){return this.set(JSON.parse(localStorage.getItem(this.id)))}},{key:"save",value:function(t,e){return localStorage.setItem(this.id,JSON.stringify(this.toJSON())),$.ajax({success:e.success,error:e.error})}},{key:"destroy",value:function(t){return localStorage.removeItem(this.id)}},{key:"isEmpty",value:function(){return _.size(this.attributes<=1)}}]),e}(u.Model),f="//api.tumblr.com/v2",p=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),e}(a);return t.prototype.id="bumblr_settings",t}(),l=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),e}(u.Model);return t.prototype.baseURL=f,t}(),s=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),b(e,[{key:"url",value:function(){return this.baseURL+"/blog/"+this.id+"/info?api_key="+this.api_key+"&callback=?"}}]),e}(l),y="4mhV8B1YQK6PUA2NW8eZZXVHjU55TPJ3UZnZGrbSoCnqJaxDyH",h=new p({consumer_key:y}),c.reply("get_app_settings",function(){return h}),t.exports={BlogInfo:s}},LcSZ:function(t,e,o){"use strict";function r(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")}function n(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}function i(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}var u,a,l,s,c,p;u=o("aGLy"),o("y11e"),p=o("2mEY"),u.Radio.channel("bumblr"),c=p.renderable(function(t){return p.p("main bumblr view")}),s=p.renderable(function(t){return p.p("bumblr_dashboard_view")}),l=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),e}(u.Marionette.View);return t.prototype.template=c,t}(),a=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),e}(u.Marionette.View);return t.prototype.template=s,t}(),t.exports={MainBumblrView:l,BumblrDashboardView:a}},agle:function(t,e,o){"use strict";function r(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")}function n(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}function i(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}var u,a,l=function(){function t(t,e){for(var o=0;o<e.length;o++){var r=e[o];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(t,r.key,r)}}return function(e,o,r){return o&&t(e.prototype,o),r&&t(e,r),e}}(),s=[].indexOf;o("y11e"),a=o("HWfR"),Backbone.Radio.channel("global"),u=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),l(e,[{key:"onBeforeStart",value:function(){var t,e,o,r,n,i=this;return e=new this.Controller,e.applet=this,this.router=new this.Router({controller:e}),(null!=this?this.appRoutes:void 0)&&(t=("function"==typeof this.appRoutes?this.appRoutes():void 0)||this.appRoutes,Object.keys(t).forEach(function(e){return i.router.appRoute(e,t[e])})),(null!=(r=this.options)?r.isFrontdoorApplet:void 0)&&(o=(null!=(n=this.options.appConfig)?n.startFrontdoorMethod:void 0)||"start",s.call(Object.keys(this.router.appRoutes),"")<0&&this.router.appRoute("",o)),this._extraRouters={},this.initExtraRouters()}},{key:"onStop",value:function(){}},{key:"setExtraRouter",value:function(t,e,o){var r,n;return r=new o,n=new e({controller:r}),this._extraRouters[t]=n}},{key:"initExtraRouters",value:function(){var t,e,o,r;t=this.getOption("extraRouters"),this.getOption("extraRouters"),e=[];for(r in t)o=t[r],console.log("rtr",r,o),this.setExtraRouter(r,o.router,o.controller),e.push(void 0);return e}},{key:"getExtraRouter",value:function(t){return this._extraRouters[t]}}]),e}(a.App),t.exports=u},iopH:function(t,e,o){"use strict";function r(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")}function n(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}function i(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}var u,a,l,s,c,p,f,h,y,b,_,v,g,d=function t(e,o,r){null===e&&(e=Function.prototype);var n=Object.getOwnPropertyDescriptor(e,o);if(void 0===n){var i=Object.getPrototypeOf(e);return null===i?void 0:t(i,o,r)}if("value"in n)return n.value;var u=n.get;if(void 0!==u)return u.call(r)},w=function(){function t(t,e){for(var o=0;o<e.length;o++){var r=e[o];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(t,r.key,r)}}return function(e,o,r){return o&&t(e.prototype,o),r&&t(e,r),e}}();u=o("4kSj"),a=o("aGLy"),o("y11e"),_=o("2mEY"),b=o("9w6x"),y=o("SiCa");var O=o("GXmR");c=O.MainController;var m=o("iuxk");f=m.ToolbarAppletLayout,o("KIRP"),o("1xar"),p=o("LcSZ"),l=a.Radio.channel("bumblr"),v=new a.Model({entries:[{name:"List Blogs",url:"#bumblr/listblogs",icon:"list"},{name:"Settings",url:"#bumblr/settings",icon:"gear"}]}),g=_.renderable(function(t){return _.div(".btn-group.btn-group-justified",function(){var e,o,r,n,i;for(n=t.entries,i=[],o=0,r=n.length;o<r;o++)e=n[o],i.push(_.div(".toolbar-button.btn.btn-default",{"button-url":e.url},function(){return _.span(".fa.fa-"+e.icon," "+e.name)}));return i})}),h=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),w(e,[{key:"toolbarButtonPressed",value:function(t){var e;return console.log("toolbarButtonPressed",t),e=t.currentTarget.getAttribute("button-url"),y(e)}}]),e}(a.Marionette.View);return t.prototype.template=g,t.prototype.ui={toolbarButton:".toolbar-button"},t.prototype.events={"click @ui.toolbarButton":"toolbarButtonPressed"},t}(),s=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),w(e,[{key:"setup_layout_if_needed",value:function(){var t;return d(e.prototype.__proto__||Object.getPrototypeOf(e.prototype),"setup_layout_if_needed",this).call(this),t=new h({model:v}),this.layout.showChildView("toolbar",t)}},{key:"set_header",value:function(t){var e;return e=u("#header"),e.text(t)}},{key:"start",value:function(){return this.setup_layout_if_needed(),this.set_header("Bumblr"),this.list_blogs()}},{key:"default_view",value:function(){return this.start()}},{key:"show_mainview",value:function(){var t;return t=new p.MainBumblrView,this.layout.showChildView("content",t),b()}},{key:"show_dashboard",value:function(){var t;return t=new p.BumblrDashboardView,this.layout.showChildView("content",t),b()}},{key:"list_blogs",value:function(){var t=this;return this.setup_layout_if_needed(),o.e(5).then(function(){var e,r,n;return r=l.request("get_local_blogs"),e=o("4i3l"),n=new e({collection:r}),t.layout.showChildView("content",n)}.bind(null,o)).catch(o.oe)}},{key:"view_blog",value:function(t){var e=this;return this.setup_layout_if_needed(),o.e(5).then(function(){var r,n,i,u;return i=t+".tumblr.com",n=l.request("make_blog_post_collection",i),r=o("QSsu"),u=n.fetch(),u.done(function(){var t;return t=new r({collection:n}),e.layout.showChildView("content",t),b()})}.bind(null,o)).catch(o.oe)}},{key:"add_new_blog",value:function(){var t=this;return this.setup_layout_if_needed(),o.e(7).then(function(){var e,r;return e=o("Rif3"),r=new e,t.layout.showChildView("content",r),b()}.bind(null,o)).catch(o.oe)}},{key:"settings_page",value:function(){var t=this;return this.setup_layout_if_needed(),o.e(7).then(function(){var e,r,n;return e=o("jry7"),r=l.request("get_app_settings"),n=new e({model:r}),t.layout.showChildView("content",n),b()}.bind(null,o)).catch(o.oe)}}]),e}(c);return t.prototype.layoutClass=f,t}(),t.exports=s},sJcH:function(t,e,o){"use strict";function r(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")}function n(t,e){if(!t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!e||"object"!=typeof e&&"function"!=typeof e?t:e}function i(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}var u,a,l=function(){function t(t,e){for(var o=0;o<e.length;o++){var r=e[o];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(t,r.key,r)}}return function(e,o,r){return o&&t(e.prototype,o),r&&t(e,r),e}}();o("4kSj"),o("rdLu"),u=o("aGLy"),o("y11e"),u.Radio.channel("global"),u.Radio.channel("messages"),u.Radio.channel("resources"),a=function(){var t=function(t){function e(){return r(this,e),n(this,(e.__proto__||Object.getPrototypeOf(e)).apply(this,arguments))}return i(e,t),l(e,[{key:"initialize",value:function(){return this.fetch(),this.on("change",this.save,this)}},{key:"fetch",value:function(){var t;return t=JSON.parse(localStorage.getItem(this.local_storage_key))||[],this.set(t)}},{key:"save",value:function(t){return localStorage.setItem(this.local_storage_key,JSON.stringify(this.toJSON()))}}]),e}(u.Collection);return t.prototype.local_storage_key=null,t}(),t.exports={BaseLocalStorageCollection:a}}});
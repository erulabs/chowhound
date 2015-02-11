(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function (global){
'use strict';
var AppWindow, BreakWindow, Chowhound, DatatableWindow, GraphWindow, LoginWindow, ManagerWindow, ProfileWindow, RegisterWindow, TeamsWindow, app,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __hasProp = {}.hasOwnProperty;

app = angular.module('app', ['ngCookies', 'ui.bootstrap']);

AppWindow = (function() {
  function AppWindow(_at_app, _at_show) {
    this.app = _at_app;
    this.show = _at_show;
    if (this.show == null) {
      this.show = false;
    }
  }

  return AppWindow;

})();

global.AppWindow = AppWindow;

LoginWindow = require('./controllers/login.coffee');

RegisterWindow = require('./controllers/register.coffee');

ProfileWindow = require('./controllers/profile.coffee');

BreakWindow = require('./controllers/break.coffee');

TeamsWindow = require('./controllers/teams.coffee');

GraphWindow = require('./controllers/graph.coffee');

DatatableWindow = require('./controllers/datatable.coffee');

ManagerWindow = (function(_super) {
  __extends(ManagerWindow, _super);

  function ManagerWindow() {
    return ManagerWindow.__super__.constructor.apply(this, arguments);
  }

  return ManagerWindow;

})(AppWindow);

app.controller('chowhound', [
  '$scope', '$http', '$cookies', '$cookieStore', '$location', '$modal', Chowhound = (function() {
    function Chowhound(_at_$scope, _at_$http, _at_$cookies, _at_$cookieStore, _at_$location, _at_$modal) {
      var expires, loginError, token;
      this.$scope = _at_$scope;
      this.$http = _at_$http;
      this.$cookies = _at_$cookies;
      this.$cookieStore = _at_$cookieStore;
      this.$location = _at_$location;
      this.$modal = _at_$modal;
      this.STATS_INTERVAL = 10;
      this.$scope.login = new LoginWindow(this);
      loginError = location.search.split('error=')[1];
      if (loginError != null) {
        this.$scope.login.error = loginError.replace(/%20/g, ' ');
      }
      this.$scope.register = new RegisterWindow(this);
      this.$scope.profile = new ProfileWindow(this);
      this.$scope.graph = new GraphWindow(this);
      this.$scope.teams = new TeamsWindow(this);
      this.$scope.datatable = new DatatableWindow(this);
      this.$scope.manager = new ManagerWindow(this);
      this.$scope["break"] = new BreakWindow(this);
      token = this.$cookies['x-chow-token'];
      expires = this.$cookies['x-chow-token-expires'];
      if (expires < (new Date().getTime()) || (token == null) || (this.$scope.profile.username == null)) {
        token = void 0;
        this.logout();
      } else if (token != null) {
        this.initData();
      } else {
        this.$scope.login.show = true;
      }
    }

    Chowhound.prototype.logout = function() {
      this.$cookieStore.remove('x-chow-token');
      this.$cookieStore.remove('x-chow-token-expires');
      return this.$scope.login.show = true;
    };

    Chowhound.prototype.initData = function() {
      return this.get('/data').success((function(_this) {
        return function(data, status, headers) {
          if (data.error) {
            return _this.logout();
          } else {
            return _this.$scope.login.login(data);
          }
        };
      })(this)).error((function(_this) {
        return function(data, status, headers) {
          if (status === 404) {
            return _this.logout();
          }
        };
      })(this));
    };

    Chowhound.prototype.http = function(options) {
      if (options.headers == null) {
        options.headers = {};
      }
      if (this.$cookies['x-chow-token'] != null) {
        options.headers['x-chow-token'] = this.$cookies['x-chow-token'].replace(/"/g, '');
      }
      return this.$http(options);
    };

    Chowhound.prototype.get = function(uri) {
      return this.http({
        method: 'GET',
        url: '/api' + uri
      });
    };

    Chowhound.prototype.post = function(uri, data) {
      if (data == null) {
        data = {};
      }
      return this.http({
        method: 'POST',
        url: '/api' + uri,
        data: data
      });
    };

    return Chowhound;

  })()
]);



}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./controllers/break.coffee":2,"./controllers/datatable.coffee":3,"./controllers/graph.coffee":4,"./controllers/login.coffee":5,"./controllers/profile.coffee":6,"./controllers/register.coffee":7,"./controllers/teams.coffee":8}],2:[function(require,module,exports){
'use strict';
var BreakWindow,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __hasProp = {}.hasOwnProperty;

BreakWindow = (function(_super) {
  __extends(BreakWindow, _super);

  function BreakWindow() {
    return BreakWindow.__super__.constructor.apply(this, arguments);
  }

  BreakWindow.prototype.init = function() {
    return this.show = false;
  };

  BreakWindow.prototype.modalTrigger = function() {
    var $scope, modal;
    $scope = this.app.$scope;
    return modal = this.app.$modal.open({
      templateUrl: 'breakModalContent',
      controller: 'chowhound',
      resolve: {
        profile: function() {
          return $scope.profile;
        },
        teams: function() {
          return $scope.teams;
        }
      }
    });
  };

  return BreakWindow;

})(AppWindow);

module.exports = BreakWindow;



},{}],3:[function(require,module,exports){
'use strict';
var DatatableWindow,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __hasProp = {}.hasOwnProperty;

DatatableWindow = (function(_super) {
  __extends(DatatableWindow, _super);

  function DatatableWindow() {
    return DatatableWindow.__super__.constructor.apply(this, arguments);
  }

  DatatableWindow.prototype.init = function() {
    return this.show = true;
  };

  return DatatableWindow;

})(AppWindow);

module.exports = DatatableWindow;



},{}],4:[function(require,module,exports){
'use strict';
var GraphWindow,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __hasProp = {}.hasOwnProperty;

GraphWindow = (function(_super) {
  __extends(GraphWindow, _super);

  function GraphWindow() {
    return GraphWindow.__super__.constructor.apply(this, arguments);
  }

  GraphWindow.prototype.init = function(initialData) {
    this.show = true;
    this.chart = {};
    return angular.element(document).ready((function(_this) {
      return function() {
        return _this.chart = new Chartist.Line('.ct-chart', initialData.graphdata, {
          low: 0,
          showArea: true
        });
      };
    })(this));
  };

  GraphWindow.prototype.update = function(data) {
    console.log('new data for graph', data);
    return this.chart.update(data.graphdata);
  };

  return GraphWindow;

})(AppWindow);

module.exports = GraphWindow;



},{}],5:[function(require,module,exports){
'use strict';
var LoginWindow,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __hasProp = {}.hasOwnProperty;

LoginWindow = (function(_super) {
  __extends(LoginWindow, _super);

  function LoginWindow(_at_app, _at_show) {
    this.app = _at_app;
    this.show = _at_show;
    this.username = '';
    if (this.app.$cookies['x-chow-user'] != null) {
      this.username = this.app.$cookies['x-chow-user'];
    }
    this.password = '';
  }

  LoginWindow.prototype.register = function() {
    this.show = false;
    return this.app.$scope.register.show = true;
  };

  LoginWindow.prototype.login = function(data) {
    this.app.$scope.datatable.init();
    this.app.$scope.profile.init();
    this.app.$scope.teams.init();
    this.app.$scope.teams.show = true;
    this.app.$scope.teams.teams = Object.keys(data.teams);
    this.app.$scope.teams.begin(this.app.STATS_INTERVAL);
    if (this.app.$scope.teams.teams.length > 0) {
      return this.app.$scope.graph.init(data);
    }
  };

  return LoginWindow;

})(AppWindow);

module.exports = LoginWindow;



},{}],6:[function(require,module,exports){
'use strict';
var ProfileWindow,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __hasProp = {}.hasOwnProperty;

ProfileWindow = (function(_super) {
  __extends(ProfileWindow, _super);

  function ProfileWindow() {
    return ProfileWindow.__super__.constructor.apply(this, arguments);
  }

  ProfileWindow.prototype.init = function() {
    return this.show = true;
  };

  ProfileWindow.prototype.modalTrigger = function() {
    var $scope, modal;
    $scope = this.app.$scope;
    return modal = this.app.$modal.open({
      templateUrl: 'profileModalContent',
      controller: 'chowhound',
      resolve: {
        profile: function() {
          return $scope.profile;
        },
        teams: function() {
          return $scope.teams;
        }
      }
    });
  };

  ProfileWindow.prototype.logout = function() {
    return this.app.post('/logout').success((function(_this) {
      return function(data, status, headers, config) {
        if (data.error) {
          return alert(data.error);
        } else {
          return _this.doLogoutAction();
        }
      };
    })(this)).error((function(_this) {
      return function(data, status, headers, config) {
        return _this.doLogoutAction();
      };
    })(this));
  };

  ProfileWindow.prototype.doLogoutAction = function() {
    this.app.$cookieStore.remove('x-chow-token');
    this.app.$cookieStore.remove('x-chow-token-expires');
    this.app.$scope.login.show = true;
    this.app.$scope.graph.show = false;
    this.app.$scope.datatable.show = false;
    this.app.$scope.profile.username = void 0;
    this.app.$scope.profile.show = false;
    this.app.$scope.manager.show = false;
    return this.app.$scope.teams.show = false;
  };

  ProfileWindow.prototype.createTeam = function(teamName) {
    return this.app.post('/new/team', {
      name: teamName
    }).success((function(_this) {
      return function(data, status, headers, config) {
        if (data.error) {
          return alert(data.error);
        } else {
          return _this.app.initData();
        }
      };
    })(this)).error(function(data, status, headers, config) {
      return console.log('error', data);
    });
  };

  return ProfileWindow;

})(AppWindow);

module.exports = ProfileWindow;



},{}],7:[function(require,module,exports){
'use strict';
var RegisterWindow,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __hasProp = {}.hasOwnProperty;

RegisterWindow = (function(_super) {
  __extends(RegisterWindow, _super);

  function RegisterWindow(_at_app, _at_show) {
    this.app = _at_app;
    this.show = _at_show;
    this.username = '';
    this.password = '';
    this.password_confirm = '';
    this.starttime = new Date();
    this.starttime.setHours(9);
    this.starttime.setMinutes(0);
    this.endtime = new Date();
    this.endtime.setMinutes(0);
    this.endtime.setHours(17);
    this.dotw = {
      mon: 1,
      tue: 1,
      wed: 1,
      thu: 1,
      fri: 1,
      sat: 0,
      sun: 0
    };
  }

  RegisterWindow.prototype.starttimeChanged = function() {
    return console.log(this.starttime);
  };

  RegisterWindow.prototype.submit = function() {
    if (this.password !== this.password_confirm) {
      return alert('Passwords do not match');
    }
    return this.app.post('/register', {
      username: this.username,
      password: this.password,
      starttime: this.starttime,
      endtime: this.endtime,
      dotw: this.dotw
    }).success((function(_this) {
      return function(data, status, headers, config) {
        if (data.error) {
          return alert(data.error);
        } else {
          _this.show = false;
          _this.app.$cookies['x-chow-token'] = data.token;
          _this.app.$cookies['x-chow-user'] = _this.username;
          _this.app.$cookies['x-chow-token-expires'] = data.expires;
          return _this.app.$scope.login.login(data);
        }
      };
    })(this)).error(function(data, status, headers, config) {
      return console.log('error', data);
    });
  };

  RegisterWindow.prototype.back = function() {
    this.show = false;
    return this.app.$scope.login.show = true;
  };

  return RegisterWindow;

})(AppWindow);

module.exports = RegisterWindow;



},{}],8:[function(require,module,exports){
'use strict';
var TeamsWindow,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __hasProp = {}.hasOwnProperty;

TeamsWindow = (function(_super) {
  __extends(TeamsWindow, _super);

  function TeamsWindow() {
    return TeamsWindow.__super__.constructor.apply(this, arguments);
  }

  TeamsWindow.prototype.init = function() {
    this.show = false;
    this.teams = [];
    this.isManager = false;
    return this.graphData = {};
  };

  TeamsWindow.prototype.begin = function(interval) {
    return setInterval((function(_this) {
      return function() {
        return _this.app.get('/data').success(function(data, status, headers) {
          if (data.error) {
            return _this.logout();
          } else {
            if (data.teams.length > 0) {
              return _this.app.$scope.graph.update(data);
            }
          }
        }).error(function(data, status, headers) {
          if (status === 404) {
            return _this.logout();
          }
        });
      };
    })(this), interval * 1000);
  };

  return TeamsWindow;

})(AppWindow);

module.exports = TeamsWindow;



},{}]},{},[1]);

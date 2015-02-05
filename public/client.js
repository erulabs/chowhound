(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';
var AppWindow, BreakWindow, Chowhound, DatatableWindow, GraphWindow, LoginWindow, ManagerWindow, ProfileWindow, RegisterWindow, STATS_INTERVAL, StatsWindow, app,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

app = angular.module('app', ['ngCookies']);

STATS_INTERVAL = 10;

AppWindow = (function() {
  function AppWindow(app, show) {
    this.app = app;
    this.show = show;
    if (this.show == null) {
      this.show = false;
    }
  }

  return AppWindow;

})();

LoginWindow = (function(_super) {
  __extends(LoginWindow, _super);

  function LoginWindow(app, show) {
    this.app = app;
    this.show = show;
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
    this.app.$scope.stats.init();
    this.app.$scope.stats.show = true;
    this.app.$scope.stats.teams = Object.keys(data.teams);
    this.app.$scope.stats.begin(STATS_INTERVAL);
    if (this.app.$scope.stats.teams.length > 0) {
      return this.app.$scope.graph.init(data);
    }
  };

  return LoginWindow;

})(AppWindow);

RegisterWindow = (function(_super) {
  __extends(RegisterWindow, _super);

  function RegisterWindow(app, show) {
    this.app = app;
    this.show = show;
    this.username = '';
    this.password = '';
    this.groups = '';
  }

  RegisterWindow.prototype.submit = function() {
    return this.app.post('/register', {
      username: this.username,
      password: this.password,
      groups: this.groups
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

ProfileWindow = (function(_super) {
  __extends(ProfileWindow, _super);

  function ProfileWindow() {
    return ProfileWindow.__super__.constructor.apply(this, arguments);
  }

  ProfileWindow.prototype.init = function() {
    this.show = false;
    return this.username = this.app.$cookies['x-chow-user'];
  };

  ProfileWindow.prototype.logout = function() {
    return this.app.post('/logout').success((function(_this) {
      return function(data, status, headers, config) {
        if (data.error) {
          return alert(data.error);
        } else {
          _this.app.$cookieStore.remove('x-chow-token');
          _this.app.$cookieStore.remove('x-chow-token-expires');
          _this.app.$scope.login.show = true;
          _this.app.$scope.graph.show = false;
          _this.app.$scope.datatable.show = false;
          _this.app.$scope.profile.show = false;
          _this.app.$scope.manager.show = false;
          return _this.app.$scope.stats.show = false;
        }
      };
    })(this)).error(function(data, status, headers, config) {
      return console.log('error', data);
    });
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

BreakWindow = (function(_super) {
  __extends(BreakWindow, _super);

  function BreakWindow() {
    return BreakWindow.__super__.constructor.apply(this, arguments);
  }

  BreakWindow.prototype.init = function() {
    return this.show = false;
  };

  return BreakWindow;

})(AppWindow);

StatsWindow = (function(_super) {
  __extends(StatsWindow, _super);

  function StatsWindow() {
    return StatsWindow.__super__.constructor.apply(this, arguments);
  }

  StatsWindow.prototype.init = function() {
    this.show = false;
    this.teams = [];
    this.isManager = false;
    return this.graphData = {};
  };

  StatsWindow.prototype.begin = function(interval) {
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

  return StatsWindow;

})(AppWindow);

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

ManagerWindow = (function(_super) {
  __extends(ManagerWindow, _super);

  function ManagerWindow() {
    return ManagerWindow.__super__.constructor.apply(this, arguments);
  }

  return ManagerWindow;

})(AppWindow);

app.controller('chowhound', Chowhound = (function() {
  function Chowhound($scope, $http, $cookies, $cookieStore, $location) {
    var expires, token;
    this.$scope = $scope;
    this.$http = $http;
    this.$cookies = $cookies;
    this.$cookieStore = $cookieStore;
    this.$location = $location;
    this.$scope.login = new LoginWindow(this);
    this.$scope.register = new RegisterWindow(this);
    this.$scope.profile = new ProfileWindow(this);
    this.$scope.graph = new GraphWindow(this);
    this.$scope.stats = new StatsWindow(this);
    this.$scope.datatable = new DatatableWindow(this);
    this.$scope.manager = new ManagerWindow(this);
    this.$scope["break"] = new BreakWindow(this);
    token = this.$cookies['x-chow-token'];
    expires = this.$cookies['x-chow-token-expires'];
    if (expires < (new Date().getTime())) {
      token = void 0;
      this.logout();
    }
    if (token != null) {
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

})());



},{}]},{},[1]);

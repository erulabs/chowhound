(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';
var AppWindow, BreakWindow, Chowhound, DatatableWindow, GraphWindow, LoginWindow, ManagerWindow, ProfileWindow, RegisterWindow, StatsWindow, app,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

app = angular.module('app', ['ngCookies']);

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
    this.password = '';
  }

  LoginWindow.prototype.register = function() {
    this.show = false;
    return this.app.$scope.register.show = true;
  };

  LoginWindow.prototype.login = function(data) {
    this.app.$scope.graph.init();
    this.app.$scope.datatable.init();
    this.app.$scope.profile.init();
    this.app.$scope.stats.teams = _.keys(data.teams);
    return this.app.$scope.stats.show = true;
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
    return this.show = false;
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
    return this.team = false;
  };

  return StatsWindow;

})(AppWindow);

GraphWindow = (function(_super) {
  __extends(GraphWindow, _super);

  function GraphWindow() {
    return GraphWindow.__super__.constructor.apply(this, arguments);
  }

  GraphWindow.prototype.init = function() {
    var ampm, date, hour, hourList, thisHour, _i, _ref, _ref1;
    this.show = true;
    date = new Date();
    thisHour = date.getHours();
    ampm = 'am';
    if (thisHour > 11) {
      ampm = 'pm';
    }
    if (thisHour > 12) {
      thisHour = thisHour - 12;
    }
    if (thisHour === 0) {
      thisHour = 12;
    }
    hourList = [];
    for (hour = _i = _ref = thisHour - 1, _ref1 = thisHour + 7; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; hour = _ref <= _ref1 ? ++_i : --_i) {
      if (hour > 12) {
        hour = hour - 12;
        hourList.push(hour + 'am');
      } else {
        hourList.push(hour + 'pm');
      }
    }
    return angular.element(document).ready(function() {
      return new Chartist.Line('.ct-chart', {
        labels: hourList,
        series: [[5, 9, 7, 8, 5, 3, 5, 8]]
      }, {
        low: 0,
        showArea: true
      });
    });
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
      this.$cookieStore.remove('x-chow-token');
      this.$cookieStore.remove('x-chow-token-expires');
    }
    if (token != null) {
      this.initData();
    } else {
      this.$scope.login.show = true;
    }
  }

  Chowhound.prototype.initData = function() {
    return this.get('/data').success((function(_this) {
      return function(data, status, headers) {
        if (data.error) {
          _this.$cookieStore.remove('x-chow-token');
          _this.$cookieStore.remove('x-chow-token-expires');
          return _this.$scope.login.show = true;
        } else {
          return _this.$scope.login.login(data);
        }
      };
    })(this)).error((function(_this) {
      return function(data, status, headers) {
        if (status === 404) {
          _this.$cookieStore.remove('x-chow-token');
          _this.$cookieStore.remove('x-chow-token-expires');
          return _this.$scope.login.show = true;
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

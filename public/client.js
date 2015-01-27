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

  LoginWindow.prototype.submit = function() {
    return this.app.$http.post('/api/login', {
      username: this.username,
      password: this.password
    }).success((function(_this) {
      return function(data, status, headers, config) {
        if (data.error) {
          return alert(data.error);
        } else {
          _this.show = false;
          return _this.login(data);
        }
      };
    })(this)).error(function(data, status, headers, config) {
      return console.log('error', data);
    });
  };

  LoginWindow.prototype.tokenLogin = function(username, token) {
    return this.app.$http.post('/api/login', {
      username: username,
      token: token
    }).success((function(_this) {
      return function(data, status, headers, config) {
        if (data.error) {
          alert(data.error);
          _this.app.$cookieStore.remove('token');
          return _this.app.$scope.login.show = true;
        } else {
          _this.show = false;
          return _this.login(data);
        }
      };
    })(this)).error(function(data, status, headers, config) {
      return console.log('error', data);
    });
  };

  LoginWindow.prototype.register = function() {
    this.show = false;
    return this.app.$scope.register.show = true;
  };

  LoginWindow.prototype.login = function(data) {
    this.app.$scope.loading.show = false;
    this.app.$scope.graph.init();
    this.app.$scope.datatable.init();
    this.app.$scope.profile.init();
    this.app.$scope.stats.show = true;
    this.app.$cookies.token = data.token;
    return this.app.$cookies.username = data.username;
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
    return this.app.$http.post('/api/register', {
      username: this.username,
      password: this.password,
      groups: this.groups
    }).success((function(_this) {
      return function(data, status, headers, config) {
        if (data.error) {
          return alert(data.error);
        } else {
          _this.show = false;
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
    return this.app.$http.post('/api/logout', {
      logout: true
    }).success((function(_this) {
      return function(data, status, headers, config) {
        if (data.error) {
          return alert(data.error);
        } else {
          _this.app.$cookieStore.remove('token');
          _this.app.$cookieStore.remove('username');
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
    return this.show = false;
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
  function Chowhound($scope, $http, $cookies, $cookieStore) {
    this.$scope = $scope;
    this.$http = $http;
    this.$cookies = $cookies;
    this.$cookieStore = $cookieStore;
    this.$scope.loading = new AppWindow(this, true);
    this.$scope.login = new LoginWindow(this);
    this.$scope.register = new RegisterWindow(this);
    this.$scope.profile = new ProfileWindow(this);
    this.$scope.graph = new GraphWindow(this);
    this.$scope.stats = new StatsWindow(this);
    this.$scope.datatable = new DatatableWindow(this);
    this.$scope.manager = new ManagerWindow(this);
    this.$scope["break"] = new BreakWindow(this);
    this.$http({
      method: 'GET',
      url: '/api/data',
      headers: {
        'x-chow-user': this.$cookies.username,
        'x-chow-token': this.$cookies.token
      }
    }).success((function(_this) {
      return function(data, status, headers) {
        return _this.$scope.login.login(data);
      };
    })(this)).error((function(_this) {
      return function(data, status, headers) {
        if (status === 404) {
          _this.$scope.loading.show = false;
          return _this.$scope.login.show = true;
        }
      };
    })(this));
  }

  return Chowhound;

})());



},{}]},{},[1]);

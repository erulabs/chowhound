(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';
var AppWindow, Chowhound, DatatableWindow, GraphWindow, LoginWindow, ManagerWindow, ProfileWindow, RegisterWindow, SECRET, app,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

app = angular.module('app', ['ngCookies']);

SECRET = {
  token: {
    id: false,
    expires: false
  }
};

AppWindow = (function() {
  function AppWindow(app, show) {
    this.app = app;
    this.show = show;
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
    return this.app.$http.post('/api/new/login', {
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
    return this.app.$http.post('/api/new/login', {
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
    console.log('login action', data);
    this.app.$scope.graph.init();
    this.app.$scope.datatable.init();
    this.app.$scope.profile.init();
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
    console.log('ProfileWindow init');
    return this.show = true;
  };

  return ProfileWindow;

})(AppWindow);

GraphWindow = (function(_super) {
  __extends(GraphWindow, _super);

  function GraphWindow() {
    return GraphWindow.__super__.constructor.apply(this, arguments);
  }

  GraphWindow.prototype.init = function() {
    console.log('GraphWindow init');
    return this.show = true;
  };

  return GraphWindow;

})(AppWindow);

DatatableWindow = (function(_super) {
  __extends(DatatableWindow, _super);

  function DatatableWindow() {
    return DatatableWindow.__super__.constructor.apply(this, arguments);
  }

  DatatableWindow.prototype.init = function() {
    console.log('DatatableWindow init');
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
    this.$scope.loading = new AppWindow(this, false);
    this.$scope.login = new LoginWindow(this, false);
    this.$scope.register = new RegisterWindow(this, false);
    this.$scope.profile = new ProfileWindow(this, false);
    this.$scope.graph = new GraphWindow(this, false);
    this.$scope.datatable = new DatatableWindow(this, false);
    this.$scope.manager = new ManagerWindow(this, false);
    console.log(this.$cookies.token, this.$cookies.username);
    if (this.$cookies.token && this.$cookies.username) {
      this.$scope.login.tokenLogin(this.$cookies.username, this.$cookies.token);
    } else {
      this.$scope.login.show = true;
    }
  }

  Chowhound.prototype.loadData = function() {
    var self;
    self = this;
    if (this.$cookies.token) {
      return this.$http({
        url: '/api/data'
      }).success(function(data, status, headers, config) {
        console.log('done loading', data);
        return self.$scope.loading.show = true;
      }).error(function(data, status, headers, config) {
        return console.log('error', data);
      });
    }
  };

  return Chowhound;

})());



},{}]},{},[1]);

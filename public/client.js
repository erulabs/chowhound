(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';
var AppWindow, Chowhound, LoginWindow, RegisterWindow, SECRET, app,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

app = angular.module('app', []);

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
    }).success(function(data, status, headers, config) {
      return console.log('done logging in', data);
    }).error(function(data, status, headers, config) {
      return console.log('error', data);
    });
  };

  LoginWindow.prototype.register = function() {
    this.show = false;
    return this.app.$scope.register.show = true;
  };

  return LoginWindow;

})(AppWindow);

RegisterWindow = (function(_super) {
  __extends(RegisterWindow, _super);

  function RegisterWindow(app, show) {
    this.app = app;
    this.show = show;
  }

  return RegisterWindow;

})(AppWindow);

app.controller('chowhound', Chowhound = (function() {
  function Chowhound($scope, $http) {
    this.$scope = $scope;
    this.$http = $http;
    this.$scope.loading = new AppWindow(this, false);
    this.$scope.login = new LoginWindow(this, false);
    this.$scope.register = new AppWindow(this, false);
    this.$scope.profile = new AppWindow(this, false);
    this.$scope.graph = new AppWindow(this, false);
    this.$scope.datatable = new AppWindow(this, false);
    this.$scope.manager = new AppWindow(this, false);
    if (SECRET.token.id) {
      this.loadData();
    } else {
      this.$scope.login.show = true;
    }
  }

  Chowhound.prototype.loadData = function() {
    var self;
    self = this;
    if (SECRET.token.id) {
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

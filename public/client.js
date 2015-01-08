(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';
var AppWindow, Chowhound, app;

app = angular.module('app', []);

AppWindow = (function() {
  function AppWindow(show) {
    this.show = show;
  }

  return AppWindow;

})();

app.controller('chowhound', Chowhound = (function() {
  function Chowhound($scope, $http) {
    this.$scope = $scope;
    this.$http = $http;
    this.$scope.loading = new AppWindow(false);
    this.$scope.login = new AppWindow(false);
    this.$scope.profile = new AppWindow(false);
    this.$scope.graph = new AppWindow(false);
    this.$scope.datatable = new AppWindow(false);
    this.$scope.manager = new AppWindow(false);
    this.loadData();
  }

  Chowhound.prototype.loadData = function() {
    var self;
    self = this;
    return this.$http({
      url: '/api/data'
    }).success(function(data, status, headers, config) {
      console.log('done loading', data);
      return self.$scope.loading.show = true;
    }).error(function(data, status, headers, config) {
      return console.log('error', data);
    });
  };

  return Chowhound;

})());



},{}]},{},[1]);

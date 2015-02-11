'use strict'

class GraphWindow extends AppWindow
  init: (initialData) ->
    @show = yes
    @chart = {}
    angular.element(document).ready =>
      @chart = new Chartist.Line('.ct-chart', initialData.graphdata, {
        low: 0,
        showArea: true
      })

  update: (data) ->
    console.log 'new data for graph', data
    @chart.update data.graphdata

module.exports = GraphWindow

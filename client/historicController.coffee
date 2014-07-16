historic = @historic

class @HistoricController extends @LoginController
    waitOn: -> Meteor.subscribe("historic")
    data: ->
        hist = historic.find().fetch()
        for h in hist
            h.fecha = moment.unix(h.timestamp).format('DD-MM-YYYY')
        historic : hist
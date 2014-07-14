historic = @historic

class @HistoricController extends @LoginController
    waitOn: -> Meteor.subscribe("historic")
    data: ->
        historic: historic.find()

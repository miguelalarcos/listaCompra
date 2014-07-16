tags = @tags
lista = @lista

class @WorkingListController extends @LoginController
  waitOn: ->  [Meteor.subscribe('items'), Meteor.subscribe('accesible_list')]
  data: ->
    tas = tags.find({active: true}).fetch()
    all = lista.find({stored: false}).fetch()
    all = _.groupBy(all, (x)->x.tag)
    items: (key)->all[key]
    tags: -> (t.tag for t in tas)
    edit: true

Template.workingList.events
  'click .almacenar': (e,t)->
    Meteor.call "almacenar"







lista = @lista

class @DespensaController extends @LoginController
  waitOn: -> [Meteor.subscribe('items'), Meteor.subscribe('accesible_list')]
  data: ->
    tas = tags.find({active:true}).fetch()
    all = lista.find({stored: true}).fetch()
    all = _.groupBy(all, (x)->x.tag)
    items: (key)->all[key]
    tags: -> ({tag: t.tag, private: t.private} for t in tas)
    edit: false

Template.despensa.events
  'click div.take': (e,t)->
      _id = $(e.target).attr('_id')
      Meteor.call('take', _id)
  'click .consumir': (e,t)->
      Meteor.call "consumir"
  'click .vaciar': (e,t)->
      Meteor.call "vaciar"

Template.despensa.isTaken = (_id)->
  item = lista.findOne(_id)
  if item and item.taken
    'taken'
  else
    ''
tags = @tags
lista = @lista
_messages_ = @messages

class @WorkingListController extends @LoginController
  waitOn: ->  [Meteor.subscribe('items'), Meteor.subscribe('accesible_list'), Meteor.subscribe('messages')]
  data: ->
    tas = tags.find({active: true}).fetch()
    all = lista.find({stored: false}).fetch()
    all = _.groupBy(all, (x)->x.tag)
    #total por tag
    ret = []
    for t in tas
        sum = 0
        if _.has(all, t.tag)
            for item in all[t.tag]
                if item.quantity and item.price
                    sum += item.quantity*item.price
            ret.push {tag: t.tag, sum: sum}
        else
            ret.push {tag: t.tag, sum: 0}

    #return
    items: (key)->all[key]
    tags: -> ret #(t.tag for t in tas)
    edit: true
    messages: _messages_.find({})

Template.workingList.events
  'click .almacenar': (e,t)->
      Meteor.call "almacenar"
  'click .servicio': (e,t)->
      Meteor.call 'servicio'

Template.workingList.isVisibleButton = ->
    items = lista.find({stored: false, taken: true}).fetch()
    for it in items
        if _.isEmpty(it.market) or _.isEmpty(it.item) or _.isNaN(parseFloat(it.price)) or _.isNaN(parseFloat(it.quantity))
            return false
    return true

Deps.autorun ->
    ms = (x._id for  x in _messages_.find({}).fetch())
    f = ()->
        Meteor.call 'closeMessages', ms
    Meteor.setTimeout f, 5000



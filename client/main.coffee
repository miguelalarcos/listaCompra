local_items = new Meteor.Collection null
lista = @lista

Template.adminListas.events
    'click .guardar-lista': (e,t)->
        doc = {}
        doc.tag = $(t.find('.tag')).html()
        doc.descripcion = $(t.find('.descripcion')).val()
        doc.mails = $(t.find('.mails')).val()
        doc.mails = doc.mails.split(',')
        Meteor.call "guardarLista", doc
    'click .append-nueva-lista': (e,t)->
        Meteor.call "insertTag", $(".input-nueva-lista").val()

Template.despensa.events
  'click div.take': (e,t)->
      _id = $(e.target).attr('_id')
      Meteor.call('take', _id)
  'click .consumir': (e,t)->
      Meteor.call "consumir"

Template.workingList.events
    'click .almacenar': (e,t)->
        Meteor.call "almacenar"
    'click tr.take':(e,t)->
        _id = $(e.currentTarget).attr('_id')
        Meteor.call('take', _id)
    'keyup .number':(e,t)->
        el = $(e.target)
        value = parseFloat(el.val())
        doInput(el, value)
    'keyup .text':(e,t)->
        el = $(e.target)
        value = el.val()
        doInput(el, value)
    'click .guardar': (e,t)->
        tag = $(e.target).attr('tag')
        item = local_items.findOne({tag:tag})
        #delete item._id
        item._id = item.remote_id
        Meteor.call "GuardarItem", item
        $("input[tag='"+tag+"']").val("")
        local_items.remove({tag:tag})
    'click .edit-item': (e,t)->
        _id = $(e.target).attr('_id')
        tag = $(e.target).parent().attr('tag')
        local_items.remove({tag:tag})
        item = lista.findOne(_id:_id)
        delete item._id
        item.remote_id = _id
        local_items.insert(item)
        $("input[tag='"+tag+"']").each (index, element)->
            element = $(element)
            element.val(item[element.attr('name')])
    'click .remove-item': (e,t)->
        _id = $(e.target).attr('_id')
        Meteor.call "removeItem", _id


doInput = (el, value)->
    name = el.attr('name')
    tag = el.attr('tag')
    if not local_items.findOne({tag:tag})
        dct = {tag:tag}
        dct[name] = value
        local_items.insert(dct)
    else
        dct = {}
        dct[name] = value
        local_items.update({tag:tag}, {$set:dct})

Template.workingList.BAlmacenarVisible = ->
  if lista.find({stored:false, taken:true})
      ""
  else
      "invisible"

Template.despensa.BConsumirVisible = ->
  if lista.find({stored: true, taken:true})
    ""
  else
    "invisible"

Template.workingList.isVisible = (tag)->
    item = local_items.findOne({tag:tag})
    console.log item
    if item
        delete item._id
        delete item.remote_id
    if item and  lista.simpleSchema().namedContext('test').validate(item, {modifier:false})
        ''
    else
        console.log lista.simpleSchema().namedContext('test')
        'invisible'

Template.workingList.isTaken = (_id) ->
    item = lista.findOne(_id)
    if item and item.taken
        'taken'
    else
        ''

Template.despensa.isTaken = (_id)->
  item = lista.findOne(_id)
  if item and item.taken
    'taken'
  else
    ''
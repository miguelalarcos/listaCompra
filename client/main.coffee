local_items = new Meteor.Collection null
lista = @lista

Template.workingList.events
    'click tr.take':(e,t)->
        _id = $(e.currentTarget).attr('_id')
        Meteor.call('take', _id)
Template.workingList.events
    'blur .number':(e,t)->
        el = $(e.target)
        value = parseFloat(el.val())
        doInput(el, value)
    'blur .text':(e,t)->
        el = $(e.target)
        value = el.val()
        doInput(el, value)
    'click button': (e,t)->
        tag = $(e.target).attr('tag')
        item = local_items.findOne({tag:tag})
        delete item._id
        Meteor.call "insertItem", item
        $("input[tag='"+tag+"']").val("")

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

Template.workingList.isVisible = (tag)->
    item = local_items.findOne({tag:tag})
    if item
        delete item._id
    if item and  lista.simpleSchema().namedContext('test').validate(item, {modifier:false})
        ''
    else
        'invisible'

Template.workingList.isTaken = (_id) ->
    item = lista.findOne(_id)
    if item.taken
        'taken'
    else
        ''

Session.set 'item-selected', null

Template.listas.events
    'keyup input:not([nested])': (e,t)->
        if e.keyCode == 13
            $('.guardar').click()
    'click td.take':(e,t)->
        _id = $(e.target).attr('_id')
        Meteor.call('take', _id)
    'click .edit-item': (e,t)->
        _id = $(e.target).attr('_id')
        tag = $(e.target).parent().parent().attr('tag')
        item = lista.findOne(_id:_id)
        $("[formId='"+tag+"']").each (index, element)->
            element = $(element)
            element.val(item[element.attr('name')])

    'click .guardar': (e,t)->
        tag = $(e.target).attr('formId')
        item = {tag: tag}
        $("[formId='"+tag+"']").each (index, el)->
            el=$(el)
            if el.hasClass('number')
                value = parseFloat(el.val())
                if _.isNaN(value)
                    return
                item[el.attr('name')] = value
            else
                item[el.attr('name')] = el.val()

        if item.item
            Meteor.call "GuardarItem", item
            $("[formId='"+tag+"']").each (index, el)->
                if $(el).attr('name') != 'market'
                    $(el).val("")

    'click .remove-item': (e,t)->
        _id = $(e.target).attr('_id')
        Meteor.call "removeItem", _id

Template.itemxtag.isTaken = (_id) ->
    item = lista.findOne(_id)
    if item and item.taken
        'taken'
    else
        ''

Template.listas.rendered = ->
    $(this.findAll('.xautocomplete-tag')).xautocomplete()

Deps.autorun ->
    item = Session.get 'item-selected'
    console.log 'deps.autorun', item
    if item
        Meteor.call "GuardarItem", item

@referencias = (item)->
    item.item+', '+item.price + ', '+ item.market + ', ' + moment.unix(item.timestamp).format('DD-MM-YYYY') + ', ' + item.times
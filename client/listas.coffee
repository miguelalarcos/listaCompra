_tags_ = @tags
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
    'click .acceso-directo': (e,t)->
        _id = $(e.target).attr('_id')
        Meteor.call "CrearAccesoDirecto", _id
    'click .guardar': (e,t)->
        tag = $(e.target).attr('formId')
        item = {tag: tag}
        for el in t.findAll("[formId='"+tag+"']")
            el=$(el)
            if el.attr('name')
                if el.hasClass('number')
                    value = parseFloat(el.val())
                    if _.isNaN(value)
                        value = undefined
                    item[el.attr('name')] = value
                else
                    item[el.attr('name')] = el.val()

        if item.item
            Meteor.call "GuardarItem", item
            $("[formId='"+tag+"']").each (index, el)->
                if $(el).attr('name') != 'market'
                    if $(el).attr('name') == 'quantity'
                        $(el).val('1')
                    else
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

Template.listas.head_lista = ->
    if this.private
        'head-lista-private'
    else
        'head-lista'

Template.listas.rendered = ->
    $(this.findAll('.xautocomplete-tag')).xautocomplete()

# debe estar en un fichero llamado deps.autorun.coffee
Deps.autorun ->
    item = Session.get 'item-selected'
    if item
        if item.tag == 'mis-tiendas#market'
            ret = $(".xautocomplete-tag[formId='mis-tiendas'][name='market']").val()
            ret.push item.doc.name
            $(".xautocomplete-tag[formId='mis-tiendas'][name='market']").val(ret)
            Session.set 'item-selected', null
            return
        for t in _tags_.find({active: true}).fetch()
            if item.tag == t.tag+'#item'
                delete item.doc.email
                delete item.doc.timestamp
                delete item.doc.active
                delete item.doc.times
                Meteor.call "GuardarItem", item.doc
                break
            else if item.tag == t.tag+'#market'
                $(".xautocomplete-tag[formId='"+t.tag+"'][name='market']").val(item.doc.name)

@referencias = (item)->
    "<td><b>" + item.price + "</b></td><td>"+ item.item + '&nbsp;</td><td>'+ item.market + '&nbsp;</td><td>' + moment.unix(item.timestamp).format('DD-MM-YYYY') + '</td><td align="right"><span class=badge>' + item.times+'</span></td>'

@market = (item) -> '<td>'+item.name+'</td>'

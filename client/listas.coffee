_tags_ = @tags
Session.set 'item-selected', null
Session.set 'big-letters', true

Template.listas.events
    'click .letras-grandes': (e,t)->
        value = Session.get('big-letters')
        Session.set('big-letters', not value)
    'click .set-markets': (e,t)->
        tag = $(e.target).attr('tag')
        value = $("[formId='"+tag+"'][name='market']").val()
        Meteor.call 'SetMarkets', tag, value
    'click .seleccionar-todo': (e,t)->
        tag = $(e.target).attr('tag')
        Meteor.call "SeleccionarTodo", tag
    #'keyup input:not([nested])': (e,t)->
    'keyup input': (e,t)->
        flag1=false
        flag2=false
        it = Session.get('item-selected')
        if it and it.tag == it.doc.tag + '#item'
            flag1=true
        it = Session.get('item-selected-tab')
        if it and it.tag == it.doc.tag + '#item'
            flag2=true
        if e.keyCode == 13 and not flag1 and not flag2 and $(e.target).attr('name').split('#')[2] != 'market'
            formId=$(e.target).attr('formId_nested')
            $(".guardar[formId='"+formId+"']").click()

    'click td.take':(e,t)->
        _id = $(e.target).attr('_id')
        Meteor.call('take', _id)
    'click .edit-item': (e,t)->
        _id = $(e.target).attr('_id')
        tag = $(e.target).parent().parent().attr('tag')
        item = lista.findOne(_id:_id)
        $("[formId='"+tag+"']").each (index, element)->
            element = $(element)
            value = item[element.attr('name')]
            if element.attr('name') != 'market' or value isnt undefined
                element.val(value)

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
        $("[formId='"+tag+"'][name='item']>[nested]").focus()

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
    else if this.invited
        'head-lista-invited'
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
    Session.set 'item-selected', null

@referencias = (item)->
    "<td><b>" + item.price + "</b></td><td>"+ item.item + '&nbsp;</td><td>'+ item.market + '&nbsp;</td><td>' + moment.unix(item.timestamp).format('DD-MM-YYYY') + '</td><td align="right"><span class=badge>' + item.times+'</span></td>'

@market = (item) -> '<td>'+item.name+'</td>'

Session.set "EditInlinePrice", null
Session.set "EditInlineQuantity", null

Template.itemxtag.events
    'click .item-price': (e,t)->
        Session.set "EditInlinePrice", this._id
        Meteor.setTimeout ->
            $(e.target).children('input')[0].focus()

    'blur .item-price': (e,t)->
        Session.set "EditInlinePrice", null
        value = $(t.find(".price-inline[_id='"+this._id+"']")).val()
        if value != ''
            Meteor.call "GuardarPrecioItem", this._id, parseFloat(value)

    'click .item-quantity': (e,t)->
        Session.set "EditInlineQuantity", this._id
        Meteor.setTimeout ->
            $(e.target).children('input')[0].focus()

    'blur .item-quantity': (e,t)->
        Session.set "EditInlineQuantity", null
        value = $(t.find(".quantity-inline[_id='"+this._id+"']")).val()
        if value != ''
            Meteor.call "GuardarQuantityItem", this._id, parseFloat(value)



Template.itemxtag.edit_in_line_price = (_id, isEditable) ->
    Session.get("EditInlinePrice") == _id and isEditable

Template.itemxtag.edit_in_line_quantity = (_id, isEditable) ->
    Session.get("EditInlineQuantity") == _id and isEditable

Template.itemxtag.h2 = ->
    if Session.get('big-letters') == true
        'h2'
    else
        ''
Template.itemxtag.color_row = (tag)->
    it = _tags_.findOne(tag:tag)
    if it and it.private
        'lista-private'
    else
        ''
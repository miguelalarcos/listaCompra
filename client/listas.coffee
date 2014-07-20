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
        $("[formId='"+tag+"']").each (index, el)->
            el=$(el)
            if el.attr('name')
                if el.hasClass('number')
                    value = parseFloat(el.val())
                    if _.isNaN(value)
                        return
                    item[el.attr('name')] = value
                else
                    item[el.attr('name')] = el.val()

        if item.item
            Meteor.call "GuardarItem", item, false
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

# debe estar en un fichero llamado deps.autorun.coffee
Deps.autorun ->
    item = Session.get 'item-selected'
    console.log 'item->',item
    if item
        if item.tag == 'mis-tiendas#market'
            ret = $(".xautocomplete-tag[formId='mis-tiendas'][name='market']").val()
            ret.push item.doc.name
            $(".xautocomplete-tag[formId='mis-tiendas'][name='market']").val(ret)
            Session.set 'item-selected', null
            return
        for t in _tags_.find({active: true}).fetch()
            console.log item.tag, t.tag+'#item'
            if item.tag == t.tag+'#item'
                Meteor.call "GuardarItem", item.doc
                break
            else if item.tag == t.tag+'#market'
                $(".xautocomplete-tag[formId='"+t.tag+"'][name='market']").val(item.doc.name)

@referencias = (item)->
    "<td><b>" + item.price + "</b></td><td>"+ item.item + '&nbsp;</td><td>'+ item.market + '&nbsp;</td><td>' + moment.unix(item.timestamp).format('DD-MM-YYYY') + '</td><td align="right"><span class=badge>' + item.times+'</span></td>'

@market = (item) -> '<td>'+item.name+'</td>'

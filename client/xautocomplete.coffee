Session.set 'xquery', null
@local_items = local_items = new Meteor.Collection null
@local_tags = local_tags = new Meteor.Collection null
@xdata = xdata = new Meteor.Collection null

index = -1
current_input = null

Template.xautocomplete.helpers
    getName: ->
        this.tag + '#' + this.name
    getValue: (name) ->
        item = xdata.findOne(name:name)
        if item
            item.value
        else
            null
    init: ->
        xdata.insert({name:this.tag + '#' + this.name}) # para qué?
        value = this.value
        Meteor.setTimeout ->
            #el = $(".xautocomplete-tag[formId='"+this.formId+"'][name='"+this.name+"']")
            el = $(".xautocomplete-tag")
            el.val(value)
        null
    tags: (tag) ->
        local_tags.find({tag:tag})
    items: (call, tag,  name, funcName) -> # the items that will be shown in the popover
        query = Session.get('xquery')
        if name == current_input
            if query != ''
                Meteor.call call, query, (error, result)->
                    local_items.remove({})
                    for item, i in result
                        name = window[funcName] item
                        local_items.insert({tag:tag, name: name, index: i, remote_id: item._id, doc: item})

            local_items.find({tag:tag})
        else
            null

Template.xautocomplete.events
    'click .xitem':(e,t)->
        #el = t.find('.xautocomplete')
        name = $(t.find('.xautocomplete')).attr('name')

        index = $(e.target).attr('index')
        local_items.update({},{$set:{selected: ''}})
        local_items.update({index: parseInt(index)}, {$set:{selected: 'selected'}})

        selected = local_items.findOne selected: 'selected'

        if selected
            item = selected.doc
            item.tag = selected.tag
            delete item._id
            Session.set "item-selected", selected.doc
            console.log 'item-selected', selected.doc
        local_items.remove({})
        Session.set('xquery','')
        index = -1

    'keyup .xautocomplete': (e,t)->
        if e.keyCode == 38
            local_items.update({index:index}, {$set:{selected: ''}})
            if index == -1 then index = -1 else index -= 1
            local_items.update({index:index}, {$set:{selected: 'selected'}})
        else if e.keyCode == 40
            local_items.update({index:index}, {$set:{selected: ''}})
            count = local_items.find({}).count() - 1
            if index == count then index = 0 else index += 1
            local_items.update({index:index}, {$set:{selected: 'selected'}})
        else if e.keyCode == 13
            $(e.target).parent().find('.popover2').focus()
            if t.data.tags # tag mode

                selected = local_items.findOne(selected: 'selected') or $(e.target).val()
                value = selected.name

                if not local_tags.findOne({tag: t.data.tags, value:value})
                    local_tags.insert({tag: t.data.tags, value:value})
            else
                selected = local_items.findOne selected: 'selected'
                if selected
                    selected.doc.tag = t.data.tag
                    delete selected.doc._id
                    Session.set "item-selected", selected.doc
                    console.log 'item-selected()', selected.doc
            # close popover
            local_items.remove({})
            Session.set('xquery','')
            index = -1
        else
            Session.set 'xquery', $(e.target).val()
            current_input = $(e.target).attr('name')
    'click .xclose':(e,t)->
        val = $(e.target).attr('value')
        local_tags.remove({tag: t.data.tags, value:val})

    'blur .popover2': (e,t)->
        local_items.remove({})
        Session.set('xquery','')


$.valHooks['xautocomplete'] =
    get : (el)->
        tag = $(el).attr('tags')
        if tag
            (x.value for x in local_tags.find(tag: tag).fetch())
        else
            if $(el).attr('strict') == 'true' and $(el).find('.xautocomplete').attr('_id') == 'null'
                return null
            $(el).find('.xautocomplete').val()

    set : (el, value)->
        if _.isEqual(value, [""])
            value = []
        tag=$(el).attr('tags')
        if tag
            local_tags.remove tag:tag
            for v in value
                _id = null
                local_tags.insert tag:tag, value: v, remote_id: _id
        else
            $(el).find('.xautocomplete').val(value)
            name = $(el).attr('name')
            xdata.remove({name:name})
            xdata.insert({name:name, value:value})

$.fn.xautocomplete = ->
    this.each -> this.type = 'xautocomplete'
    this

Template.xautocomplete.rendered = ->
    $(this.findAll('.xautocomplete-tag')).xautocomplete()
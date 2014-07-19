tags = @tags

class @AdminListasController extends @LoginController
  waitOn: -> [Meteor.subscribe('mis-listas'), Meteor.subscribe("userData")]
  data: ->
        email = Meteor.users.findOne().emails[0].address
        lugar: Meteor.users.findOne().lugar or {localidad:"", provincia:""}
        listas: tags.find({email: email})
        invited: tags.find({invited: email})

Template.adminListas.events
  'click .guardar-lugar': (e,t)->
        formId = $(e.target).attr('formId')
        doc = {}
        $("input[formId='"+formId+"']").each (index, el)->
            el=$(el)
            doc[el.attr('name')] = el.val()
        Meteor.call "guardarLugar", doc
  'click .guardar-lista': (e,t)->
        formId = $(e.target).attr('formId')
        doc = {tag: formId}
        $("input[formId='"+formId+"']").each (index, el)->
            el=$(el)
            if el.hasClass('check')
                doc[el.attr('name')] = el.is(':checked')
            else
                doc[el.attr('name')] = el.val()
        Meteor.call "guardarLista", doc
  'click .append-nueva-lista': (e,t)->
        Meteor.call "insertTag", $(".input-nueva-lista").val()
  'click .ban': (e,t)->
        Meteor.call "block", $(e.target).attr('tag')
  'click .guardar-markets': (e,t)->
        Meteor.call "saveMarkets", $(t.find(".xautocomplete-tag[formId='mis-tiendas'][name='market']")).val()


Template.adminListas.isBanned = (tag)->
    tag = tags.findOne(tag:tag)
    email = Meteor.users.findOne().emails[0].address
    if email in (tag.blocked or [])
        'banned'
    else
        ''

Template.adminListas.checked = (active)->
    if active
        'checked'
    else
        ''

@tiendas = (item)->
    '<td>'+item.name+'</td>'

Template.adminListas.misTiendasValue = ->
    {value: Meteor.users.findOne(Meteor.userId()).myMarkets}



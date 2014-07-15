tags = @tags

class @AdminListasController extends @LoginController
  waitOn: -> Meteor.subscribe('mis-listas')
  data: ->
        email = Meteor.users.findOne().emails[0].address
        listas: tags.find({email: email})
        invited: tags.find({invited: email})

Template.adminListas.events
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
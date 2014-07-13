tags = @tags

class @AdminListasController extends @LoginController
  waitOn: -> Meteor.subscribe('mis-listas')
  data: ->
    listas: tags.find({})

Template.adminListas.events
  'click .guardar-lista': (e,t)->
        tag = $(e.target).attr('tag')
        doc = {tag: tag}
        $("input[tag='"+tag+"']").each (index, el)->
            el=$(el)
            doc[el.attr('name')] = el.val()
        Meteor.call "guardarLista", doc
  'click .append-nueva-lista': (e,t)->
        Meteor.call "insertTag", $(".input-nueva-lista").val()



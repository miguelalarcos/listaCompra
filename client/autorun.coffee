Session.set "item-selected-tab", null

Deps.autorun ->
    item = Session.get "item-selected-tab"
    if item
        campos = item.tag.split('#')
        formId = campos[0] + '#' + campos[1]
        name = campos[2]
        doc = {}
        doc.item = item.doc.item
        doc.tag = item.doc.tag
        $("[formId='"+formId+"'][name='"+name+"']").val("")
        $("[formId='"+formId+"'][name='"+name+"']>[nested]").focus()
        Meteor.call "GuardarItem", doc
        Session.set "item-selected-tab", null

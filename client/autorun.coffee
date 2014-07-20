Session.set "item-selected-tab", null

Deps.autorun ->
    item = Session.get "item-selected-tab"
    if item
        campos = item.tag.split('#')
        formId = campos[0] + '#' + campos[1]
        name = campos[2]
        $("[formId='"+formId+"'][name='"+name+"']").val(item.doc.item)
        $("[formId='"+formId+"'][name='"+name+"']>[nested]").focus()
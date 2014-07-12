lista = @lista
tags = @tags

is_owner_or_invited = (userId)->
    {$or : [{userId: userId}, {invited: userId}]}

Meteor.methods
    take: (_id)->
        userId = Meteor.userId()
        item = lista.findOne(_id)
        tag = item.tag
        taken = item.taken
        if tags.findOne( {$and:[{tag:tag}, {$or:[{userId:userId}, {invited: userId}]}]})
            lista.update({_id:_id}, {$set:{taken: not taken}})

    insertItem: (doc)->
        x = is_owner_or_invited(Meteor.userId())
        x['tag'] = doc.tag
        if tags.find(x)
            doc.userId = Meteor.userId()
            doc.stored = false
            doc.taken = false
            lista.insert(doc)

    insertTag: (doc)->
        doc.userId = userId
        email = Meteor.users.findOne(userId).emails[0].address
        doc.tag = doc.tag + '#' + email
        tags.insert(doc)





lista = @lista
tags = @tags

email = (userId)->
  Meteor.users.findOne(_id: userId).emails[0].address

is_owner_or_invited = (userId)->
  {$or : [{email: email(userId)}, {invited: email(userId)}]}
Meteor.methods
    guardarLista: (doc)->
        tag = tags.findOne(tag:doc.tag, email:email(Meteor.userId()))
        if tag
            tags.update({_id:tag._id}, {$set: {description: doc.descripcion, invited: doc.mails}})
    consumir: ->
        tas = (t.tag for t in tags.find(is_owner_or_invited(Meteor.userId())).fetch())
        lista.update({taken:true, stored: true, tag : {$in: tas}}, {$set: {stored: false, taken:false}})
    almacenar: ->
        tas = (t.tag for t in tags.find(is_owner_or_invited(Meteor.userId())).fetch())
        lista.update({taken:true, stored: false, tag : {$in: tas}}, {$set: {stored: true, taken:false}})
    take: (_id)->
        userId = Meteor.userId()
        item = lista.findOne(_id)
        tag = item.tag
        taken = item.taken
        if tags.findOne( {$and:[{tag:tag}, is_owner_or_invited(userId)]})
            lista.update({_id:_id}, {$set:{taken: not taken}})

    GuardarItem: (doc)->
        x = is_owner_or_invited(Meteor.userId())
        x['tag'] = doc.tag
        console.log x
        if tags.find(x)
            doc.userId = Meteor.userId()
            doc.stored = false
            doc.taken = false
            console.log doc._id
            if doc._id
              _id = doc._id
              delete doc._id
              lista.update({_id:_id}, {$set: doc})
              console.log 'update', doc
            else
              lista.insert(doc)
              console.log 'insert', doc

    insertTag: (tag)->
        #doc.userId = Meteor.userId()
        #email = Meteor.users.findOne(Meteor.userId()).emails[0].address
        doc = {}
        doc.email = email(Meteor.userId())
        doc.tag = tag + '#' + doc.email
        tags.insert(doc)

    removeItem: (_id)->
        userId = Meteor.userId()
        item = lista.findOne(_id)
        tag = item.tag
        if tags.findOne( {$and:[{tag:tag}, is_owner_or_invited(userId)]})
            lista.remove(_id)




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
            console.log tags.findOne({_id: tag._id})
    vaciar: ->
      tas = (t.tag for t in tags.find(is_owner_or_invited(Meteor.userId())).fetch())
      for doc in lista.find({taken:true, stored: true, tag : {$in: tas}}).fetch()
            delete doc._id
            delete doc.taken
            delete doc.stored
            doc.timestamp = moment().unix()
            historic.insert(doc)
      lista.remove({taken:true, stored: true, tag : {$in: tas}})
    consumir: ->
        tas = (t.tag for t in tags.find(is_owner_or_invited(Meteor.userId())).fetch())
        for doc in lista.find({taken:true, stored: true, tag : {$in: tas}}).fetch()
            delete doc._id
            delete doc.taken
            delete doc.stored
            doc.timestamp = moment().unix()
            historic.insert(doc)
        lista.update({taken:true, stored: true, tag : {$in: tas}}, {$set: {stored: false, taken:false}}, {multi:true})
    almacenar: ->
        tas = (t.tag for t in tags.find(is_owner_or_invited(Meteor.userId())).fetch())
        lista.update({taken:true, stored: false, tag : {$in: tas}}, {$set: {stored: true, taken:false}}, {multi:true})
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
        if tags.find(x)
            doc.userId = Meteor.userId()
            doc.stored = false
            doc.taken = false
            if doc._id
              _id = doc._id
              delete doc._id
              lista.update({_id:_id}, {$set: doc})
            else
              lista.insert(doc)

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




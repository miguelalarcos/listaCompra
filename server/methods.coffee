lista = @lista
tags = @tags
_market_ = @market
_item_ = @item

email = (userId)->
  Meteor.users.findOne(_id: userId).emails[0].address

is_owner_or_invited = (userId)->
  {$or : [{email: email(userId)}, {invited: email(userId)}]}

Meteor.methods
    block: (tag)->
        console.log tag, email(Meteor.userId())
        tag = tags.findOne(tag: tag, invited: email(Meteor.userId()))
        if tag
            mail = email(Meteor.userId())
            if mail in tag.blocked
                tags.update({_id:tag._id}, {$pull: {blocked: mail}})
            else
                tags.update({_id:tag._id}, {$push : {blocked: mail}})
    guardarLista: (doc)->
        tag = tags.findOne(tag:doc.tag, email:email(Meteor.userId()))
        if tag
            tags.update({_id:tag._id}, {$set: {active: doc.active, description: doc.descripcion, invited: doc.mails}})
    vaciar: ->
      tas = (t.tag for t in tags.find(is_owner_or_invited(Meteor.userId())).fetch())
      for doc in lista.find({taken:true, stored: true, tag : {$in: tas}}).fetch()
            delete doc._id
            delete doc.taken
            delete doc.stored
            historic.insert(doc)
      lista.remove({taken:true, stored: true, tag : {$in: tas}})
    consumir: ->
        tas = (t.tag for t in tags.find(is_owner_or_invited(Meteor.userId())).fetch())
        for doc in lista.find({taken:true, stored: true, tag : {$in: tas}}).fetch()
            delete doc._id
            delete doc.taken
            delete doc.stored
            historic.insert(doc)
        lista.update({taken:true, stored: true, tag : {$in: tas}}, {$set: {stored: false, taken:false}}, {multi:true})
    almacenar: ->
        tas = (t.tag for t in tags.find(is_owner_or_invited(Meteor.userId())).fetch())
        for doc in lista.find({taken:true, stored: false, tag : {$in: tas}}).fetch()
            if doc.market
                if not _market_.findOne(name:doc.market)
                    _market_.insert({name:doc.market, active: true})

                Meteor.users.update({_id: Meteor.userId()}, {$addToSet: {myMarkets: doc.market}})
                it = _item_.findOne({item: doc.item, price: doc.price, market: doc.market, active: true})
                timestamp = moment().startOf('day').unix()
                if it
                    _item_.update({_id:it._id}, {$set:{timestamp:timestamp}, $inc: {times: 1}})
                else
                    _item_.insert({email: email(Meteor.userId()), timestamp:timestamp, item: doc.item, price: doc.price, market: doc.market, active: true, times: 1})
        lista.update({taken:true, stored: false, tag : {$in: tas}}, {$set: {stored: true, taken:false, timestamp: moment().unix()}}, {multi:true})
    take: (_id)->
        userId = Meteor.userId()
        item = lista.findOne(_id)
        tag = item.tag
        taken = item.taken

        if tags.findOne( {$and:[{tag:tag}, is_owner_or_invited(userId)]})
            lista.update({_id:_id}, {$set:{taken: not taken}})
    GuardarItem: (doc)->
        console.log 'guardarDoc', doc
        if not doc
            return
        x = is_owner_or_invited(Meteor.userId())
        x['tag'] = doc.tag
        if tags.find(x)
            doc.stored = false
            doc.taken = false
            delete doc.active
            if doc._id
              _id = doc._id
              delete doc._id
              lista.update({_id:_id}, {$set: doc})
            else
              lista.insert(doc)
    insertTag: (tag)->
        doc = {}
        doc.email = email(Meteor.userId())
        doc.tag = tag + '#' + doc.email
        doc.active = true
        tags.insert(doc)
    removeItem: (_id)->
        userId = Meteor.userId()
        item = lista.findOne(_id)
        tag = item.tag
        if tags.findOne( {$and:[{tag:tag}, is_owner_or_invited(userId)]})
            lista.remove(_id)
    getItems: (query)->
        mis_tiendas = Meteor.users.findOne(Meteor.userId()).myMarkets or []
        x = _item_.find({market: {$in: mis_tiendas}, price: {$exists: true}, item: { $regex: '^.*'+query+'.*$', $options: 'i' } }, {sort: {timestamp: -1, price: +1}, limit: 20} ).fetch()
        console.log x
        x

    dummy: ->
        []

    getMarkets: (query)->
        _market_.find({active:true, name: { $regex: '^.*'+query+'.*$', $options: 'i'}}).fetch()

    saveMarkets: (markets)->
        ms = []
        for m in markets
            if _market_.findOne(name: m)
                ms.push m
        Meteor.users.update({_id: Meteor.userId()}, {$set: {myMarkets: ms}})


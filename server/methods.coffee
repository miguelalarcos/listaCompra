lista = @lista
tags = @tags
_market_ = @market
_item_ = @item
_acceso_directo_ = @accesoDirecto

email = (userId)->
  Meteor.users.findOne(_id: userId).emails[0].address

is_owner_or_invited = (userId)->
  {$or : [{email: email(userId)}, {invited: email(userId)}]}

Meteor.methods
    guardarLugar: (doc)->
        check(doc, {localidad: String, provincia: String})
        Meteor.users.update({_id: Meteor.userId()}, {$set: {lugar: doc}})
    block: (tag)->
        check(tag, String)
        tag = tags.findOne(tag: tag, invited: email(Meteor.userId()))
        if tag
            mail = email(Meteor.userId())
            if mail in tag.blocked
                tags.update({_id:tag._id}, {$pull: {blocked: mail}})
            else
                tags.update({_id:tag._id}, {$push : {blocked: mail}})
    guardarLista: (doc)->
        check(doc, {tag: String, private: Boolean, active: Boolean, description: String, mails: [String]})
        tag = tags.findOne(tag:doc.tag, email:email(Meteor.userId()))
        if tag
            tags.update({_id:tag._id}, {$set: {private: doc.private, active: doc.active, description: doc.description, invited: doc.mails}})
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
        lista.update({taken:true, stored: true, tag : {$in: tas}}, {$set: {timestamp: moment().startOf('day').unix(), stored: false, taken:false}}, {multi:true})
    almacenar: ->
        cond = {$and : [{private: false}, is_owner_or_invited(Meteor.userId())]}
        tas = (t.tag for t in tags.find(cond).fetch())
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

        tas = (t.tag for t in tags.find(is_owner_or_invited(Meteor.userId())).fetch())
        lista.update({taken:true, stored: false, tag : {$in: tas}}, {$set: {stored: true, taken:false, timestamp: moment().unix()}}, {multi:true})
    take: (_id)->
        check(_id, String)
        userId = Meteor.userId()
        item = lista.findOne(_id)
        tag = item.tag
        taken = item.taken

        if tags.findOne( {$and:[{tag:tag}, is_owner_or_invited(userId)]})
            lista.update({_id:_id}, {$set:{taken: not taken}})
    CrearAccesoDirecto: (_id)->
        check(_id, String)
        item = lista.findOne(_id)
        x = is_owner_or_invited(Meteor.userId())
        x['tag'] = item.tag
        if tags.find(x)
            if item.market and item.price and item.quantity and item.item and item.tag
                _acceso_directo_.insert({tag: item.tag, market: item.market, price: item.price, quantity: item.quantity, item: item.item})
    InsertarAccesoDirecto: (_id)->
        check(_id, String)
        ad = _acceso_directo_.findOne(_id)
        if ad
            tag = ad.tag
            x = is_owner_or_invited(Meteor.userId())
            x['tag'] = tag
            if tags.find(x)
                ad.stored = false
                ad.taken = false
                lista.insert(ad)
    RemoveAccesoDirecto: (_id)->
        check(_id, String)
        ad = _acceso_directo_.findOne(_id)
        if ad
            tag = ad.tag
            x = is_owner_or_invited(Meteor.userId())
            x['tag'] = tag
            if tags.find(x)
                _acceso_directo_.remove(_id:_id)
    GuardarItem: (doc)->
        check(doc, {tag: String, market: String, item: String, price: Number, quantity: Number, _id: Match.Optional(String)})
        if not doc
            return
        x = is_owner_or_invited(Meteor.userId())
        x['tag'] = doc.tag
        if tags.find(x)
            lugar = Meteor.users.findOne(Meteor.userId()).lugar
            if not /.*\(.*\)/.test(doc.market) and lugar
                doc.market += ' ('+lugar.localidad + ', ' + lugar.provincia+')'
            doc.stored = false
            doc.taken = false
            #delete doc.active
            if doc._id
              _id = doc._id
              delete doc._id
              lista.update({_id:_id}, {$set: doc})
            else
              lista.insert(doc)
    insertTag: (tag)->
        check(tag, String)
        doc = {}
        doc.email = email(Meteor.userId())
        doc.tag = tag + '#' + doc.email
        doc.active = true
        doc.private = false
        tags.insert(doc)
    removeItem: (_id)->
        check(_id, String)
        userId = Meteor.userId()
        item = lista.findOne(_id)
        tag = item.tag
        if tags.findOne( {$and:[{tag:tag}, is_owner_or_invited(userId)]})
            lista.remove(_id)
    getItems: (query)->
        check(query, String)
        mis_tiendas = Meteor.users.findOne(Meteor.userId()).myMarkets or []
        _item_.find({market: {$in: mis_tiendas}, price: {$exists: true}, item: { $regex: '^.*'+query+'.*$', $options: 'i' } }, {sort: {timestamp: -1, times: -1, price : +1}, limit: 20} ).fetch()

    dummy: ->
        []

    getMarkets: (query)->
        check(query, String)
        _market_.find({active:true, name: { $regex: '^.*'+query+'.*$', $options: 'i'}}).fetch()

    saveMarkets: (markets)->
        check(markets, [String])
        ms = []
        for m in markets
            if _market_.findOne(name: m)
                ms.push m
        Meteor.users.update({_id: Meteor.userId()}, {$set: {myMarkets: ms}})


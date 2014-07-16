historic_allowed = @historic_allowed
historic= @historic
lista = @lista
tags = @tags

#Meteor.publish 'historic', ->
#    historic_allowed.find({invited: this.userId})

email = (userId)->
    Meteor.users.findOne(_id: userId).emails[0].address

is_owner_or_invited = (userId)->
    mail = email(userId)
    {$or : [{email: mail}, {invited: mail}]}

not_blocked = (userId) ->
    {blocked: {$ne: email(userId)}}

is_owner_or_invited_and_not_blocked = (userId)->
    {$and: [is_owner_or_invited(userId), not_blocked(userId)]}


Meteor.publish 'tags', ->
    tags.find(is_owner_or_invited(this.userId))

Meteor.publish 'items',->
    x = tags.find(is_owner_or_invited_and_not_blocked(this.userId) ).fetch()
    tas = (t.tag for t in x when t.active)
    lista.find({tag: {$in: tas}})

Meteor.publish 'accesible_list', ->
    tags.find(is_owner_or_invited_and_not_blocked(this.userId))

Meteor.publish 'mis-listas', ->
    mail = email(this.userId)
    tags.find({$or: [{email: mail}, {invited: mail}]})

Meteor.publish 'historic',->
    x = tags.find(is_owner_or_invited_and_not_blocked(this.userId) ).fetch()
    tas = (t.tag for t in x)
    historic.find({tag: {$in: tas}},{reactive:false})

Meteor.publish "userData", ->
    Meteor.users.find({_id: this.userId}, {fields: {'myMarkets': 1}})
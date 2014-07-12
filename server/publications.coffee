historic_allowed = @historic_allowed
historic= @historic
lista = @lista
tags = @tags

#Meteor.publish 'historic', ->
#    historic_allowed.find({invited: this.userId})

email = (userId)->
    Meteor.users.findOne(_id: userId).emails[0].address

is_owner_or_invited = (userId)->
    {$or : [{email: email(userId)}, {invited: email(userId)}]}

Meteor.publish 'tags', ->
    tags.find(is_owner_or_invited(this.userId))

Meteor.publish 'items',->
    x = tags.find( is_owner_or_invited(this.userId) ).fetch()
    tas = (t.tag for t in x)
    lista.find({tag: {$in: tas}})

Meteor.publish 'accesible_list', ->
    tags.find (is_owner_or_invited(this.userId))

Meteor.publish 'mis-listas', ->
    tags.find(email: email(this.userId))




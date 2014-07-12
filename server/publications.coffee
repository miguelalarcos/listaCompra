historic_allowed = @historic_allowed
historic= @historic
lista = @lista
tags = @tags

#Meteor.publish 'historic', ->
#    historic_allowed.find({invited: this.userId})

is_owner_or_invited = (userId)->
    {$or : [{userId: userId}, {invited: userId}]}

Meteor.publish 'tags', (userId)->
    tags.find(is_owner_or_invited(userId))

Meteor.publish 'items',->
    x = tags.find( is_owner_or_invited(this.userId) ).fetch()
    tas = (t.tag for t in x)
    lista.find({tag: {$in: tas}})

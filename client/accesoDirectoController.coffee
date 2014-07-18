_acceso_directo_ = @accesoDirecto

class @AccesoDirectoController extends @LoginController
    waitOn: -> Meteor.subscribe("acceso_directo")
    data: ->
        accesos: _acceso_directo_.find().fetch()

Template.accesoDirecto.events
    'click .insertar-acceso-directo': (e,t)->
        Meteor.call 'InsertarAccesoDirecto', $(e.target).attr('_id')
    'click .remove-acceso-directo': (e,t)->
        Meteor.call 'RemoveAccesoDirecto', $(e.target).attr('_id')


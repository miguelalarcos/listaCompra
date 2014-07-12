historic = @historic
tags = @tags
lista = @lista

class LoginController extends RouteController
    onBeforeAction: ->
        if not Meteor.user() and not Meteor.loggingIn()
            @redirect 'login'

#class HistoricController extends LoginController
#    waitOn: -> Meteor.subscribe('historic')


#class ListaController extends LoginController
#    waitOn: -> [Meteor.subscribe('tags')]#, Meteor.subscribe('items')]
#    data: ->
#        listas: tags.find({invited: Meteor.userId()}) #{userId: Meteor.userId()}

class WorkingListController extends LoginController
    waitOn: ->  [Meteor.subscribe('items'), Meteor.subscribe('accesible_list')]
    data: ->
        tas = tags.find({}).fetch()
        all = lista.find({stored: false}).fetch()
        all = _.groupBy(all, (x)->x.tag)
        items: (key)->all[key]
        tags: -> (t.tag for t in tas)

class DespensaController extends LoginController
    waitOn: -> Meteor.subscribe('items')
    data: -> items: lista.find({stored: true})


class AdminListasController extends LoginController
    waitOn: -> Meteor.subscribe('mis-listas')
    data: ->
              listas: tags.find({})

Router.map ->
    @route 'login',
        path: '/login'
    @route 'home',
        path: '/'
        controller: LoginController
    @route 'workingList',
        path: '/working-list'
        controller: WorkingListController
    @route 'despensa',
        path: '/despensa'
        controller: DespensaController
    @route 'adminListas',
        path: '/admin-listas'
        controller: AdminListasController



historic = @historic
tags = @tags
lista = @lista

class LoginController extends RouteController
    onBeforeAction: ->
        if not Meteor.user() and not Meteor.loggingIn()
            @redirect 'login'

class HistoricController extends LoginController
    waitOn: -> Meteor.subscribe('historic')


class ListaController extends LoginController
    waitOn: -> [Meteor.subscribe('tags')]#, Meteor.subscribe('items')]
    data: ->
        listas: tags.find({invited: Meteor.userId()}) #{userId: Meteor.userId()}

class WorkingListController extends LoginController
    waitOn: ->  Meteor.subscribe('items', Meteor.userId())
    data: ->
        all = lista.find({}).fetch()
        all = _.groupBy(all, (x)->x.tag)
        items: (key)-> all[key]
        tags: -> _.keys(all)



Router.map ->
    @route 'login',
        path: '/login'
    @route 'home',
        path: '/'
        controller: LoginController
    @route 'historic',
        path: '/historic'
        controller: HistoricController
    @route 'lista',
        path: '/lista'
        controller: ListaController
    @route 'workingList',
        path: '/working-list'
        controller: WorkingListController




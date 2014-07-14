Router.map ->
    @route 'login',
        path: '/login'
        controller: RouteController
    @route 'home',
        path: '/'
        controller: @LoginController
    @route 'workingList',
        path: '/working-list'
        controller: @WorkingListController
    @route 'despensa',
        path: '/despensa'
        controller: @DespensaController
    @route 'adminListas',
        path: '/admin-listas'
        controller: @AdminListasController
    @route 'historic',
        path: '/historic'
        controller: @HistoricController



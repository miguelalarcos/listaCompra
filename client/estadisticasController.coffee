_historic_ = @historic

class @EstadisticasController extends @LoginController
    waitOn: -> Meteor.subscribe("historic")
    data: ->
        hist = _historic_.find().fetch()
        years: -> estadisticas_year(hist)
        months: (year)->estadisticas_month(hist, year)

estadisticas_month = (historico, year) ->
    _hist_year_month_ = {}
    for h in historico
        h.fecha = moment.unix(h.timestamp)
        h.year = h.fecha.year()
        if _.isNaN(h.year) or parseInt(year) != h.year
            continue
        h.month = h.fecha.month()
        fecha = h.fecha.startOf('month')
        it = _hist_year_month_[fecha]
        if it
            _hist_year_month_[fecha] += h.price*h.quantity
        else
            _hist_year_month_[fecha] = h.price*h.quantity

    _hist_year_month_2 = {}
    for k,v of _hist_year_month_

        _hist_year_month_2[moment(k).format('MM')] = v

    return _.sortBy(_.pairs(_hist_year_month_2), (x)->x[0])

estadisticas_year = (historico) ->
    _hist_year_ = {}
    for h in historico
        h.fecha = moment.unix(h.timestamp)
        h.year = h.fecha.year()
        if _.isNaN(h.year)
            continue

        it = _hist_year_[h.year]
        if it
            _hist_year_[h.year] += h.price*h.quantity
        else
            _hist_year_[h.year] = h.price*h.quantity

    return _.sortBy(_.pairs(_hist_year_), (x)->x[0])

#Template.estadisticas.format_month = (fecha)->
#    moment(fecha).format('MM')
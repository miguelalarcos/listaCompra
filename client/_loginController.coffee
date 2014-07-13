class @LoginController extends RouteController
  onBeforeAction: ->
    if not Meteor.user() and not Meteor.loggingIn()
      @redirect 'login'
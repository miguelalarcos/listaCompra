@market = new Meteor.Collection "Market",
    schema:
        name:
            type: String
        active:
            type: Boolean
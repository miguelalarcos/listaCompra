@historic = new Meteor.Collection "Historic",
    schema:
        item:
            type: String
        quantity:
            type: Number
        price:
            type: Number
            decimal: true
        userId:
            type: String
            optional: true
        timestamp:
            type: Number
            optional: true
        market:
            type: String
            optional: true
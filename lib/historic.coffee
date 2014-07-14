@historic = new Meteor.Collection "Historic",
    schema:
        tag:
          type: String
        item:
            type: String
        quantity:
            type: Number
            optional: true
        price:
            type: Number
            decimal: true
            optional: true
        timestamp:
            type: Number
            decimal: true
            optional: true
        market:
            type: String
            optional: true
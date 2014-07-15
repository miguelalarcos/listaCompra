@item = new Meteor.Collection "Item",
    schema:
        item:
            type: String
        active:
            type: Boolean
        price:
            type: Number
            decimal: true
            optional: true
        market:
            type: String
            optional: true
        times:
            type: Number

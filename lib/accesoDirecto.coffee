@accesoDirecto = new Meteor.Collection "AccesoDirecto",
    schema:
        tag:
            type: String
        item:
            type: String
        quantity:
            type: Number
            decimal: true
        price:
            type: Number
            decimal: true
        market:
            type: String


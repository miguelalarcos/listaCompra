@lista = new Meteor.Collection "Lista",
    schema:
        userId:
            type: String
            optional: true
        tag:
            type: String
        item:
            type: String
        taken:
            type: Boolean
            optional: true
        stored:
            type: Boolean
            optional: true
        quantity:
            type: Number
            optional: true
        price:
            type: Number
            decimal: true
            optional: true
        market:
            type: String
            optional: true

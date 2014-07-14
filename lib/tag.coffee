@tags = new Meteor.Collection "Tags",
    schema:
        email:
            type: String
            optional: true
        tag:
            type: String
        invited:
            type: [String]
            optional: true
        description:
            type: String
            optional: true
        blocked:
            type: [String]
            optional: true
        active:
            type: Boolean
            optional: true



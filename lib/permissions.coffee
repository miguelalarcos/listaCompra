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


@historic_allowed = new Meteor.Collection "Historic allowed",
    schema:
        userId:
            type: String
        invited:
            type: [String]
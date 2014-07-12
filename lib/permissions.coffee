@tags = new Meteor.Collection "Tags",
    schema:
        userId:
            type: String
            optional: true
        tag:
            type: String
        invited:
            type: [String]
            optional: true


@historic_allowed = new Meteor.Collection "Historic allowed",
    schema:
        userId:
            type: String
        invited:
            type: [String]
@messages = new Meteor.Collection "Messages",
    schema:
        userId:
            type: String
        text:
            type: String

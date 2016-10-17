# Description
#   Hubot script to listen for certain rocket.chat streamer events and respond to them.
#
# Author:
#   Gary Chapman @ 4thParty

_customRegCollection = 'stream-custom-registration'

module.exports = (robot) ->
    debugger

    robot.adapter.chatdriver.setupReactiveUsersList = (changedUserCallback) =>

        @customRegDb = robot.adapter.chatdriver.asteroid.getCollection _customRegCollection
        messageRq = @customRegDb.reactiveQuery {}

        messageRq.on "change", (id) =>
            debugger
            changedUserQuery = @customRegDb.reactiveQuery {"_id": id}
            console.log 'This changed: ', id
            console. log messageRq.result
            if changedUserQuery.result && changedUserQuery.result.length > 0

                changedUser = changedUserQuery.result[0]

                if changedUser.args?
                    changedUserCallback changedUser.args[0], changedUser.args[1]

    robot.adapter.chatdriver.prepCustomRegistrationSubscriptions = =>
        robot.logger.info "Preparing Custom Registration Subscription..."
        msgsub = robot.adapter.chatdriver.asteroid.subscribe _customRegCollection, 'customRegistrationEvent', true
        robot.logger.info "Subscribing to #{_customRegCollection}"
        return msgsub.ready

    return robot.adapter.chatdriver.prepCustomRegistrationSubscriptions()
    .catch((subErr) =>
        robot.logger.error "Unable to subscribe to activeUsers: #{JSON.stringify(subErr)} Reason: #{subErr.reason}"
        throw subErr
    )
    .then(() =>
        robot.logger.info "Successfully subscribed to custom registration messages"
        robot.adapter.chatdriver.setupReactiveUsersList (userName, regOptions) =>
            debugger
            msg = if regOptions?.skipped != true then "Thanks for completing your registration" else "You didn't complete your registration!" 

            envelope = {
                user: {
                    name: userName
                }
            }

            return robot.adapter.sendDirect(envelope, msg)
    )
    .catch((err) =>
        robot.logger.error err.message
        robot.logger.error "Unable to complete setup. See https://github.com/RocketChat/hubot-rocketchat for more info."
    )




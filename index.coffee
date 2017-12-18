# Description
#   Hubot script to listen for certain rocket.chat events and respond to them.
#
# Author:
#   Gary Chapman @ 4thParty

class Listener
    constructor: (@robot, @collectionName, @eventName, @callback) ->
        
    listen: ->
        return @prepCustomRegistrationSubscriptions()
        .catch((subErr) =>
            @robot.logger.error "Unable to subscribe to active list: #{JSON.stringify(subErr)} Reason: #{subErr.reason}"
            throw subErr
        )
        .then(() =>
            @robot.logger.info "Successfully subscribed to custom #{@collectionName}"
            @setupReactiveList()
        )
        .catch((err) =>
            @robot.logger.error err.message
            @robot.logger.error "Unable to complete setup. See https://github.com/RocketChat/hubot-rocketchat for more info."
        )

    setupReactiveList: ->
        @customRegDb = @robot.adapter.chatdriver.asteroid.getCollection @collectionName
        messageRq = @customRegDb.reactiveQuery {}

        messageRq.on "change", (id) =>
            query = @customRegDb.reactiveQuery {"_id": id}
            
            console.log messageRq.result
        
            args = query?.result?[0].args?[0]
            @callback args if args

    prepCustomRegistrationSubscriptions: ->
        msgsub = @robot.adapter.chatdriver.asteroid.subscribe @collectionName, @eventName, true
        @robot.logger.info "Subscribed to #{@collectionName}"
        return msgsub.ready

module.exports = Listener

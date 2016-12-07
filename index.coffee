# Description
#   Hubot script to listen for certain rocket.chat events and respond to them.
#
# Configuration:
#   ROCKETCHAT_USER so the bot can introduce itself using its @username
#   WELCOME_MESSAGE String, what the bot says to new users
#   DIRECT_WELCOME Bool (default true), welcome users by direct message, instead of posting in the room they joined
#   GLOBAL_WELCOME Bool (default true), welcome only once per user across all rooms, false will welcome once per room
#
# Notes:
#   TODO: Allow setting a welcome messsage by environment OR a command
#   TODO: Allow role authentication to decide who can set a new welcome message
#
# Author:
#   Gary Chapman @ 4thParty

#_customRegCollection = 'stream-custom-registration'

class Listener
	constructor: (@robot, @collectionName, @eventName, @callback) ->
    return
        
  listen: ->
      return @prepCustomRegistrationSubscriptions()
      .catch((subErr) =>
          @robot.logger.error "Unable to subscribe to active list: #{JSON.stringify(subErr)} Reason: #{subErr.reason}"
          throw subErr
      )
      .then(() =>
          @robot.logger.info "Successfully subscribed to custom registration messages"
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
          
          if query.result && query.result.length > 0

              changedUser = query.result[0]

              if changedUser.args?
                @callback changedUser?.args[0]

  prepCustomRegistrationSubscriptions: ->
      @robot.logger.info "Preparing Custom Registration Subscription..."
      msgsub = @robot.adapter.chatdriver.asteroid.subscribe @collectionName, @eventName, true
      @robot.logger.info "Subscribing to #{@collectionName}"
      return msgsub.ready

module.exports = Listener
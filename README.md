# hubot-rocketchat-listener
Allows a hubot to subscribe to a Rocket.chat streamer and react when the streamer emits events

# Usage

```
const StreamListener = require('hubot-rocketchat-listener')

const listener = new StreamListener(
    robot, // hubot instance
    'stream-user-events', // stream to listen on
    'afterCreateUser', // the particular event name we want to listen for
    (user) => { console.log(`User ${user.name} just joined`) } // callback for event
  )
  
listener.listen()
```

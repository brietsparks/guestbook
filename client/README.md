# Guestbook Client

The frontend web application for the Guestbook app. 

**To deploy to production**, follow [the production deployment steps](https://github.com/brietsparks/guestbook#deployment-and-tear-down). 

**To use locally:**
1. Ensure you have locally running Guestbook API server. See the [steps for using the server locally](https://github.com/brietsparks/guestbook/blob/master/server/README.md).
2. Install the packages. Run `yarn` or `npm install`.
3. Create an .env file
   ```
   touch .env
   ```
   And add the URL of the guestbook server
   ```
   REACT_APP_SERVER_URL=http://localhost:8000
   ```
   Note, be sure the port above matches the port you specify when running the server. 
4. Then run: `npm run start`. The webapp will run on `http://localhost:3000` by default

![Guestbook Application Demo GIF](https://raw.githubusercontent.com/brietsparks/guestbook/master/demo.gif "Guestbook Application Demo GIF")

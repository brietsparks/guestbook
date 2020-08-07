# Guestbook API Server

The backend application that serves HTTP endpoints for reading and writing comments for the Guestbook app.

**Endpoints:**
- `GET /items`: gets all comments posted by the user's IP address
- `POST /items`: creates a comment associated with the user's IP address. Expects a body: `{ value: 'string' }`

**To deploy to production**, follow [the production deployment steps](https://github.com/brietsparks/guestbook#deployment-and-tear-down). 

**To use locally:**
1. [Deploy the dev environment database](https://github.com/brietsparks/guestbook#deploy-dev-environment-infrastructure)
2. Set the following environment variables locally:
    ```
    AWS_SDK_LOAD_CONFIG=1
    AWS_PROFILE=local_dev_user_role      # the role outputted from provisioning the dev environment 
    AWS_REGION=us-west-2                 # or the region specified when provisioning
    DYNAMO_TABLE=guestbook_dev           # outputted from the provisioning
    SERVER_PORT=8000                     # whichever port you choose
    CLIENT_ORIGIN=http://localhost:3000  # should match the local client app if you plan to run both
    ```
3. Run: `go cmd/main.go`


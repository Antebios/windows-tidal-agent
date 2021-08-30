# Windows Tidal Agent

## Introduction

This is a Dockerfile that anyone can use to include the Tidal Agent for Windows to include in their own 
Windows-based container.

## Requirements

You must provide your own Windows Tidal Agent installer and name it "TAAgent.msi".

## Build the Docker image

The building of the docker image assumes this is being down on a Windows machine or Windows 2019 server.

`docker build -t tidalagent:dev .`

## Run the Docker image

`docker run -d -p 5912:5912 tidalagent:dev`

The docker logs will show:
`The Service 'TIDAL_AGENT_1' is in the 'Running' state.`

Now on your Tidal Controller you must connect to the IP address of the HOST machine and use the Port Number 5912 to connect to the Tidal Agent that is currently running.

## Make sure the Tidal Agent is running

`docker exec -it <container id or name> powershell.exe`

Then `get-service TIDAL_AGENT_1` will result with:

```
PS C:\> get-service TIDAL_AGENT_1

Status   Name               DisplayName
------   ----               -----------
Running  TIDAL_AGENT_1      TIDAL_AGENT_1
```


## Configure Tidal Agent

Using the Tidal Agent in its default configuration is fine, but should you find it necessary to 
configure the agent please look at modifying the file `C:\Program Files\TIDAL\Agent\bin\tagent.ini`

Please read Tidal's documentation on what key/value to set inside the file.



# Working with Reverse Proxy

When using Tidal Agents within containers behind a reverse proxy there has to be some configuration because the 
communication architecture is PUSH (the Controller initiates communication to the Agents).

## Traefik
This is the configuration Traefik needs to route incomming connections.  You don't have to use port 5912 but you do have to use port numbers 9999 and below.
```
...
services:
  traefik:
    image: ...
    command:
      - "--entrypoint.some-entrypoint-name-tidal.address=:5912" # Tidal's default port, but could be ANY arbitray port number 9999 and below
    ports:
      - 5912:5912 # Matches the port number used above in the entrypoint.
```

For your Windows container that needs the incoming connections for the Tidal Agent, this is the configuration for Traefik:
```
  some-service-name:
    image: ...
    ports:
      - target: 5912 # This is required and it MUST be 5912 if the agent is left as default.  It could be changed if you configured the agent differently.
    labels:
      # TIDAL connection is "HOST_IP_ADDRESS:5912" or "FQDN:5912"
      - "traefik.tcp.services.some-service-name-tidal-svc.loadbalancer.server.port=5912"
      - "traefik.tcp.routers.some-service-name-tidal-router.rule=HostSNI(`*`)"
      - "traefik.tcp.routers.some-service-name-tidal-router.entrypoints=some-entrypoint-name-tidal"
      - "traefik.tcp.routers.some-service-name-tidal-router.service=some-service-name-tidal-svc"
```

Now your Tidal Controller should be able to make a successfull connection using the host machine's IP Address or Fully Qualified Domain Name and the port number 5912.  The incoming connection is using port number 5912 and it being routed internally to the service listening on port 5912.

I could have changed Traefik's entrypoint to use port 6912 (as well as the ports section to match) and left the container target port alone at 5912.  Traefik would have routed incoming port 6912 to this container's port number 5912.  This way you can have multiple containers each with their on Tidal Agent all listening on port 5912 but configuring Traefik to route different external ports to different service (aka Containers).


# Conclusion

Let me know how this works out for you!

Thanks,
Richard Nunez

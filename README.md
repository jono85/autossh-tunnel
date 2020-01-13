# autossh-tunnel
Docker container allowing you to set up persistent SSH tunnels from your network

## usage
To use the container you need to mount a volume with config json file and private keys for the SSH connections.
Then to use the container as a proxy in your network publish the ports in your docker run command.

## example
Using the example config in source repository "config" directory, you would run the container like this:

```console
docker run \ 
	--name autossh-tunnel \ 
	--restart always \ 
	-p 5432:5432 \ 
	-p 5433:5433 \ 
	-p 3306:3306 \ 
	-v ./config:/config \ 
	-dit \ 
	jono85/autossh-tunnel:latest
```


| switch  | usage |
| ------------- | ------------- |
| --name autossh-tunnel | OPTIONAL - Tag the running container as autossh-tunnel. |
| --restart always | OPTIONAL - Restart the container if it crashes or if the docker host/service is restarted. |
| -p X:Y | OPTIONAL - Publish the container exposed ports from SSH on the docker host machine. If you want to use this container as a permanent tunnel from your network to the targets, you need to publish the ports on docker host. Otherwise these ports will only be accessible within the docker internal network. |
| -v /example/path/config:/config | MANDATORY - Bind the volume in "/example/path/config" relative path on your docker host to "/config" path inside the container. This volume must contain config.json and the private key files. |
| -dit | MANDATORY - Run container in background, create a virtual tty console and allow interactive operation (if you want to use docker attach for debugging) |

The example config assumes you have 2 SSH servers you want to use to tunnel. 
- First SSH server gives you access to two Postgres servers, you want to tunnel to port 5432 on each one of them, but publish them on ports 5432 and 5433 of the docker container. 
- Second SSH server gives you access to one MySQL server, you want to tunnel to port 3306 there.

Check the config.json example file and the settings should be self-explanatory.

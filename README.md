# nova-docker

This repository offers a reference implementation for deploying a local instance of Astrometry.net Nova frontend and backend.
While all the necessary information and steps are detailed in the `Dockerfile`, for a quick start, we've provided a high-level overview in the following instructions.
However, it's highly recommended to read the `Dockerfile` to be technically and mentally prepared for any potential issues before executing anything.
It's also beneficial to read [this GitHub issue](https://github.com/dstndstn/nova-docker/issues/1) to troubleshoot any errors during the deployment process.

1. Start by downloading the index file. Execute the command mentioned in the `Dockerfile`, which is also provided here for convenience. 
```
mkdir -p INDEXES
cd /INDEXES/ \
  && for i in 4100 4200; do \
    wget -r -l1 --no-parent -nc -nd -A ".fits" http://data.astrometry.net/$i/;\
    done
```
This process may take some time, so it's advisable to start early and continue reading the `README` file and the `Dockerfile` in the meantime.

2. Next, build the Docker image using the example command line provided. Modify according to your needs.
```
sudo docker build -t nova-docker .
```

3. Once the image is built, launch it using the example command line.
```
sudo docker run -d -p 8000:80 --mount type=bind,source=$PWD/INDEXES,target=/INDEX nova-docker
```
This command will launch a docker instance, start the backend and frontend of the Nova system, listen on port 80. And then it will map the Docker instance's 80 port to the host's 8000 port. If you are deploying in a production environment, you may want to put it as 80 instead of 8000 as well, or use a reverse proxy.

4. Lastly, make necessary changes in the code. To do this, execute the provided command line to enter the Docker image.
```
sudo docker exec -it 3581ccc20fa9 /bin/bash
```
The `3581ccc20fa9` is a hash you can find either from `sudo docker ps` or the output from the last step.
You may need to modify `/src/astrometry/net/appsecrets`, which is a simple copy of the `appsecrets-example`, to change the passwords/secrets of the database and other components. Additionally, you might need to change the `settings.py` file to include your hostname in the settings, preventing an error like 'hostname is not in the allowed host'. Here's an example, assuming you're deploying this instance to a website named example.com.
```
ALLOWED_HOSTS = ['example.com']
```
5. Then the Nova website can be accessed through http://example.com/ or http://localhost if you are deploying on localhost.

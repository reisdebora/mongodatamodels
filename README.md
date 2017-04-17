# mongodatamodels

## Building The Enviroment
This environment provides a fully sharded mongo environment using docker-compose and local storage.

The MongoDB environment consists of the following docker containers

 - **mongosrs(1-3)n(1-3)**: Mongod data server with three replica sets containing 3 nodes each (6 containers)
 - **mongocfg(1-3)**: Stores metadata for sharded data distribution (3 containers)
 - **mongos(1-2)**: Mongo routing service to connect to the cluster through (1 container)

## Installation (Debian base):

### Install Docker
	sudo apt install docker.io
    

### Install Docker-compose (1.4.2+)

	sudo apt install python-pip
	sudo pip install docker-compose

### Check out the repository

    git clone git@github.com:reisdebora/mongodatamodels.git
    cd mongodatamodels


### Setup Cluster
This will pull all the images from [Docker hub](https://hub.docker.com) and run all the containers.
Please note that you will need docker-compose 1.4.2 or better for this to work due to circular references between cluster members.
You will need to run the following *once* only to initialize all replica sets and shard data across them

    ./mongoshard.sh init

You should now be able connect to mongos1 and the new sharded cluster from the mongos container itself using the mongo shell to connect to the running mongos process

    docker exec -it mongos1 mongo --port 21017
	
### Cluster Usage
	mongoshard.sh {start|stop|restart|reset|init|status}

## Persistent storage
Data is stored at `./data/` and is excluded from version control. Data will be persistent between container runs. To remove all data `./mongoshard.sh reset`

## Built upon

 - [Docker](https://github.com/dotcloud/docker/)
 - [Mongo docker-compose](https://github.com/singram/mongo-docker-compose)
 - [Mongo Cluster Docker](https://github.com/senssei/mongo-cluster-docker)

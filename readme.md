You will need to upload a copy of wordpress to the ecr repository manually.

instructions and helpful commands can be in the aws web ui under "view push commands" button

Downlaod the latest copy of wordpress

```
docker pull wordpress:latest
```

Retrieve an authentication token and authenticate your Docker client to your registry

e.g.

```
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 055706347965.dkr.ecr.eu-west-2.amazonaws.com
```

tag the image

```
docker tag wordpress:latest {REPO_LOCATION}
```

e.g.

```
docker tag wordpress:latest 055706347965.dkr.ecr.eu-west-2.amazonaws.com/pw-101-default-ecr-repository:latest
```


push the image to the ecr repository

```
docker push {REPO_LOCATION}
```

e.g.

```
docker push 055706347965.dkr.ecr.eu-west-2.amazonaws.com/pw-101-default-ecr-repository:latest
```


access the wordpress instance via the the laod balancer

e.g.
http://pw-101-default-xdm-frontend-418861426.eu-west-2.elb.amazonaws.com/
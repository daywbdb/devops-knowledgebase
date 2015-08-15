# vagrant up

# Install docker
wget -qO- https://get.docker.com/ | sh

# start docker container
curl -o bootstrap_sandbox.sh https://raw.githubusercontent.com/DennyZhang/data/master/vagrant/bootstrap_sandbox.sh
sudo bash -xe bootstrap_sandbox.sh $IMAGE_NAME

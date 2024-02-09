Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  config.vm.disk :disk, size: "20GB", primary: true

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
    echo "vm.nr_hugepages = 512" >> /etc/sysctl.conf
    sysctl -p

    apt update

    curl https://releases.rancher.com/install-docker/20.10.sh | sh
    usermod -G docker -a vagrant

    curl -sfL https://get.k3s.io | sh -s - --docker
    
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
  SHELL
end

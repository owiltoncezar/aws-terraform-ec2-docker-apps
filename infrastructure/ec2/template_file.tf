# data "template_file" "user_data" {
#   template = <<EOF
# #!/bin/bash

# # Update packages
# sudo apt update && sudo apt upgrade -y

# # Install dependencies
# sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# # Add Docker's GPG key
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# # Add Docker repository
# echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# # Update packages again
# sudo apt update

# # Install Docker
# sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose

# # Start and enable Docker
# sudo systemctl start docker
# sudo systemctl enable docker

# # Add the current user to the docker group
# sudo usermod -aG docker ubuntu

# # Reiniciar a sessão para aplicar as alterações do grupo (opcional, dependendo do uso)
# newgrp docker

# EOF
# }

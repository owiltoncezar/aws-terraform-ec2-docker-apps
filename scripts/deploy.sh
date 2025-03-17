#!/bin/bash

# Verificar se um parâmetro foi passado
if [ -z "$1" ]; then
  echo "Uso: $0 <install|destroy>"
  exit 1
fi

# Configurações
REPO_DIR=$(dirname $(pwd))
INFRA_DIR="$REPO_DIR/infrastructure"
APP_DIR="$REPO_DIR/application"
KEY_PATH="caminho da chave privada"

# Função para instalar a infraestrutura
install_infra() {
  echo "Verificando infraestrutura com Terraform..."
  cd "$INFRA_DIR"
  terraform init
  terraform apply -auto-approve
  
  # Obter o IP público da EC2
  EC2_IP=$(terraform output -raw ec2_instance_public_ip)
  if [ -z "$EC2_IP" ]; then
    echo "Erro: Não foi possível obter o IP público da EC2."
    exit 1
  fi
  echo "IP da EC2: $EC2_IP"
  
  echo "Aguardando 60 segundos para garantir que a EC2 está pronta para conexões SSH..."
  sleep 60
  
  # Instalar Docker e dependências
  echo "Instalando Docker e configurando o ambiente..."
  ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$EC2_IP << 'EOF'
    
    sudo apt update && sudo apt upgrade -y
    
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt update
    
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose
    
    sudo systemctl start docker

    sudo systemctl enable docker
    
    sudo usermod -aG docker ubuntu
EOF

  # Reiniciar a EC2 para aplicar permissões de grupo
  echo "Reiniciando a EC2 para aplicar permissões de grupo docker..."
  ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$EC2_IP "sudo reboot"
  
  echo "Aguardando 40 segundos para a reinicialização..."
  sleep 40
  
  # Copiar a pasta app para a EC2
  echo "Copiando aplicação para a EC2..."
  scp -o StrictHostKeyChecking=no -i "$KEY_PATH" -r "$APP_DIR" ubuntu@$EC2_IP:/home/ubuntu/
  
  # Executar docker-compose na EC2
  echo "Executando docker-compose na EC2..."
  ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$EC2_IP << 'EOF'
    cd /home/ubuntu/application
    docker-compose up -d
EOF

  echo "Infraestrutura e aplicação implantadas com sucesso!"
}

# 5. Função para destruir a infraestrutura
destroy_infra() {
  echo "Destruindo infraestrutura com Terraform..."
  cd "$INFRA_DIR"
  terraform destroy -auto-approve
  echo "Infraestrutura destruída com sucesso!"
}

# 6. Executar a ação com base no parâmetro
case "$1" in
  install)
    install_infra
    ;;
  destroy)
    destroy_infra
    ;;
  *)
    echo "Parâmetro inválido. Uso: $0 <install|destroy>"
    exit 1
    ;;
esac
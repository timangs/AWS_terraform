
resource "aws_instance" "kops_ec2" {
  ami           = data.aws_ssm_parameter.latest_amzn_linux_ami.value
  instance_type = "t3.small"
  key_name      = var.key_name

  subnet_id                   = aws_subnet.my_public_sn.id
  associate_public_ip_address = true
  private_ip                  = "10.0.0.10"
  vpc_security_group_ids      = [aws_security_group.kops_ec2_sg.id]

  iam_instance_profile = aws_iam_instance_profile.kops_ec2_profile.name

  user_data = <<-EOF
#!/bin/bash

hostnamectl --static set-hostname kops-ec2

ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

echo "Updating packages and installing base tools..."
cd /root
yum update -y
yum -y install tree jq git htop wget unzip amazon-linux-extras || { echo "Failed to install base packages"; exit 1; }

export PATH=$PATH:/usr/local/bin

echo "Installing kubectl v${var.kubernetes_version}..."
curl -Lo kubectl "https://dl.k8s.io/release/v${var.kubernetes_version}/bin/linux/amd64/kubectl"
if [ $? -ne 0 ]; then echo "Error: Failed to download kubectl."; exit 1; fi
chmod +x kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
if [ $? -ne 0 ]; then echo "Error: Failed to install kubectl to /usr/local/bin/."; exit 1; fi
rm kubectl
echo "Verifying kubectl command..."
kubectl version --client || { echo "Error: kubectl command not found or not working after install."; exit 1; }
echo "kubectl installed successfully."

echo "Installing kops v1.28.7..."
curl -Lo kops https://github.com/kubernetes/kops/releases/download/v1.28.7/kops-linux-amd64
if [ $? -ne 0 ]; then echo "Error: Failed to download kops."; exit 1; fi
chmod +x kops
mv kops /usr/local/bin/kops
if [ $? -ne 0 ]; then echo "Error: Failed to move kops to /usr/local/bin/."; exit 1; fi
echo "Verifying kops command..."
kops version || { echo "Error: kops command not found or not working after install."; exit 1; }
echo "kops installed successfully."

echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
if [ $? -ne 0 ]; then echo "Error: Failed to download AWS CLI zip."; exit 1; fi
unzip awscliv2.zip >/dev/null 2>&1
./aws/install
if [ $? -ne 0 ]; then echo "Error: Failed to install AWS CLI."; exit 1; fi
rm -rf aws awscliv2.zip
echo "AWS CLI installed successfully."

echo "Configuring environment variables..."
echo "export AWS_DEFAULT_REGION=${data.aws_region.current.name}" >> /etc/profile
echo 'export AWS_PAGER=""' >> /etc/profile
echo "export ACCOUNT_ID=${data.aws_caller_identity.current.account_id}" >> /etc/profile
echo "export KUBERNETES_VERSION=${var.kubernetes_version}" >> /etc/profile
echo "export KOPS_CLUSTER_NAME=${var.cluster_base_name}" >> /etc/profile
echo "export KOPS_STATE_STORE=s3://${var.s3_state_store}" >> /etc/profile
echo 'export PATH="$PATH:/root/.krew/bin:/usr/local/bin"' >> /etc/profile

export AWS_DEFAULT_REGION=${data.aws_region.current.name}
export AWS_PAGER=""
export ACCOUNT_ID=${data.aws_caller_identity.current.account_id}
export KUBERNETES_VERSION=${var.kubernetes_version}
export KOPS_CLUSTER_NAME=${var.cluster_base_name}
export KOPS_STATE_STORE=s3://${var.s3_state_store}

echo "Verifying AWS credentials via IAM role..."
aws sts get-caller-identity || { echo "Error: Failed to get AWS caller identity. Check IAM role permissions and trust policy."; exit 1; }

echo "Generating SSH key pair..."
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa

echo "Setting up shell aliases and config..."
echo 'alias vi=vim' >> /etc/profile
echo 'sudo su -' >> /home/ec2-user/.bashrc

echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh || { echo "Failed to install Helm"; exit 1; }
rm ./get_helm.sh
echo "Helm installed successfully."

echo "Installing yh..."
wget https://github.com/andreazorzetto/yh/releases/download/v0.4.0/yh-linux-amd64.zip
unzip yh-linux-amd64.zip
mv yh /usr/local/bin/
rm yh-linux-amd64.zip
echo "yh installed successfully."

echo "Cloning PKOS repository..."
git clone https://github.com/gasida/PKOS.git /root/pkos

echo "Installing krew..."
KREW_TEMP_DIR="$(mktemp -d)"
cd "$KREW_TEMP_DIR" || exit 1
echo "Downloading krew from https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz"
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz"
if [ $? -ne 0 ]; then echo "Error: Failed to download krew tarball"; cd /root; exit 1; fi
echo "Extracting krew-linux_amd64.tar.gz"
tar zxvf "krew-linux_amd64.tar.gz"
if [ $? -ne 0 ]; then echo "Error: Failed to extract krew tarball."; cd /root; exit 1; fi
echo "Running krew installer: ./krew-linux_amd64 install krew"
"./krew-linux_amd64" install krew
KREW_INSTALL_STATUS=$?
cd /root
rm -rf "$KREW_TEMP_DIR"
if [ $KREW_INSTALL_STATUS -ne 0 ]; then echo "Krew installation failed with status $${KREW_INSTALL_STATUS}."; else echo "Krew installation seems successful."; fi

echo "Installing kube-ps1..."
echo 'source <(kubectl completion bash)' >> /etc/profile
echo 'alias k=kubectl' >> /etc/profile
echo 'complete -F __start_kubectl k' >> /etc/profile
git clone https://github.com/jonmosco/kube-ps1.git /root/kube-ps1
cat <<"EOT" >> /root/.bash_profile
source /root/kube-ps1/kube-ps1.sh
KUBE_PS1_SYMBOL_ENABLE=false
function get_cluster_short() { echo "$1" | cut -d . -f1; }
KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
KUBE_PS1_SUFFIX=') '
PS1='$(kube_ps1)'$PS1
EOT

if [ $KREW_INSTALL_STATUS -eq 0 ]; then
  echo "Installing krew plugins..."
  KREW_PLUGIN_PATH=""
  if [ -z "$KPATH" ]; then KREW_PLUGIN_PATH="/root/.krew/bin"; else KREW_PLUGIN_PATH="$KPATH"; fi
  PATH="$KREW_PLUGIN_PATH:$PATH" kubectl krew install ctx ns get-all ktop || echo "Warning: Failed to install some krew plugins."
else
  echo "Skipping krew plugin installation."
fi

echo "Installing Docker..."
amazon-linux-extras install docker -y || { echo "Failed to install Docker"; exit 1; }
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
echo "Docker installed and started."

echo "Starting kOps cluster creation process..."

echo "Checking access to kOps state store: $KOPS_STATE_STORE"
aws s3 ls $KOPS_STATE_STORE || { echo "Error: KOPS_STATE_STORE $KOPS_STATE_STORE does not exist or is not accessible via IAM role."; exit 1; }

echo "Generating kops config for cluster: ${var.cluster_base_name} using DNS Zone ID: ${data.aws_route53_zone.existing.zone_id}"
kops create cluster --name=${var.cluster_base_name} --dns-zone=${data.aws_route53_zone.existing.zone_id} \
  --zones=${var.availability_zone_1},${var.availability_zone_2} --networking amazonvpc --cloud aws \
  --master-size ${var.master_node_instance_type} --node-size ${var.worker_node_instance_type} --node-count=${var.worker_node_count} \
  --network-cidr ${var.vpc_block} --ssh-public-key ~/.ssh/id_rsa.pub --kubernetes-version "${var.kubernetes_version}" --dry-run \
  --output yaml > kops.yaml

if [ ! -f kops.yaml ] || [ ! -s kops.yaml ]; then echo "Error: Failed to generate kops.yaml or it is empty."; exit 1; fi

echo "Modifying kops.yaml to add addons and settings..."
sed -i '/^spec:/a \
  certManager:\n\
    enabled: true\n\
  awsLoadBalancerController:\n\
    enabled: true\n\
  externalDns:\n\
    provider: external-dns\n\
  metricsServer:\n\
    enabled: true\n\
  kubeProxy:\n\
    metricsBindAddress: 0.0.0.0\n\
  kubeDNS:\n\
    provider: CoreDNS\n\
    nodeLocalDNS:\n\
      enabled: true\n\
      memoryRequest: 5Mi\n\
      cpuRequest: 25m' kops.yaml
sed -i '/kubelet:/a \ \ \ \ maxPods: 100' kops.yaml
sed -i '/amazonvpc:/a \ \ \ \ env:\n\ \ \ \ - name: ENABLE_PREFIX_DELEGATION\n\ \ \ \ \ \ value: "true"' kops.yaml

echo "Adding sshPublicKey to kops.yaml spec (for reference)..."
PUB_KEY_CONTENT=$(cat /root/.ssh/id_rsa.pub)
awk -v key="  sshPublicKey: $${PUB_KEY_CONTENT}" '/^  kubernetesVersion:/ { print; print key; next } 1' kops.yaml > kops.yaml.tmp && mv kops.yaml.tmp kops.yaml
grep -q "sshPublicKey:" kops.yaml || echo "Warning: Failed to add sshPublicKey to kops.yaml spec"

echo "--- Generated kops.yaml (Final) ---"
cat kops.yaml
echo "-----------------------------------"

echo "Creating/Updating cluster configuration in S3 state store using kops.yaml..."
kops replace -f kops.yaml || { echo "Error: kops replace -f kops.yaml failed."; exit 1; }
# Note: Using 'kops replace' instead of 'kops create' ensures idempotency if config already exists

echo "Explicitly adding SSH public key secret to kOps state store..."
kops create secret sshpublickey admin -i /root/.ssh/id_rsa.pub --name ${var.cluster_base_name} --state $KOPS_STATE_STORE --yes || { echo "Error: Failed to create kops sshpublickey secret."; exit 1; }

echo "Running kops update cluster --yes --admin... This may take a significant amount of time."
kops update cluster --name ${var.cluster_base_name} --yes --admin

if [ $? -ne 0 ]; then
  echo "Error: kops update cluster failed. Check IAM role permissions (including Route 53 for ${data.aws_route53_zone.existing.zone_id}) and kOps logs (or run 'kops update cluster' manually)."
else
 echo "kops update cluster command finished successfully. Cluster provisioning initiated."
fi

echo "Adding kops export kubeconfig hint to /etc/profile..."
echo "echo 'Run: kops export kubeconfig --admin --state $KOPS_STATE_STORE' to configure kubectl" >> /etc/profile
echo "echo 'Then source /etc/profile or re-login'" >> /etc/profile

echo "UserData script finished."
EOF

  user_data_replace_on_change = true

  tags = merge(var.instance_tags, {
    Name = "kops-ec2"
  })

  depends_on = [
    aws_internet_gateway.my_igw,
    aws_iam_instance_profile.kops_ec2_profile
  ]
}

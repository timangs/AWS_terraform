#!/bin/bash
# UserData script for kops-ec2 instance (Hardcoding krew OS/Arch)

# Set hostname
hostnamectl --static set-hostname kops-ec2

# Change Timezone
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Install Packages
echo "Updating packages and installing base tools..."
cd /root
yum update -y
yum -y install tree jq git htop wget unzip amazon-linux-extras || { echo "Failed to install base packages"; exit 1; }

# Ensure /usr/local/bin is in PATH early
export PATH=$PATH:/usr/local/bin

# Install kubectl (Revised with checks)
echo "Installing kubectl v${k8s_version}..."
curl -Lo kubectl "https://dl.k8s.io/release/v${k8s_version}/bin/linux/amd64/kubectl"
if [ $? -ne 0 ]; then echo "Error: Failed to download kubectl."; exit 1; fi
chmod +x kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
if [ $? -ne 0 ]; then echo "Error: Failed to install kubectl to /usr/local/bin/."; exit 1; fi
rm kubectl # Clean up downloaded file
echo "Verifying kubectl command..."
kubectl version --client || { echo "Error: kubectl command not found or not working after install."; exit 1; }
echo "kubectl installed successfully."

# Install kops (Revised with checks)
echo "Installing kops ${kops_release_tag}..."
curl -Lo kops https://github.com/kubernetes/kops/releases/download/${kops_release_tag}/kops-linux-amd64
if [ $? -ne 0 ]; then echo "Error: Failed to download kops."; exit 1; fi
chmod +x kops
mv kops /usr/local/bin/kops
if [ $? -ne 0 ]; then echo "Error: Failed to move kops to /usr/local/bin/."; exit 1; fi
echo "Verifying kops command..."
kops version || { echo "Error: kops command not found or not working after install."; exit 1; }
echo "kops installed successfully."

# Install AWS CLI v2
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
if [ $? -ne 0 ]; then echo "Error: Failed to download AWS CLI zip."; exit 1; fi
unzip awscliv2.zip >/dev/null 2>&1
./aws/install
if [ $? -ne 0 ]; then echo "Error: Failed to install AWS CLI."; exit 1; fi
rm -rf aws awscliv2.zip
echo "AWS CLI installed successfully."

# Configure environment variables (Region, Account ID, kOps vars)
echo "Configuring environment variables..."
echo "export AWS_DEFAULT_REGION=${aws_default_region}" >> /etc/profile
echo 'export AWS_PAGER=""' >> /etc/profile
echo "export ACCOUNT_ID=${aws_account_id}" >> /etc/profile
echo "export KUBERNETES_VERSION=${k8s_version}" >> /etc/profile
echo "export KOPS_CLUSTER_NAME=${kops_cluster_name}" >> /etc/profile
echo "export KOPS_STATE_STORE=s3://${kops_state_store_bucket}" >> /etc/profile
# Add /root/.krew/bin to PATH definition for profile
echo 'export PATH="$PATH:/root/.krew/bin:/usr/local/bin"' >> /etc/profile

# Apply env vars (excluding keys) to current session for subsequent commands
export AWS_DEFAULT_REGION=${aws_default_region}
export AWS_PAGER=""
export ACCOUNT_ID=${aws_account_id}
export KUBERNETES_VERSION=${k8s_version}
export KOPS_CLUSTER_NAME=${kops_cluster_name}
export KOPS_STATE_STORE=s3://${kops_state_store_bucket}
# PATH already includes /usr/local/bin from earlier export

# Verify AWS CLI can use the IAM role
echo "Verifying AWS credentials via IAM role..."
aws sts get-caller-identity || { echo "Error: Failed to get AWS caller identity. Check IAM role permissions and trust policy."; exit 1; }

# Generate SSH key pair
echo "Generating SSH key pair..."
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa

# Shell Aliases and Config
echo "Setting up shell aliases and config..."
echo 'alias vi=vim' >> /etc/profile
echo 'sudo su -' >> /home/ec2-user/.bashrc

# Install Helm
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh || { echo "Failed to install Helm"; exit 1; }
rm ./get_helm.sh
echo "Helm installed successfully."

# Install yh
echo "Installing yh..."
wget https://github.com/andreazorzetto/yh/releases/download/v0.4.0/yh-linux-amd64.zip
unzip yh-linux-amd64.zip
mv yh /usr/local/bin/
rm yh-linux-amd64.zip
echo "yh installed successfully."

# Git Clone PKOS repo
echo "Cloning PKOS repository..."
git clone https://github.com/gasida/PKOS.git /root/pkos

# Install krew (Revised - Hardcoding linux/amd64)
echo "Installing krew..."
KREW_TEMP_DIR="$(mktemp -d)"
cd "$KREW_TEMP_DIR" || exit 1

echo "Downloading krew from https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz"
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download krew tarball from https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz"
    cd /root
    exit 1
fi

echo "Extracting krew-linux_amd64.tar.gz"
tar zxvf "krew-linux_amd64.tar.gz"
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract krew tarball."
    cd /root
    exit 1
fi

echo "Running krew installer: ./krew-linux_amd64 install krew"
"./krew-linux_amd64" install krew
KREW_INSTALL_STATUS=$? # Capture exit status

# Clean up temporary directory
cd /root
rm -rf "$KREW_TEMP_DIR"

if [ $KREW_INSTALL_STATUS -ne 0 ]; then
    # Escape the shell variable used in the echo command for Terraform
    echo "Krew installation failed with status $${KREW_INSTALL_STATUS}." # Keep $$ escape for this specific echo
    # Decide if critical; exit 1; or continue
else
    echo "Krew installation seems successful. Adding krew to PATH for current session."
    # Escape the bash parameter expansion for Terraform templatefile function
    export PATH="$${KPATH:-/root/.krew/bin}:$PATH" # Keep $$ escape here
fi

# Install kube-ps1
echo "Installing kube-ps1..."
echo 'source <(kubectl completion bash)' >> /etc/profile
echo 'alias k=kubectl' >> /etc/profile
echo 'complete -F __start_kubectl k' >> /etc/profile
git clone https://github.com/jonmosco/kube-ps1.git /root/kube-ps1
cat <<"EOT" >> /root/.bash_profile
source /root/kube-ps1/kube-ps1.sh
KUBE_PS1_SYMBOL_ENABLE=false
function get_cluster_short() {
  echo "$1" | cut -d . -f1
}
KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
KUBE_PS1_SUFFIX=') '
PS1='$(kube_ps1)'$PS1
EOT

# Install krew plugins (Check if krew install succeeded)
if [ $KREW_INSTALL_STATUS -eq 0 ]; then
  echo "Installing krew plugins..."
  # Ensure krew bin dir is in PATH for this command too
  # Escape $${KPATH...} again here
  PATH="$${KPATH:-/root/.krew/bin}:$PATH" kubectl krew install ctx ns get-all ktop || echo "Warning: Failed to install some krew plugins."
else
  echo "Skipping krew plugin installation because krew installation failed earlier."
fi


# Install Docker
echo "Installing Docker..."
amazon-linux-extras install docker -y || { echo "Failed to install Docker"; exit 1; }
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
echo "Docker installed and started."

# --- kOps Cluster Creation ---
echo "Starting kOps cluster creation process..."

# Ensure S3 bucket exists
echo "Checking access to kOps state store: $KOPS_STATE_STORE"
aws s3 ls $KOPS_STATE_STORE || { echo "Error: KOPS_STATE_STORE $KOPS_STATE_STORE does not exist or is not accessible via IAM role."; exit 1; }

# Generate kops cluster configuration YAML
echo "Generating kops config for cluster: ${kops_cluster_name} using DNS Zone ID: ${hosted_zone_id}"
kops create cluster --name=${kops_cluster_name} --dns-zone=${hosted_zone_id} \
  --zones=${kops_az1},${kops_az2} --networking amazonvpc --cloud aws \
  --master-size ${kops_master_instance_type} --node-size ${kops_worker_instance_type} --node-count=${kops_worker_node_count} \
  --network-cidr ${kops_vpc_cidr} --ssh-public-key ~/.ssh/id_rsa.pub --kubernetes-version "${k8s_version}" --dry-run \
  --output yaml > kops.yaml

if [ ! -f kops.yaml ] || [ ! -s kops.yaml ]; then # Check if file exists and is not empty
  echo "Error: Failed to generate kops.yaml or it is empty."
  exit 1
fi

# Add addons using sed
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

# Add maxPods under kubelet settings
sed -i '/kubelet:/a \ \ \ \ maxPods: 100' kops.yaml

# Enable Prefix Delegation for AWS VPC CNI
sed -i '/amazonvpc:/a \ \ \ \ env:\n\ \ \ \ - name: ENABLE_PREFIX_DELEGATION\n\ \ \ \ \ \ value: "true"' kops.yaml

echo "--- Generated kops.yaml ---"
cat kops.yaml
echo "--------------------------"

# Create the cluster configuration in the state store
echo "Creating cluster configuration in S3 state store..."
kops create -f kops.yaml || { echo "Error: kops create -f kops.yaml failed."; exit 1; }

# Apply the cluster changes
echo "Running kops update cluster --yes --admin... This may take a significant amount of time."
kops update cluster --name $KOPS_CLUSTER_NAME --yes --admin

if [ $? -ne 0 ]; then
  echo "Error: kops update cluster failed. Check IAM role permissions (including Route 53 for ${hosted_zone_id}) and kOps logs (or run 'kops update cluster' manually)."
  # Don't exit here, allow script to finish so user can debug
else
 echo "kops update cluster command finished successfully. Cluster provisioning initiated."
fi

# Add kops export kubeconfig command to profile
echo "Adding kops export kubeconfig hint to /etc/profile..."
echo "echo 'Run: kops export kubeconfig --admin --state $KOPS_STATE_STORE' to configure kubectl" >> /etc/profile
echo "echo 'Then source /etc/profile or re-login'" >> /etc/profile

echo "UserData script finished."

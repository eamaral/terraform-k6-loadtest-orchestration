#!/bin/bash
set -e

echo ""
echo "🧹 Limpando todos os diretórios Terraform..."
for dir in terraform-k6-loadtest-network terraform-k6-loadtest-cluster terraform-k6-loadtest-runner; do
  if [[ -d "$dir" ]]; then
    echo "🧼 Limpando $dir"
    rm -rf "$dir/.terraform" "$dir/.terraform.lock.hcl" "$dir/terraform.tfstate" "$dir/terraform.tfstate.backup"
  fi
done

echo ""
echo "🚀 Provisionando infraestrutura de teste de carga com k6..."

rm -f k6_infra_values.env runner.auto.tfvars

# 1. NETWORK
echo ""
echo "===== [1/3] terraform-k6-loadtest-network ====="
cd terraform-k6-loadtest-network
terraform init
terraform apply -auto-approve
NETWORK_OUTPUT=$(terraform output -json)
VPC_ID=$(echo "$NETWORK_OUTPUT" | jq -r '.vpc_id.value')
PUBLIC_SUBNETS=$(terraform output -json -no-color public_subnets | jq -c '.')
PRIVATE_SUBNETS=$(terraform output -json -no-color private_subnets | jq -c '.')

cd ..

# 2. CLUSTER
echo ""
echo "===== [2/3] terraform-k6-loadtest-cluster ====="
cd terraform-k6-loadtest-cluster
terraform init
terraform apply -auto-approve
CLUSTER_OUTPUT=$(terraform output -json)
CLUSTER_ID=$(echo "$CLUSTER_OUTPUT" | jq -r '.cluster_arn.value')
CLUSTER_NAME=$(echo "$CLUSTER_OUTPUT" | jq -r '.cluster_name.value')
cd ..

# 3. RUNNER
echo ""
echo "===== [3/3] terraform-k6-loadtest-runner ====="
cd terraform-k6-loadtest-runner
terraform init

cat <<EOF > runner.auto.tfvars
vpc_id                  = "$VPC_ID"
subnet_ids              = $PUBLIC_SUBNETS
private_subnets         = $PRIVATE_SUBNETS
cluster_name            = "$CLUSTER_NAME"
cluster_id              = "$CLUSTER_ID"
task_execution_role_arn = "arn:aws:iam::124355673305:role/ecsTaskExecutionRole"
aws_region              = "us-east-1"
EOF

terraform apply -auto-approve
cd ..

# Gerar env file
echo ""
echo "💾 Salvando variáveis em k6_infra_values.env..."
cat <<EOF > k6_infra_values.env
export VPC_ID="$VPC_ID"
export PUBLIC_SUBNETS='$PUBLIC_SUBNETS'
export PRIVATE_SUBNETS='$PRIVATE_SUBNETS'
export CLUSTER_ID="$CLUSTER_ID"
export CLUSTER_NAME="$CLUSTER_NAME"
export TASK_EXECUTION_ROLE_ARN="arn:aws:iam::124355673305:role/ecsTaskExecutionRole"
export AWS_REGION="us-east-1"
EOF

echo ""
echo "✅ Infraestrutura provisionada com sucesso!"

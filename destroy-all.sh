#!/bin/bash
set -e

echo ""
echo "💣 Destruindo infraestrutura de teste de carga com k6..."

if [ ! -f k6_infra_values.env ]; then
  echo "❌ Arquivo k6_infra_values.env não encontrado. Rode o apply-all.sh primeiro."
  exit 1
fi

source ./k6_infra_values.env

# Ordem reversa
for dir in terraform-k6-loadtest-runner terraform-k6-loadtest-cluster terraform-k6-loadtest-network; do
  echo ""
  echo "💥 Destruindo $dir..."
  cd "$dir"
  case "$dir" in
    terraform-k6-loadtest-runner)
      terraform destroy -auto-approve \
        -var="vpc_id=$VPC_ID" \
        -var="subnet_ids=$PUBLIC_SUBNETS" \
        -var="private_subnets=$PRIVATE_SUBNETS" \
        -var="cluster_name=$CLUSTER_NAME" \
        -var="cluster_id=$CLUSTER_ID" \
        -var="task_execution_role_arn=$TASK_EXECUTION_ROLE_ARN" || true
      ;;
    *)
      terraform destroy -auto-approve || true
      ;;
  esac
  cd ..
done

rm -f k6_infra_values.env

echo ""
echo "✅ Infraestrutura destruída com sucesso!"

#!/bin/sh
set -e

echo "🔧 Configurando MinIO..."
sleep 5

echo "📝 Criando alias com root user..."
mc alias set myminio $MINIO_ENDPOINT $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD

echo "📦 Criando buckets..."
mc mb myminio/$MINIO_BUCKET_JOBS --ignore-existing
mc mb myminio/$MINIO_BUCKET_OUTPUT --ignore-existing
mc mb myminio/$MINIO_BUCKET_REFS --ignore-existing
mc mb myminio/$MINIO_BUCKET_TEMP --ignore-existing

echo "⏰ Configurando lifecycle policy (auto-delete temp)..."
mc ilm add myminio/$MINIO_BUCKET_TEMP --expiry-days $MINIO_TEMP_EXPIRY_DAYS

echo "👤 Verificando se service account já existe..."
# Se access key é igual ao root user, pular criação de usuário
if [ "$MINIO_ACCESS_KEY" = "$MINIO_ROOT_USER" ]; then
  echo "⚠️  Access key é igual ao root user - usando credenciais admin"
  echo "🔐 Criando política de acesso..."
cat > /tmp/darkchannel-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::*/*",
        "arn:aws:s3:::*"
      ]
    }
  ]
}
EOF

  mc admin policy create myminio darkchannel-app-policy /tmp/darkchannel-policy.json
  
  # Só anexar política se não for root user
  if [ "$MINIO_ACCESS_KEY" != "$MINIO_ROOT_USER" ]; then
    mc admin policy attach myminio darkchannel-app-policy --user $MINIO_ACCESS_KEY
  else
    echo "⚠️  Política criada mas não anexada (usando root user)"
  fi
else
  echo "👤 Criando novo usuário..."
  mc admin user add myminio $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
  
  echo "🔐 Criando política de acesso..."
  cat > /tmp/darkchannel-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::*/*",
        "arn:aws:s3:::*"
      ]
    }
  ]
}
EOF
  
  mc admin policy create myminio darkchannel-app-policy /tmp/darkchannel-policy.json
  mc admin policy attach myminio darkchannel-app-policy --user $MINIO_ACCESS_KEY
fi

echo "✅ Setup concluído!"
echo "🔑 Service Account: $MINIO_ACCESS_KEY"
echo "📦 Buckets criados:"
echo "   - $MINIO_BUCKET_JOBS"
echo "   - $MINIO_BUCKET_OUTPUT"
echo "   - $MINIO_BUCKET_REFS"
echo "   - $MINIO_BUCKET_TEMP"

# load nvm
set -e

echo "🚀 [AfterInstall] Start"

source /etc/environment

DB_SECRET=$(aws secretsmanager get-secret-value \
--secret-id "$SECRET_NAME" \
--region ap-northeast-2 \
--query 'SecretString' \
--output text)

if [ -z "$DB_SECRET" ]; then
  echo "❌ Failed to retrieve DB secret"
  exit 1
fi

DB_USER=$(echo "$DB_SECRET" | jq -r '.username')
DB_PASS=$(echo "$DB_SECRET" | jq -r '.password')
DB_HOST=$(echo "$DB_SECRET" | jq -r '.host')
DB_PORT=$(echo "$DB_SECRET" | jq -r '.port')

export DATABASE_URL="postgres://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/postgres?schema=public"

APP_DIR="$HOME/app"
NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo "🔧 Loading nvm..."
    source "$NVM_DIR/nvm.sh"
else
    echo "❌ nvm not found at $NVM_DIR"
    exit 1
fi

if [ ! -f "$APP_DIR/.nvmrc" ]; then
  echo "❌ .nvmrc not found in $APP_DIR"
  exit 1
fi

cd "$APP_DIR"
NODE_VERSION=$(cat .nvmrc)
echo "📦 Switching to Node.js version: $NODE_VERSION"
nvm install "$NODE_VERSION";
nvm use "$NODE_VERSION" || {
  echo "❌ Failed to switch to Node.js $NODE_VERSION"
  exit 1
}

if ! command -v pnpm; then
  npm install -g pnpm@latest-10
fi

echo "📦 Installing dependencies with pnpm..."
pnpm install --frozen-lockfile
pnpm prisma generate

if ! command -v pm2; then
  npm install -g pm2
fi

echo "⚙️ Installing PM2 logrotate module..."
pm2 install pm2-logrotate

echo "⚙️ Configuring PM2 logrotate..."
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 5
pm2 set pm2-logrotate:compress true
pm2 set pm2-logrotate:dateFormat 'YYYY-MM-DD_HH-mm-ss'
pm2 set pm2-logrotate:workerInterval 30
pm2 set pm2-logrotate:rotateInterval '0 0 * * *'

echo "🚀 Starting application with PM2..."
pm2 startOrReload ecosystem.config.js

echo "🚀 [AfterInstall] Completed"
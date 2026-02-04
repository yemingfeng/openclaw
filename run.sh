#!/usr/bin/env bash
# OpenClaw Gateway 启动脚本
# 用法: ./run.sh {token}

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

# 检查参数
if [ $# -eq 0 ]; then
  fail "Usage: $0 <token>"
fi

TOKEN="$1"
LOG_FILE="${ROOT_DIR}/nohup.out"

log() { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# 1. Kill 现有 Gateway 进程
log "==> Killing existing Gateway processes..."
pkill -9 -f "openclaw gateway" || true
pkill -9 -f "node.*gateway" || true
sleep 1

# 2. 编译
log "==> Building OpenClaw..."
pnpm build

# 3. 启动 Gateway
log "==> Starting Gateway..."
log "    Token: ${TOKEN:0:10}..."
log "    Log: ${LOG_FILE}"

nohup pnpm openclaw gateway --auth token --token "${TOKEN}" --verbose > "${LOG_FILE}" 2>&1 &

# 4. 等待启动并显示日志
log "==> Waiting for Gateway to start..."
sleep 2

if pgrep -f "openclaw gateway" >/dev/null 2>&1; then
  log "✅ Gateway is running!"
  log "==> Recent logs:"
  tail -n 20 "${LOG_FILE}"
else
  fail "Gateway failed to start. Check ${LOG_FILE}"
fi

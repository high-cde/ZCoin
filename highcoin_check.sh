#!/bin/bash

echo "----------------------------------------"
echo " HIGHCOIN SYSTEM CHECK — ZDOS"
echo "----------------------------------------"

check() {
  printf "%-40s" "$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "[OK]"
  else
    echo "[FAIL]"
  fi
}

check "RPC HL0" curl -s http://localhost/rpc/view/hyper_universe/oracle_state
check "Portale Web" curl -s http://5.189.180.13
check "Z-Lang Playground" curl -s http://5.189.180.13/portal/zlang-playground.html
check "Explorer" curl -s http://5.189.180.13/portal/explorer.html
check "Dashboard" curl -s http://5.189.180.13/portal/dashboard.html
check "HL0 Console" curl -s http://5.189.180.13/portal/hl0-console.html

if systemctl is-active --quiet zdos-entity; then
  echo "Entità Discord: [ONLINE]"
else
  echo "Entità Discord: [OFFLINE]"
fi

echo "----------------------------------------"
echo " DONE."
echo "----------------------------------------"

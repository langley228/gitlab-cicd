#!/bin/sh

CONFIG_FILE="/etc/gitlab-runner/config.toml"
TEMPLATE_CONFIG="/template/template-config.toml"


if [ ! -f "$CONFIG_FILE" ] || ! grep -q '\[runners\]' "$CONFIG_FILE"; then
  echo "Runner not registered, registering..."
  until gitlab-runner register \
    --non-interactive \
    --url "https://host.docker.internal:8443/" \
    --registration-token "${GITLAB_RUNNER_TOKEN}" \
    --template-config "$TEMPLATE_CONFIG"
  do
    echo "Register failed, retrying in 5 seconds..."
    sleep 5
  done
else
  echo "Runner already registered, starting runner..."
fi

exec gitlab-runner run --user=gitlab-runner --working-directory=/home/gitlab-runner
# gitlab-cicd

本專案提供一套基於 Docker Compose 的 GitLab CE 及 GitLab Runner 部署範例，方便在本地端快速建立 CI/CD 測試環境。

## 目錄結構

- `.env`：主要環境變數（如資料目錄與 Runner Token）。
- `docker-compose.yml`：GitLab CE、PostgreSQL 及 GitLab Runner 服務定義。
- `Dockerfiles/gitlab-runner/`：自訂 Runner Dockerfile 目錄。
- `volumes/ssl/`：SSL 憑證與相關設定檔存放目錄。

## 使用方式

1. **準備環境變數**
   - 編輯 `.env` 設定 GitLab 資料目錄。

2. **產生自簽 SSL 憑證（範例指令）**
   - 請先準備 `volumes/ssl/openssl.cnf`，可自訂 SAN（Subject Alternative Name）。
   - 於專案根目錄執行以下指令產生憑證與私鑰：
     ```sh
     mkdir -p volumes/ssl
     openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
       -keyout volumes/ssl/gitlab.key \
       -out volumes/ssl/gitlab.crt \
       -config volumes/ssl/openssl.cnf
     ```
   - `openssl.cnf` 範例已提供於 `volumes/ssl/openssl.cnf`，可依需求調整。

3. **啟動 GitLab 服務（不包含 Runner）**
   ```sh
   docker-compose up -d web db
   ```

4. **瀏覽 GitLab**
   - 透過 [https://localhost:8443](https://localhost:8443) 進入 GitLab 介面。

5. **GitLab 初始登入說明**
   - 第一次登入請使用 `root` 帳號，初始密碼可透過下列指令取得：
     ```sh
     docker exec -it gitlab-ce cat /etc/gitlab/initial_root_password
     ```
   - 輸入後即可設定新密碼並開始使用。

6. **啟動 GitLab Runner**
   1. 登入 GitLab，建立一個專案（例如 `Test`）。
   2. 進入專案的 **Settings > CI/CD > Runners**，取得註冊用的 Token。
   3. 將 Token 填入 `.env` 檔案中的 `GITLAB_RUNNER_TOKEN` 變數。
   4. 確認 `volumes/template/template-config.toml` 已存在，該檔案為 Runner 的預設設定檔，會在 Runner 容器初始化時複製到 `/etc/gitlab-runner/config.toml`，可依需求調整內容。
      - `template-config.toml` 主要設定說明：
        - `concurrent`：同時允許執行的 Job 數量。
        - `check_interval`：Runner 檢查新任務的間隔秒數。
        - `[session_server]`：互動 Session 的逾時時間。
        - `[[runners]]`：Runner 註冊資訊，支援多個 Runner 設定。常用參數如下：
          - `name`：Runner 顯示名稱。
          - `url`：GitLab 伺服器網址。
          - `clone_url`：Runner clone 專案程式碼時使用的 GitLab 伺服器網址，通常與 `url` 相同。
          - `tls-ca-file`：自簽憑證路徑，確保 Runner 能安全連線 GitLab。
          - `executor`：執行方式（如 `docker`、`shell` 等）。
        - `[runners.docker]`：Docker 執行器相關設定，僅當 `executor` 設為 `docker` 時適用。常用參數如下：
          - `image`：預設 Job 執行的 Docker 映像（如 `alpine:latest`）。
          - `privileged`：是否啟用特權模式（預設 `false`）。
          - `volumes`：掛載目錄（如 `/cache`）。
          - `tls_verify`：是否驗證 TLS 憑證。
          - `disable_cache`：是否停用快取。
          - `shm_size`：/dev/shm 大小（單位：位元組）。
          - `network_mtu`：容器網路 MTU 設定。
          - 其他參數可參考官方文件。
        - 其他參數如 `oom_kill_disable`、`disable_entrypoint_overwrite` 等，可依需求調整。
      - 詳細設定可參考 [GitLab Runner 官方文件](https://docs.gitlab.com/runner/configuration/advanced-configuration.html)。
   5. 啟動 GitLab Runner：
      ```sh
      docker-compose up -d gitlab-runner
      ```
   6. 於專案的 **CI/CD > Editor** 編輯 `.gitlab-ci.yml`，可直接使用預設產生的內容進行測試。

## 注意事項

- 請自行準備 SSL 憑證於 `volumes/ssl` 目錄下，檔名需為 `gitlab.crt` 及 `gitlab.key`，否則 GitLab 服務將無法正常啟動。
- 預設帳號密碼請參考 GitLab CE 官方文件，初始 root 密碼請依上述步驟取得。
- 若需重設 GitLab 或 Runner 資料，請清除 `volumes` 目錄內容（會刪除所有資料，請小心操作）。
- 若遇到 Runner 無法註冊，請確認 `.env` 檔案中的 Token 是否正確，並重新啟動 Runner。

## 參考

- [GitLab 官方文件](https://docs.gitlab.com/omnibus/docker/)
- [GitLab Runner 官方文件](https://docs.gitlab.com/runner/)
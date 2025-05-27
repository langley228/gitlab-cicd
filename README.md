# gitlab-cicd

本專案提供一套基於 Docker Compose 的 GitLab CE 及 GitLab Runner 部署範例，方便在本地端快速建立 CI/CD 測試環境。

## 目錄結構

- `.env`：主要環境變數（如資料目錄）。
- `.env.runner`：GitLab Runner 註冊所需的 Token。
- `docker-compose.yml`：GitLab CE 與 PostgreSQL 服務定義。
- `docker-compose.runner.yml`：GitLab Runner 服務定義。
- `Dockerfiles/gitlab-runner/`：自訂 Runner Dockerfile 目錄。

## 使用方式

1. **準備環境變數**
   - 編輯 `.env` 設定 GitLab 資料目錄。
   - 編輯 `.env.runner`，填入你的 GitLab Runner Token。

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
   1. 順利登入 GitLab 後，建立一個名為 `Test` 的 Repository。
   2. 進入專案的 **Settings > CI/CD > Runners**，取得註冊用的 Token。
   3. 將 Token 填入 `.env` 檔案中的 `GITLAB_RUNNER_TOKEN` 變數。
   4. 啟動 GitLab Runner：
      ```sh
      docker-compose up -d gitlab-runner
      ```
   5. 於專案的 **CI/CD > Editor** 編輯 `.gitlab-ci.yml`，可直接使用預設產生的內容進行測試。

## 注意事項

- 請自行準備 SSL 憑證於 `volumes/ssl` 目錄下，檔名需為 `gitlab.crt` 及 `gitlab.key`，否則 GitLab 服務將無法正常啟動。
- 預設帳號密碼請參考 GitLab CE 官方文件，初始 root 密碼請依上述步驟取得。
- 若需重設 GitLab 或 Runner 資料，請清除 `volumes` 目錄內容（會刪除所有資料，請小心操作）。
- 若遇到 Runner 無法註冊，請確認 `.env` 檔案中的 Token 是否正確，並重新啟動 Runner。

## 參考

- [GitLab 官方文件](https://docs.gitlab.com/omnibus/docker/)
- [GitLab Runner 官方文件](https://docs.gitlab.com/runner/)
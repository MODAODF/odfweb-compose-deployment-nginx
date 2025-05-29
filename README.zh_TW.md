# ODFWEB 服務的容器部署（NGINX+FPM 變體）

快速地部署一個符合需求的 ODFWEB 服務（NGINX+FPM 變體）

<https://github.com/MODAODF/odfweb-compose-deployment-nginx>  
[![pre-commit 框架已引入標誌](https://img.shields.io/badge/pre--commit-已引入-brightgreen?logo=pre-commit&logoColor=white "鄙專案使用 pre-commit 框架來檢查潛在問題")](https://pre-commit.com/)

[English](README.md) 台灣中文

## 先決條件

在使用本產品前您應先滿足下列條件：

* 服務主機須已安裝近期版本之 Docker Engine（或其功能對等之）軟體。
* 在部署服務期間服務主機須有 Docker Hub 容器映像註冊服務之存取能力。

## 使用說明

參閱下列指示以將本產品部署到服務主機上：

1. 於[本產品的釋出頁](https://github.com/MODAODF/odfweb-compose-deployment-nginx/releases)下載釋出包。
1. 將釋出包上傳至服務主機上。
1. 取得服務主機的命令列界面。
1. 執行下列命令以解開產品釋出包：

    ```bash
    tar \
        --extract \
        --verbose \
        --file /path/to/odfweb-container-deployment-nginx-X.Y.Z.tar.gz
    ```

1. 執行下列命令以將作業目錄(working directory)切換到解開的產品目錄：

    ```bash
    cd /path/to/odfweb-container-deployment-nginx-X.Y.Z
    ```

1. 如果您有既有的 HTTPS 憑證的話，將它們以下列檔名安裝至 [`ssl` 子目錄](ssl/)：
    + _域名_.crt：PEM 格式之 X.509v3 完整信任鏈憑證包(full-chain certificate bundle)（即服務憑證後面有串接中繼 CA 與根 CA 憑證）。
    + _域名_.key：PEM 格式之 PKCS#8 格式私鑰。
1. 執行下列命令進行產品的初次設定：

    ```bash
    ./setup.sh
    ```

   如果您未於先前步驟提供您自己的 HTTPS 憑證該程式將會在此步驟自動生成一自簽憑證。
1. 執行下列命令以自容器映像創建服務容器並啟動服務：

    ```bash
    docker compose up -d
    ```

1. 服務現在應可透過 setup.sh 設定程序所提示之網址存取。

   如果您未於先前步驟提供一被瀏覽器信任之 HTTPS 憑證的話您需要在瀏覽器之「網站未受信任」警告畫面中將網站加入您瀏覽器的白名單。

   為了保護您的帳號安全，您應於使用者選單 > 個人設定 > 安全性 > 密碼頁面重設並妥善保存您的管理員帳號密碼。

## 維運說明

以下章節說明維護本容器化服務之有用資訊：

### 常用操作

本節說明了本服務部署相關之常用操作：

#### 啟動服務

遵循下列步驟以啟動服務：

1. 啟動一終端機。
1. 將作業目錄(working directory)切換至本文件所在目錄。
1. 執行下列命令以啟動服務：

    ```bash
    docker compose start
    ```

#### 中止服務

遵循下列步驟以中止服務運行：

1. 啟動一終端機。
1. 將作業目錄(working directory)切換至本文件所在目錄。
1. 執行下列命令以中止服務：

    ```bash
    docker compose stop
    ```

#### 重新啟動服務

遵循下列步驟以中止服務運行：

1. 啟動一終端機。
1. 將作業目錄(working directory)切換至本文件所在目錄。
1. 執行下列命令以重新啟動服務：

    ```bash
    docker compose restart
    ```

#### 調閱服務運行紀錄

遵循下列步驟以調閱服務的運行紀錄：

1. 啟動一終端機。
1. 將作業目錄(working directory)切換至本文件所在目錄。
1. 執行下列命令以調閱指定服務的運行紀錄：

    ```bash
    docker compose logs \
        --tail=100 \
        "${docker_logs_opts[@]}" \
        _Compose 服務識別名稱_
    ```

   請將 \_Compose 服務識別名稱\_ 佔位字替換為實際的服務識別名稱：

    + `app`: ODFWEB + PHP-FPM 服務。
    + `db`: MariaDB 資料庫。
    + `redis`: Redis 資料庫。
    + `web`: NGINX 反向代理服務。
    + `editor`: MODAODFWEB 文件編輯器服務。

   `docker compose logs` 命令之命令選項說明：

    + `--tail=100` ：顯示最後 100 筆運行紀錄。
    + （選用）`--follow` ：跟隨並印出新的運行紀錄至標準輸出裝置(stdout)。

#### 摧毀服務容器

遵循下列步驟以摧毀服務容器：

1. 啟動一終端機。
1. 將作業目錄(working directory)切換至本文件所在目錄。
1. 執行下列命令：

    ```bash
    docker compose down
    ```

## 參考資料

開發本產品在開發期間參考了下列資源：

* [docker/README.md at master · nextcloud/docker](https://github.com/nextcloud/docker/blob/master/README.md)  
  提供類 Nextcloud 容器映像的基本資訊。
* [docker/.examples at master · nextcloud/docker](https://github.com/nextcloud/docker/tree/master/.examples)  
  提供類 Nextcloud 容器映像 fpm 變體的 Docker Compose 參考實作。
* [mariadb - Official Image | Docker Hub](https://hub.docker.com/_/mariadb)  
  說明 MariaDB 容器映像支援的環境變數。
* [Reverse proxy settings in Nginx config (SSL termination) — Proxy settings — SDK https://sdk.collaboraonline.com/ documentation](https://sdk.collaboraonline.com/docs/installation/Proxy_settings.html#reverse-proxy-settings-in-nginx-config-ssl-termination)  
  說明如何設定相容於類 MODAODFWEB 服務之 NGINX 反向代理服務。
* [Control startup order | Docker Docs](https://docs.docker.com/compose/how-tos/startup-order/)  
  說明如何設定使服務容器在其依賴容器處於健康狀態時才啟動。
* [Using Healthcheck.sh - MariaDB Knowledge Base](https://mariadb.com/kb/en/using-healthcheck-sh/)  
  說明如何於 Compose 設定檔中檢查 MariaDB 服務容器的健康狀態。
* [Rob van Oostenrijk 的回應 | use serverinfo for docker healthcheck · Issue #676 · nextcloud/docker](https://github.com/nextcloud/docker/issues/676)  
  說明如何在 Compose 設定檔中檢查類 Nextcloud 服務容器的健康狀態。

## 授權條款

除非另有註明（個別檔案的開頭 / [REUSE.toml](https://reuse.software/spec-3.3/#reusetoml)），本產品以[第 3.0 版之 GNU Affero 通用公眾授權條款](https://www.gnu.org/licenses/agpl-3.0.en.html)（或其任意更近期之版本）釋出供大眾於授權範圍內自由使用。

本作品遵從 [REUSE 規範](https://reuse.software/spec/)，參閱 [REUSE - Make licensing easy for everyone](https://reuse.software/) 網站以了解本產品的授權相關資訊。

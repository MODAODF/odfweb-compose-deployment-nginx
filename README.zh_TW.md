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

1. 編輯 [db.env 資料庫環境設定檔](db.env)，將下列環境變數值的佔位字(`__REDACTED__`)替換為對應之適當值：
    + `MYSQL_ROOT_PASSWORD`: 「root」資料庫使用者的密碼。
    + `MYSQL_PASSWORD`: 應用服務之資料庫使用者的密碼。
1. 執行下列命令以自容器映像創建服務容器並啟動服務：

    ```bash
    docker compose up -d
    ```

## 參考資料

開發本產品在開發期間參考了下列資源：

* [docker/README.md at master · nextcloud/docker](https://github.com/nextcloud/docker/blob/master/README.md)  
  提供類 Nextcloud 容器映像的基本資訊。
* [docker/.examples at master · nextcloud/docker](https://github.com/nextcloud/docker/tree/master/.examples)  
  提供類 Nextcloud 容器映像 fpm 變體的 Docker Compose 參考實作。
* [mariadb - Official Image | Docker Hub](https://hub.docker.com/_/mariadb)  
  說明 MariaDB 容器映像支援的環境變數。

## 授權條款

除非另有註明（個別檔案的開頭 / [REUSE.toml](https://reuse.software/spec-3.3/#reusetoml)），本產品以[第 3.0 版之 GNU Affero 通用公眾授權條款](https://www.gnu.org/licenses/agpl-3.0.en.html)（或其任意更近期之版本）釋出供大眾於授權範圍內自由使用。

本作品遵從 [REUSE 規範](https://reuse.software/spec/)，參閱 [REUSE - Make licensing easy for everyone](https://reuse.software/) 網站以了解本產品的授權相關資訊。

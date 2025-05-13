# Container deployment of the ODFWEB service(NGINX+FPM variant)

Rapidly deploy a ODFWEB service(NGINX+FPM variant) that meets your requirements.

<https://github.com/MODAODF/odfweb-compose-deployment-nginx>  
[![pre-commit enabled badge](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white "This project uses pre-commit to check potential problems")](https://pre-commit.com/)

English [台灣中文](README.zh_TW.md)

## Prerequisites

The following requirements must be met in order to use this product:

* The service host must have a recent version of the Docker Engine(or its equivalent alternatives) software installed.
* During the service deployment the service host must have access to the Docker Hub registry service.

## Usage

Refer to the following instructions to deploy this product to the service host:

1. Download the release package from [the product's Releases page](https://github.com/MODAODF/odfweb-compose-deployment-nginx/releases).
1. Upload the product release package to the service host.
1. Aquire a command-line interface of the service host.
1. Run the following command to extract the product release package:

    ```bash
    tar \
        --extract \
        --verbose \
        --file /path/to/odfweb-container-deployment-nginx-X.Y.Z.tar.gz
    ```

1. Run the following command to change the working directory to the extracted product directory:

    ```bash
    cd /path/to/odfweb-container-deployment-nginx-X.Y.Z
    ```

1. Edit [the db.env database environment file](db.env), replace the following environment variable's value placeholder text(`__REDACTED__`) to their appropriate values:
    + `MYSQL_ROOT_PASSWORD`: The password of the "root" database user.
    + `MYSQL_PASSWORD`: The password fo the application service database user account.
1. Run the following command to create the container from its container image and start the service:

    ```bash
    docker compose up -d
    ```

## References

The following materials are referenced in the development of this product:

* [docker/README.md at master · nextcloud/docker](https://github.com/nextcloud/docker/blob/master/README.md)  
  Provides the basic information of the Nextcloud-like container image.
* [docker/.examples at master · nextcloud/docker](https://github.com/nextcloud/docker/tree/master/.examples)  
  Provides reference implementation of the fpm variant of the Nextcloud-like container image.
* [mariadb - Official Image | Docker Hub](https://hub.docker.com/_/mariadb)  
  Explains the supported environment variables of the MariaDB container image.
* [Reverse proxy settings in Nginx config (SSL termination) — Proxy settings — SDK https://sdk.collaboraonline.com/ documentation](https://sdk.collaboraonline.com/docs/installation/Proxy_settings.html#reverse-proxy-settings-in-nginx-config-ssl-termination)  
  Explains how to configure the NGINX reverse proxy service to make it compatible with the MODAODFWEB-like services.

## Licensing

Unless otherwise noted(individual file's header/[REUSE.toml](https://reuse.software/spec-3.3/#reusetoml)), this product is licensed under [the 3.0 version of the GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.en.html), or any of its recent versions you would prefer.

This work complies to [the REUSE Specification](https://reuse.software/spec/), refer to the [REUSE - Make licensing easy for everyone](https://reuse.software/) website for info regarding the licensing of this product.

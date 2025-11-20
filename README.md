# Compose container deployment of the ODFWEB service(NGINX+FPM variant)

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
        --file /path/to/odfweb-compose-deployment-nginx-X.Y.Z.tar.gz
    ```

1. Run the following command to change the working directory to the extracted product directory:

    ```bash
    cd /path/to/odfweb-compose-deployment-nginx-X.Y.Z
    ```

1. If you have an existing HTTPS certificate to use, install them into [the `ssl` sub-directory](ssl/) under the following names:
    + _domain name_.crt: X.509v3 full-chain certificate bundle(have the Intermediate CA and Root CA certificates appended after the end entity certificate) in PEM format.
    + _domain name_.key: PKCS#8 private key in PEM format.
1. Run the following command to setup the product:

    ```bash
    ./setup.sh
    ```

   If you don't supply your own HTTPS certificate a self-signed one will be created during this step.
1. Run the following command to create the container from its container image and start the service:

    ```bash
    docker compose up -d
    ```

1. The service is now accessible from the URL presented by the setup.sh program.

   If you didn't supply a browser-trustable HTTPS certificate in the previous step, you'll need to add the website to your browser's whitelist in the "Website not trusted" warning screen.

   For your safety, you should reset and securely store your administrative account's password via the User menu > Personal settings > Security > Password page.

## Operations

The following sections documents noteworthy information for maintaining the containerized service:

### Common operations

This section documents common operations regarding this service deployment:

#### Start the service

Refer to the following instructions to start the service:

1. Launch a text terminal.
1. Change the working directory to the directory that hosts this document.
1. Run the following commands to start the service:

    ```bash
    docker compose start
    ```

#### Stop the service

Refer to the following instructions to stop the service:

1. Launch a text terminal.
1. Change the working directory to the directory that hosts this document.
1. Run the following commands to stop the service:

    ```bash
    docker compose stop
    ```

#### Restart the service

Refer to the following instructions to restart the service:

1. Launch a text terminal.
1. Change the working directory to the directory that hosts this document.
1. Run the following commands to restart the service:

    ```bash
    docker compose restart
    ```

#### Check the service logs

Refer to the following instructions to stop the service:

1. Launch a text terminal.
1. Change the working directory to the directory that hosts this document.
1. Run the following command to check the specified service logs:

    ```bash
    docker compose logs \
        --tail=100 \
        "${docker_logs_opts[@]}" \
        _Compose service identifier_
    ```

   Please replace the \_Compose service identifier\_ placeholder to the actual service identifier:

    + `app`: ODFWEB + PHP-FPM service.
    + `db`: MariaDB database service.
    + `redis`: Redis database service.
    + `web`: NGINX reverse proxy service.
    + `editor`: MODAODFWEB document editor service.

   Explanation of the command options used in the `docker compose logs` command:

    + `--tail=100`: Show the last 100 log entries.
    + (Optional) `--follow`: Follow and print new log entries to the stdout.

#### Destroy the service container

Refer to the following instructions to destroy the service container:

1. Launch a text terminal
1. Change the working directory to the directory that hosts this document.
1. Run the following commands:

    ```bash
    docker compose down
    ```

### DESTRUCTIVE OPERATIONS

The following operations are DESTRUCTIVE and may RESULT IN DATA LOSS.  Please ensure you have a valid backup of your data before proceeding:

#### Drop all data associated with this service deployment

Refer to the following instructions to drop all data associated with this service deployment:

1. Launch a text terminal
1. Change the working directory to the directory that hosts this document.
1. [Destroy the service container](#destroy-the-service-container).
1. Run the following commands to delete all data in the named volumes:

    ```bash
    docker volume rm odfweb-nginx_{db,odfweb,redis}
    ```

1. Run the following commands _as root_ to delete all datas in the bind-mounted directories:

    ```bash
    rm -rvf {apps,config,data,theme}
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
* [Control startup order | Docker Docs](https://docs.docker.com/compose/how-tos/startup-order/)  
  Explains how to make a service container only starts when its depending container is in health state.
* [Using Healthcheck.sh - MariaDB Knowledge Base](https://mariadb.com/kb/en/using-healthcheck-sh/)  
  Explains how to check the health status of a MariaDB container in a Compose file.
* [Rob van Oostenrijk's reply | use serverinfo for docker healthcheck · Issue #676 · nextcloud/docker](https://github.com/nextcloud/docker/issues/676)  
  Explains how to check the health status of a Nextcloud-like container in a Compose file.

## Licensing

Unless otherwise noted(individual file's header/[REUSE.toml](https://reuse.software/spec-3.3/#reusetoml)), this product is licensed under [the 3.0 version of the GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.en.html), or any of its recent versions you would prefer.

This work complies to [the REUSE Specification](https://reuse.software/spec/), refer to the [REUSE - Make licensing easy for everyone](https://reuse.software/) website for info regarding the licensing of this product.

# Project template

A common project template to start of, batteries included.

<https://github.com/the-common/project-template>  
[![pre-commit enabled badge](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white "This project uses pre-commit to check potential problems")](https://pre-commit.com/)

English [台灣中文](README.zh_TW.md)

## Features

* Incorporated [EditorConfig](https://editorconfig.org) for synchronized text editor configuration between project collaborators on supported text editors/IDEs.
* Incorporated [the pre-commit framework](https://pre-commit.com) for automated potential problem checking on every commit, including but not limited to:
    + Accidental commit of security credentials/large binaries.
    + Inconsistent code indentation/line ending.
    + Shell script/Markdown/YAML docoument problems.
    + License compliance.
* Included configurations and automations for spinning up product development/testing environments with the following virtualization solutions:
    + [Docker Compose](https://docs.docker.com/compose/)  
      For workloads that can be easily containerized.
    + [Vagrant](https://www.vagrantup.com/)  
      For workloads that require full-fledged virtual machines.
* Support GitLab continuation integration(CI) for automated product building and testing.
* Support GitLab continuation delivery(CD) for automated build artifact publishing.

## How to use

1. Download a copy of the source archive from the project.
1. Extract the source archive.
1. Copy all files except of the following ones into your existing project directory:
    + .markdownlint.yml
    + README.md
1. Rename the following files or integrate their content into your existing ones:
    + real.gitattributes → .gitattributes
    + real.markdownlint.yml → .markdownlint.yml
    + real.README.md → README.md
    + real.README.zh_TW.md → README.zh_TW.md
1. (If applicable) Edit the new [README.md project README document](README.md), replace the following `_placeholders_ to the appropriate content:
    + `_project_name_`: The project's (display) name.
    + `_project_summary_`: A single-line summary of the project.
    + `_namespace_/_project_`  
      Variable portion of the project URL, if you intent to host the project on a third-party hosting service you need to manually replace the entire URL instead.
    + `_license_name_`: The name of your project's license.
    + `_license_url_`: The URL of your project's license.
1. Update the copyright holder name and year in [the REUSE.toml reuse-tool configuration file](REUSE.toml).
1. Replace the `project-name` placeholder text of the following files to your hostname-friendly project name:
    + [Vagrantfile](Vagrantfile)
    + [docker-compose.yml](docker-compose.yml)
1. Commit all changes as a new revision(commit summary for reference: `chore: Initialize new project`)

You can drop/rewrite some of the files/contents to satisfy your project's requirements.

## Licensing

Unless otherwise noted(individual file's header/[REUSE.toml](https://reuse.software/spec-3.3/#reusetoml)), this product is licensed under [MIT license](https://opensource.org/license/mit).

This work complies to [the REUSE Specification](https://reuse.software/spec/), refer to the [REUSE - Make licensing easy for everyone](https://reuse.software/) website for info regarding the licensing of this product.

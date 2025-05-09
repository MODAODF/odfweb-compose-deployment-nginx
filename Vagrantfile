# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrant environment configuration file
#
# Copyright 2025 Buo-ren Lin (OSSII) <buoren.lin@ossii.com.tw>
# SPDX-License-Identifier: MIT

Vagrant.configure("2") do |config|
  config.vm.define "test-env" do |test_env|
    # NOTE: Avoid using official box for now as their download link currently will temporary fail whenever a new release is made:
    # Issue Downloading Rocky Linux 9 Vagrant Box - Rocky Linux Tech Help - Rocky Linux Forum
    # https://forums.rockylinux.org/t/issue-downloading-rocky-linux-9-vagrant-box/16627
    #test_env.vm.box = "rockylinux/8"
    #test_env.vm.box = "generic/rocky8"
    test_env.vm.box = "bento/ubuntu-24.04"

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    test_env.vm.network "private_network", ip: "192.168.56.10"

    test_env.vm.provider "virtualbox" do |vb|
      vb.name = "project-name-test"
    end

    config.vm.provision "test-env",
      type: "shell",
      inline: "/vagrant/dev-assets/deploy-test-environment.sh",
      env: {
        "DISABLE_SELINUX" => "false",
        "DISABLE_SYSUPGRADE" => "false"
      }
  end

  # Shared folder for project file access
  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = "1024"
    vb.default_nic_type = "virtio"
  end
end

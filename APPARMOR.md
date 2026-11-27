# MODAODFWEB jail bind mounts with AppArmor

On a Ubuntu Docker host, MODAODFWEB 4.0 could start and serve WOPI discovery while logging:

```text
sh: 1: /usr/bin/modaodfwebmount: Operation not permitted
```

The editor had fallen back to building Kit jails with links and copies. A healthy container can still be using that fallback.

## Cause

MODAODFWEB first creates a user namespace and a mount namespace, then makes mount propagation recursively private. In this deployment, Docker's `docker-default` AppArmor policy denied that mount operation. MODAODFWEB fell back to calling `modaodfwebmount`, whose file capability is `cap_sys_admin=ep`. The container's capability bounding set excludes `CAP_SYS_ADMIN`, so the kernel rejected execution of the helper. The existing seccomp profile already allows the relevant execution and mount syscalls. [Docker's built-in AppArmor template](https://github.com/moby/profiles/blob/61eaf32614c7/apparmor/template.go) · [Linux capability checks at exec](https://man7.org/linux/man-pages/man7/capabilities.7.html)

The editor-specific profile allows user namespace creation and the propagation, bind-mount, and remount operations used for Kit jails. Linux grants the mount capability inside the new user namespace. MODAODFWEB then performs the mount operations internally. The editor service can keep its existing capability bounding set and seccomp profile.

## Load the profile

The repository ships [the complete AppArmor profile](apparmor.d/modaodfweb-editor). It is based on the template pinned by Docker Engine 29.8.1 and uses AppArmor ABI 4.0 for user namespace mediation. From the repository root, check the policy and install it on the **Docker host**. [Engine dependency pin](https://github.com/moby/moby/blob/464cd50/go.mod#L75) · [Docker profile loading](https://docs.docker.com/engine/security/apparmor/#load-and-unload-profiles)

```bash
apparmor_parser -Q -K apparmor.d/modaodfweb-editor
sudo install -m 0644 apparmor.d/modaodfweb-editor /etc/apparmor.d/modaodfweb-editor
sudo apparmor_parser -r -W /etc/apparmor.d/modaodfweb-editor
```

The `editor` service in [compose.yml.in](compose.yml.in) selects both policies. An existing generated `compose.yml` should have the same entries under `editor`.

```yaml
security_opt:
  - seccomp=modaodfweb-seccomp-profile.json
  - apparmor=modaodfweb-editor
```

Keep `mount_jail_tree=true` in [the server configuration](modaodfweb-config/coolwsd.xml.in). When ready to replace the running editor, recreate only that service. This interrupts open editing sessions.

```bash
sudo docker compose up -d --no-deps --force-recreate editor
```

## Verify that Kit jails use bind mounts

```bash
sudo docker compose exec -T editor cat /proc/self/attr/current
sudo docker compose logs --no-color editor | \
    grep -E 'Using Bind Mounting|Using Mount Namespaces|Kit process.*ready'
sudo docker inspect --format '{{json .HostConfig.CapAdd}}' \
    "$(sudo docker compose ps -q editor)"
```

The verified deployment showed `modaodfweb-editor (enforce)`, `Using Bind Mounting: true`, `Using Mount Namespaces: true`, and a ready Kit process. Docker reported `null` for `CapAdd`.

If either startup flag is `false`, check the host audit log for the denied operation and paths.

```bash
sudo journalctl -k --since '10 minutes ago' | \
    grep -F 'profile="modaodfweb-editor"'
```

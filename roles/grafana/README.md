# grafana

Role for installing and configuring [Grafana](https://grafana.com/). It downloads the official tarball,
configures `grafana.ini`, installs optional plugins/provisioning files, and manages the systemd service.

## Requirements

None. The role downloads Grafana directly from the configured repository.

## Role Variables

See [`defaults/main.yml`](defaults/main.yml) for the full list. Highlights:

| Variable | Default | Purpose |
| --- | --- | --- |
| `grafana_version` | `10.4.6` | Grafana release to install. |
| `grafana_install_dir` | `/opt/grafana` | Root directory for extracted binaries. |
| `grafana_config_dir` | `/etc/grafana` | Location for `grafana.ini` and provisioning assets. |
| `grafana_data_dir` | `/var/lib/grafana` | Data directory (db, plugins, etc.). |
| `grafana_ini_sections` | map | Rendered directly into `grafana.ini`. |
| `grafana_env_extra` | `{}` | Extra env vars written to `/etc/default/grafana-server`. |
| `grafana_plugins` | `[]` | Plugins to install via `grafana-cli`. |
| `grafana_provisioning_files` | `[]` | Extra provisioning assets copied under provisioning/. |

Provisioning files accept entries like:

```yaml
grafana_provisioning_files:
  - dest: dashboards/vm.json
    src: files/dashboards/vm.json
  - dest: datasources/prometheus.yml
    content: |
      apiVersion: 1
      # ...
```

## Example

```yaml
- hosts: grafana
  become: true
  roles:
    - role: grafana
      vars:
        grafana_version: "10.4.6"
        grafana_plugins:
          - grafana-piechart-panel
          - name: grafana-worldmap-panel
            version: "0.4.2"
        grafana_ini_sections:
          server:
            http_port: 4040
            domain: "dashboards.internal"
            root_url: "https://dashboards.internal/"
```

## Handlers

- `restart grafana` — restarts the Grafana systemd service.

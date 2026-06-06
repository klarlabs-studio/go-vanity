# go-vanity

Vanity import host for Klarlabs Go packages: `go.klarlabs.de/<pkg>` → `github.com/klarlabs-studio/<repo>`.

## Packages

See [`packages.tsv`](packages.tsv) — one line per package: `<import name>\t<github repo>`.

| Import path | Repository |
|---|---|
| `go.klarlabs.de/agent` | [klarlabs-studio/agent-go](https://github.com/klarlabs-studio/agent-go) |
| `go.klarlabs.de/mcp` | [klarlabs-studio/mcp-go](https://github.com/klarlabs-studio/mcp-go) |
| `go.klarlabs.de/axi` | [klarlabs-studio/axi-go](https://github.com/klarlabs-studio/axi-go) |
| `go.klarlabs.de/fortify` | [klarlabs-studio/fortify](https://github.com/klarlabs-studio/fortify) |
| `go.klarlabs.de/statekit` | [klarlabs-studio/statekit](https://github.com/klarlabs-studio/statekit) |
| `go.klarlabs.de/bolt` | [klarlabs-studio/bolt](https://github.com/klarlabs-studio/bolt) |
| `go.klarlabs.de/mnemos` | [klarlabs-studio/mnemos](https://github.com/klarlabs-studio/mnemos) |
| `go.klarlabs.de/scout` | [klarlabs-studio/scout](https://github.com/klarlabs-studio/scout) |
| `go.klarlabs.de/coverctl` | [klarlabs-studio/coverctl](https://github.com/klarlabs-studio/coverctl) |
| `go.klarlabs.de/briefkasten` | [klarlabs-studio/briefkasten](https://github.com/klarlabs-studio/briefkasten) |
| `go.klarlabs.de/nomi` | [klarlabs-studio/nomi](https://github.com/klarlabs-studio/nomi) |

## How it works

Each package path serves an HTML page with `go-import` / `go-source` meta tags
(any subpath, including `/v2`-style major suffixes, resolves to the same page).
Humans get redirected to pkg.go.dev.

- `generate.sh` — renders `public/` and `nginx-default.conf` from `packages.tsv`
- `k8s/manifests.yaml` — namespace `klarlabs`: nginx-unprivileged Deployment (content + nginx config from ConfigMaps), Service, traefik Ingress with cert-manager TLS (`letsencrypt-prod`)
- `deploy.sh` — regenerate + apply manifests + refresh ConfigMaps + rollout restart

## Adding a package

1. Add a line to `packages.tsv`
2. Run `./deploy.sh`

## DNS

`go.klarlabs.de` points at the edge-light node:

```
go.klarlabs.de.  A     204.168.201.232
go.klarlabs.de.  AAAA  2a01:4f9:c015:8386::1
```

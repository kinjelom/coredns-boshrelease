## CoreDNS BOSH Release

BOSH release packaging [CoreDNS](https://coredns.io/) compiled with the
[`recursor` plugin](https://github.com/kinjelom/coredns-recursor).
Component versions are listed in [`src/meta-info/blobs-versions.env`](src/meta-info/blobs-versions.env).

This repository covers only the BOSH side: packaging, job templates, lifecycle and configuration delivery.
For what the `recursor` plugin does and how to configure it (resolvers, aliases, syntax, use case),
see the [plugin documentation](https://github.com/kinjelom/coredns-recursor#readme).

### Jobs

- `coredns` - runs the CoreDNS server under [BPM](https://github.com/cloudfoundry/bpm-release)
  (the `bpm` job must be colocated in the deployment manifest).
- `check-coredns` - errand that verifies the running server returns the control serial
  stored in the rendered configuration; it can be run at any time.

### Configuration

- `coredns.config.main.blocks` - list of Corefile server blocks rendered into the main `Corefile`.
- `coredns.config.external.files` - additional files (`yaml` or `text`) written to
  `coredns.config.external.directory`, e.g. external `recursor` configs or zone files referenced from the blocks.
- `coredns.dns_port`, `coredns.env`, `coredns.monit.additional_entries` - see [`jobs/coredns/spec`](jobs/coredns/spec).

### Configuration verification

A dedicated control zone is used to verify that the DNS server has loaded the latest configuration.
During template rendering, a serial number is generated from the current date and time.
The `post-start` script queries this serial from the DNS server and compares it with the expected value,
which ensures the new configuration is active.

You can disable this check with: `coredns.config.verify_control_serial_post_start: false`

### Deployment
```yaml
---
name: ((deployment_name))

instance_groups:
- name: coredns
  azs: [z1, z2, z3]
  instances: 1
  vm_type: default
  stemcell: default
  networks: [name: default]
  jobs:
  - name: coredns
    release: coredns
  - name: bpm
    release: bpm

releases:
- name: coredns
  version: latest
- name: bpm
  version: latest

stemcells:
- alias: default
  os: ubuntu-jammy
  version: latest

update:
  canaries: 1
  canary_watch_time: 30000-1200000
  max_in_flight: 1
  serial: false
  update_watch_time: 5000-1200000

```

The ops file below only shows how to wire a `recursor` block and its external YAML config into the job properties
(full example: [`example/manifests/ops/ops-demo.yml`](example/manifests/ops/ops-demo.yml)).
For the meaning of the `recursor` options, refer to the [plugin documentation](https://github.com/kinjelom/coredns-recursor#readme).

```yaml
---
- type: replace
  path: /instance_groups/name=coredns/jobs/name=coredns/properties?/coredns?/config?/main?/blocks?/-
  value: |+
    demo.svc. {
      recursor {
        external-yaml /var/vcap/jobs/coredns/config/external/demo.svc.yaml
        verbose 1
      }
      log
      errors
    }

- type: replace
  path: /instance_groups/name=coredns/jobs/name=coredns/properties?/coredns?/config?/external?/files?/-
  value:
    name: demo.svc.yaml
    yaml:
      resolvers:
        dns-c:
          urls: [ udp://1.1.1.1:53, udp://1.0.0.1:53 ]
      aliases:
        "*-lb":
          ips: [ 10.0.0.50, 10.0.0.51 ]
        "*":
          resolver_name: dns-c
          ttl: 15
```

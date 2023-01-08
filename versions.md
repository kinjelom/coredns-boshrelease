# Coredns BOSH Release Versions

<details>
  <summary>coredns / 1.0.0</summary>

You can reference this release in your deployment manifest from the `releases` section:
```yaml
- name: "coredns"
  version: "1.0.0"
  url: "https://.../coredns-boshrelease-1.0.0.tgz"
  sha1: "4f700866c95eeeb86c120fce2837f5cbd60056a8"
```
Or upload it to your director with the `upload-release` command:
```
bosh upload-release --sha1 4f700866c95eeeb86c120fce2837f5cbd60056a8 \
  https://.../coredns-boshrelease-1.0.0.tgz
```
</details>

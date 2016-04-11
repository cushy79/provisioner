aws-ec2-provisioner
=====

概要
-----

Amazon LinuxベースのAMIをPacker+Ansibleで構築し、
EC2 Run Commandにより継続的にAMIをアップデートする。

インストール
-----

### Packer

```
$ brew install packer
$ packer --version
0.8.6
```

設定
-----

```
$ vim variables/secrets.json
{
  "aws_access_key": <アクセスキー>
  "aws_secret_key": <シークレットキー>
}
```

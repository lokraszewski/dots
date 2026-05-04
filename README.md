# dots

## First time setup

```sh
bw login
bw unlock
export BW_SESSION="your-session-token"
```

## Get vault password from `Bitwarden`

```sh
ansible-playbook site.yml --vault-password-file=<(bw get password ansible-vault)
```


## TODO:
* [ ] setup inventory to work with pc, work and a remote server.
* [ ] support local config and remote. 



<!-- 

To encrypt a file:
ansible-vault encrypt inventory/host_vars/foo.yml
 -->
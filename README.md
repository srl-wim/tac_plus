# TACACS+ Docker Image

This image is a built version of tac_plus, a TACACS+ implementation written by Marc Huber.

## Building the image

Note: this image is not meant for production use, it was build to help people understand the SR-linux tacacs implementation.
Build/Tag:
```
make all
make tag
```
Push image to docker hub
```
docker push henderiw/tacacs-plus-alpine:1.0.0
```

## Run the image from docker hub

When you are happy with the tac_plus.cfg configuration example, you can use the image with the default tacacs configuration
```
docker run --name tac_plus -d -p 49:49 --network host henderiw/tacacs-plus-alpine:1.0.0
```

When you want to upload your own configuration, you can volume mount your specific tacacs configuration 
Example: below
```
docker run --name tac_plus -d -p 49:49 --network host -v ~/tac_plus/tac_plus.cfg:/etc/tac_plus/tac_plus.cfg henderiw/tacacs-plus-alpine:1.0.0
```

When you run the image in a different bridge you might have to extend some iptables rules to allow communication between the SRL container and the atc_plus container.

```
sudo iptables -I DOCKER-USER -i srlinux-mgmt -o docker0 -j ACCEPT
sudo iptables -I DOCKER-USER -i docker0 -o srlinux-mgmt -j ACCEPT
sudo iptables -t nat -I POSTROUTING 1 -o srlinux-mgmt -s 172.17.0.0/16 -j ACCEPT
sudo iptables -t nat -I POSTROUTING 1 -o docker0 -s 10.1.1.0/24 -j ACCEPT
sudo iptables -t nat -I POSTROUTING 1 -o srlinux-mgmt -s 10.1.1.0/24 -j ACCEPT
```

## Example configuration on SRL

We configured 3 servers: 2 ipv4 and 1 ipv6 for both authorization and accounting

```
--{ candidate shared }--[ system aaa ]--
A:ist1-dc-fab-f1p1-leaf1# info
    authentication {
        exit-on-reject false
        authentication-method [
            tac_plus
            local
        ]
    }
    accounting {
        accounting-method [
            tac_plus
            local
        ]
        event command {
            record start-stop
        }
    }
    server-group local {
        timeout 10
    }
    server-group tac_plus {
        timeout 2
        server 10.1.1.10 {
            name tac_plus
            network-instance mgmt
            tacacs {
                port 49
                secret-key $aes$a97cpXsHbYuU=$rAqajiK1tvAdc1FREJ8RcA==
            }
        }
        server 172.17.0.2 {
            name tac_plus
            network-instance mgmt
            tacacs {
                port 49
                secret-key $aes$a97cpXsHbYuU=$rAqajiK1tvAdc1FREJ8RcA==
            }
        }
        server 2001:10:1:1::a {
            name tac_plus
            network-instance mgmt
            tacacs {
                port 49
                secret-key $aes$a97cpXsHbYuU=$rAqajiK1tvAdc1FREJ8RcA==
            }
        }
    }
```

## Example login and logging information

Login example:
```
ssh hans@10.1.1.2
hans@10.1.1.2's password:
Last login: Fri Jul 17 18:01:55 2020 from 10.1.1.1
Using configuration file '/etc/opt/srlinux/srlinux.rc'
Welcome to the srlinux CLI.
Type 'help' (and press <ENTER>) if you need any help using this.
--{ running }--[  ]--
```

Logging exmple:
```
docker logs tac_plus
Starting server...
2020-07-17 17:41:26 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=129	timezone=UTC	service=shell	priv-lvl=15	cmd=commit stay
2020-07-17 17:42:01 +0000	10.1.1.2	admin	ssh	10.1.1.1	start	task_id=130	timezone=UTC	service=shell	priv-lvl=15	cmd=info
2020-07-17 17:42:01 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=130	timezone=UTC	service=shell	priv-lvl=15	cmd=info
2020-07-17 17:42:11 +0000	10.1.1.2	admin	ssh	10.1.1.1	start	task_id=131	timezone=UTC	service=shell	priv-lvl=15	cmd=info from state
2020-07-17 17:42:11 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=131	timezone=UTC	service=shell	priv-lvl=15	cmd=info from state
2020-07-17 17:42:17 +0000	10.1.1.2	admin	ssh	10.1.1.1	start	task_id=132	timezone=UTC	service=shell	priv-lvl=15	cmd=exit
2020-07-17 17:42:17 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=132	timezone=UTC	service=shell	priv-lvl=15	cmd=exit
2020-07-17 17:42:19 +0000	10.1.1.2	admin	ssh	10.1.1.1	start	task_id=133	timezone=UTC	service=shell	priv-lvl=15	cmd=info from state
2020-07-17 17:42:19 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=133	timezone=UTC	service=shell	priv-lvl=15	cmd=info from state
2020-07-17 17:57:25 +0000	10.1.1.2	admin	ssh	10.1.1.1	start	task_id=134	timezone=UTC	service=shell	priv-lvl=15	cmd=info
2020-07-17 17:57:25 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=134	timezone=UTC	service=shell	priv-lvl=15	cmd=info
2020-07-17 17:57:28 +0000	10.1.1.2	admin	ssh	10.1.1.1	start	task_id=135	timezone=UTC	service=shell	priv-lvl=15	cmd=back
2020-07-17 17:57:28 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=135	timezone=UTC	service=shell	priv-lvl=15	cmd=back
2020-07-17 17:57:29 +0000	10.1.1.2	admin	ssh	10.1.1.1	start	task_id=136	timezone=UTC	service=shell	priv-lvl=15	cmd=info
2020-07-17 17:57:29 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=136	timezone=UTC	service=shell	priv-lvl=15	cmd=info
2020-07-17 17:57:33 +0000	10.1.1.2	admin	ssh	10.1.1.1	start	task_id=137	timezone=UTC	service=shell	priv-lvl=15	cmd=exit
2020-07-17 17:57:33 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=137	timezone=UTC	service=shell	priv-lvl=15	cmd=exit
2020-07-17 17:57:34 +0000	10.1.1.2	admin	ssh	10.1.1.1	start	task_id=138	timezone=UTC	service=shell	priv-lvl=15	cmd=exit
2020-07-17 17:57:34 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=138	timezone=UTC	service=shell	priv-lvl=15	cmd=exit
2020-07-17 17:57:36 +0000	10.1.1.2	admin	ssh	10.1.1.1	start	task_id=139	timezone=UTC	service=shell	priv-lvl=15	cmd=info
2020-07-17 17:57:36 +0000	10.1.1.2	admin	ssh	10.1.1.1	stop	task_id=139	timezone=UTC	service=shell	priv-lvl=15	cmd=info
2020-07-17 18:01:20 +0000	10.1.1.2	wim	ssh	10.1.1.1	start	task_id=3	timezone=UTC	service=shell	priv-lvl=15	cmd=exit
2020-07-17 18:01:20 +0000	10.1.1.2	wim	ssh	10.1.1.1	stop	task_id=3	timezone=UTC	service=shell	priv-lvl=15	cmd=exit
2020-07-17 18:01:22 +0000	10.1.1.2	wim	ssh	10.1.1.1	start	task_id=4	timezone=UTC	service=shell	priv-lvl=15	cmd=quit
2020-07-17 18:01:22 +0000	10.1.1.2	wim	ssh	10.1.1.1	stop	task_id=4	timezone=UTC	service=shell	priv-lvl=15	cmd=quit
2020-07-17 18:01:50 +0000	10.1.1.2	hans	ssh	10.1.1.1	ascii login failed
2020-07-17 18:01:55 +0000	10.1.1.2	hans	ssh	10.1.1.1	ascii login succeeded
```
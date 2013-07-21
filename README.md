Installation

Python prerequisites:
- Python 2.7

```
$ easy_install pip
$ sudo pip install ansible
```

Ruby prerequisites:
- Ruby 1.9.3

```
$ bundle install
$ cp upcs.config.example upcs.config
```

Edit upcs.config and add your rackspace username and API key (the API key can be found by clicking your username when logged in, then choose "Settings & Contacts" from the dropdown menu, then click the "Show" link next to the API Key in account settings).

Run

Start 10 servers:

```$ ./rackspace-up.sh 10```

Install software on each of the 10 servers:

```$ ansible_playbook -f 10 -i download.inventory download_setup.yml```

Start downloading books to each of the 10 servers, and then to cloud files:

```$ ansible_playbook -f 10 -i download.inventory download.yml```

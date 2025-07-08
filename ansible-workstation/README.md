
░░      ░░░  ░░░░  ░░░      ░░░  ░░░░  ░░        ░                    
▒  ▒▒▒▒▒▒▒▒   ▒▒   ▒▒  ▒▒▒▒  ▒▒  ▒▒▒  ▒▒▒  ▒▒▒▒▒▒▒                    
▓▓      ▓▓▓        ▓▓  ▓▓▓▓  ▓▓     ▓▓▓▓▓      ▓▓▓                    
███████  ██  █  █  ██  ████  ██  ███  ███  ███████                    
██      ███  ████  ███      ███  ████  ██        █                    

░  ░░░░  ░░        ░░       ░░░       ░░░░      ░░░       ░░░░      ░░
▒   ▒▒   ▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒▒▒▒
▓        ▓▓▓▓▓  ▓▓▓▓▓       ▓▓▓       ▓▓▓  ▓▓▓▓  ▓▓       ▓▓▓▓      ▓▓
█  █  █  █████  █████  ███  ███  ███  ███  ████  ██  ███  █████████  █
█  ████  ██        ██  ████  ██  ████  ███      ███  ████  ███      ██


Welcome to the Ansible Workstation repo.

# Prerequisites:
- Python 3.7 or later
- Your SSH key distributed to target hosts

# Getting Started

There is a requirements.txt and a Makefile included in the git repo.

Clone the repo to a local folder, then cd into it.

Run `make` to build a hidden .venv directory with the specific Ansible release; later versions available through pip may not work with the default system Python version of the workstations, which will break support for many core modules of Ansible.

Once you have the .venv activate it by running

```
source .venv/bin/activate
```

You should then see `(.venv)` preceding your shell prompt, e.g.:

```
GBLONml80085003:ansible-workstation tonimr$ source .venv/bin/activate
(.venv) GBLONml80085003:ansible-workstation tonimr$
```

From here you can now run Ansible commands against any hosts which are present in the `inventory/hosts` file-- test ad hoc commands such as `ansible -m ping` which will send you a response from any hosts you can communicate with, or `ansible -m setup` which should return facts gathered by Ansible.

## Hosts

The hosts file exists in the `inventory` subfolder, it's written as an ini. Hosts are grouped by intended usage (for example flame, flameassist).

Variables can be set per workstation or per group, and you can create container groups full of child subgroups (for example `[all:children]` contains each subgroup).

## Playbooks

Playbooks are in the playbooks subfolder, and do not contain any logic or specific tasks; they are used to load in tasks from reusable roles, and pass variables to those roles. In this way, we can reuse the same tasks for multiple builds of machines and keep them consistent.

You can see that the install_flame_2024.2.2 playbook contains a list of roles, with target version numbers and the variable `do:` set to install.

## Roles

All of the logic is held in our roles, existing in subfolders per role (whether by software package or end goal). The `main.yml` is usually there to gather facts from the machine and decide which actions to take-- is a package already installed? Which version is it? What have we passed to the `do` variable-- install, upgrade, uninstall? It then calls the relevant .yml file which contains the specific logic for the task.

The goal is idempotency and reusability, so that playbooks can be run multiple times against a series of machines to ensure they are built and configured in line.

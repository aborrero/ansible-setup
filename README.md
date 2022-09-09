# Ansible Laptop Configuration

Configuration for my laptops

The Ansible playbook `playbook.yml` contains serval tasks (i.e. the Ansible unit of action) grouped by [roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) and identified by [tags](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html). You can see the list tasks with this command:

```sh
ansible-playbook playbook.yml --list-tasks
```

Install all the things (you will need to type your sudo password once).

```sh
ansible-playbook playbook.yml -K
```

Or install only the tasks you want:

```sh
ansible-playbook playbook.yml -K --tags "cli,dev,docs" --list-tasks
ansible-playbook playbook.yml -K --tags "cli,dev,docs"
```

If some tasks fail, try re-running the playbook while skipping them:

```sh
ansible-playbook playbook.yml -K --skip-tags "js,python"
```

You can also check that the playbook does not have any syntactic errors:

```sh
ansible-playbook playbook.yml --syntax-check
```

## Credits

- [Benoth/ansible-ubuntu](https://github.com/Benoth/ansible-ubuntu)
- [Jackdbd/ansible-laptop](https://github.com/jackdbd/ansible-laptop)

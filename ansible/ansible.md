# Ansible - Automatizacion de infraestructura

## Instalacion

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install ansible -y

# Con pip
pip install ansible

# Verificar
ansible --version
```

---

## Inventario

El inventario define los hosts sobre los que Ansible actua.

```ini
# inventory.ini (formato INI)
[webservers]
web1.ejemplo.com
web2.ejemplo.com ansible_user=ubuntu

[databases]
db1.ejemplo.com ansible_port=2222

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/mi-clave

[webservers:vars]
http_port=80
```

```yaml
# inventory.yml (formato YAML)
all:
  children:
    webservers:
      hosts:
        web1.ejemplo.com:
        web2.ejemplo.com:
          ansible_user: ubuntu
    databases:
      hosts:
        db1.ejemplo.com:
          ansible_port: 2222
  vars:
    ansible_user: ubuntu
```

```bash
# Inventario dinamico (EC2, GCP, etc.)
ansible-inventory -i aws_ec2.yml --list
ansible-inventory -i aws_ec2.yml --graph
```

---

## Comandos ad-hoc

Ejecutar tareas sueltas sin escribir un playbook.

```bash
# Ping a todos los hosts
ansible all -i inventory.ini -m ping

# Ejecutar comando en todos los webservers
ansible webservers -i inventory.ini -m command -a "uptime"
ansible webservers -i inventory.ini -m shell -a "df -h | grep /dev"

# Ver informacion del sistema
ansible all -i inventory.ini -m setup
ansible all -i inventory.ini -m setup -a "filter=ansible_*_mb"   # solo memoria

# Instalar paquete
ansible webservers -i inventory.ini -m apt -a "name=nginx state=present" -b

# Copiar archivo
ansible webservers -i inventory.ini -m copy \
  -a "src=nginx.conf dest=/etc/nginx/nginx.conf" -b

# Reiniciar servicio
ansible webservers -i inventory.ini -m service \
  -a "name=nginx state=restarted" -b

# -b = become (sudo)
# -K = pedir password de sudo
# -u = usuario SSH
# -i = archivo de inventario
```

---

## Playbooks

```yaml
# site.yml
---
- name: Configurar webservers
  hosts: webservers
  become: true             # usar sudo
  vars:
    app_port: 3000
    app_env: production

  tasks:
    - name: Actualizar cache de paquetes
      apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Instalar nginx
      apt:
        name: nginx
        state: present

    - name: Copiar configuracion de nginx
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/sites-available/mi-app
        owner: root
        group: root
        mode: '0644'
      notify: Reiniciar nginx

    - name: Habilitar sitio
      file:
        src: /etc/nginx/sites-available/mi-app
        dest: /etc/nginx/sites-enabled/mi-app
        state: link

    - name: Asegurar que nginx esta activo
      service:
        name: nginx
        state: started
        enabled: true

  handlers:
    - name: Reiniciar nginx
      service:
        name: nginx
        state: restarted
```

```bash
# Ejecutar playbook
ansible-playbook site.yml -i inventory.ini
ansible-playbook site.yml -i inventory.ini --check     # dry-run
ansible-playbook site.yml -i inventory.ini --diff      # ver diferencias
ansible-playbook site.yml -i inventory.ini -v          # verbose
ansible-playbook site.yml -i inventory.ini -vvv        # muy verbose
ansible-playbook site.yml -i inventory.ini --tags "nginx"    # solo tareas con ese tag
ansible-playbook site.yml -i inventory.ini --skip-tags "ssl" # omitir tareas con ese tag
ansible-playbook site.yml -i inventory.ini --limit "web1"    # solo ese host
```

---

## Modulos mas usados

```yaml
# Archivos y directorios
- name: Crear directorio
  file:
    path: /opt/mi-app
    state: directory
    owner: ubuntu
    group: ubuntu
    mode: '0755'

- name: Eliminar archivo
  file:
    path: /tmp/archivo.txt
    state: absent

- name: Copiar archivo
  copy:
    src: archivos/config.yml
    dest: /etc/mi-app/config.yml
    owner: root
    mode: '0644'

- name: Archivo desde template Jinja2
  template:
    src: templates/app.conf.j2
    dest: /etc/mi-app/app.conf

- name: Agregar linea a un archivo
  lineinfile:
    path: /etc/hosts
    line: "10.0.0.5 mi-servidor"
    state: present

- name: Reemplazar en archivo
  replace:
    path: /etc/ssh/sshd_config
    regexp: '^#PasswordAuthentication yes'
    replace: 'PasswordAuthentication no'

# Paquetes
- name: Instalar paquetes
  apt:
    name:
      - nginx
      - curl
      - htop
    state: present
    update_cache: true

- name: Instalar version especifica
  apt:
    name: nginx=1.24.0-1
    state: present

- name: Eliminar paquete
  apt:
    name: apache2
    state: absent
    purge: true

# Servicios
- name: Gestionar servicio
  service:
    name: nginx
    state: started     # started, stopped, restarted, reloaded
    enabled: true

# Comandos
- name: Ejecutar comando
  command: /usr/bin/mi-script.sh
  args:
    chdir: /opt/mi-app

- name: Ejecutar en shell (con pipes, etc.)
  shell: "ps aux | grep nginx | wc -l"
  register: nginx_count

- name: Mostrar resultado
  debug:
    var: nginx_count.stdout

# Condicional con resultado de comando
- name: Inicializar solo si no fue iniciado antes
  command: /opt/init.sh
  args:
    creates: /opt/.initialized   # no ejecutar si este archivo existe

# Git
- name: Clonar repositorio
  git:
    repo: https://github.com/org/repo.git
    dest: /opt/mi-app
    version: main
    force: true

# Usuarios
- name: Crear usuario
  user:
    name: appuser
    shell: /bin/bash
    groups: docker
    append: true
    create_home: true

# Variables de entorno y secrets
- name: Leer secret de AWS SSM
  community.aws.aws_ssm_parameter_store:
    name: /mi-app/prod/db-password
  register: db_password
```

---

## Variables y hechos (facts)

```yaml
# Definir variables en el playbook
vars:
  app_name: mi-app
  app_port: 3000

# Variables en archivo externo
vars_files:
  - vars/prod.yml

# Variables desde la linea de comandos
# ansible-playbook site.yml -e "app_env=staging app_port=4000"

# Registrar output de una tarea
- name: Obtener version de node
  command: node --version
  register: node_version

- name: Mostrar version
  debug:
    msg: "Node version: {{ node_version.stdout }}"

# Condicionales
- name: Solo en Ubuntu
  apt:
    name: nginx
  when: ansible_distribution == "Ubuntu"

- name: Solo si el servicio existe
  service:
    name: nginx
    state: restarted
  when: nginx_count.stdout | int > 0

# Bucles
- name: Instalar multiples paquetes
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - curl
    - git

- name: Crear multiples usuarios
  user:
    name: "{{ item.name }}"
    shell: "{{ item.shell }}"
  loop:
    - { name: lucas, shell: /bin/zsh }
    - { name: deploy, shell: /bin/bash }
```

---

## Roles (estructura reutilizable)

```bash
# Crear estructura de rol
ansible-galaxy role init mi-rol

# Estructura generada:
# mi-rol/
#   tasks/
#     main.yml
#   handlers/
#     main.yml
#   templates/
#   files/
#   vars/
#     main.yml
#   defaults/
#     main.yml    <- variables con valores por defecto (sobreescribibles)
#   meta/
#     main.yml    <- dependencias del rol
```

```yaml
# Usar rol en playbook
- name: Configurar servidor
  hosts: webservers
  become: true
  roles:
    - common
    - nginx
    - { role: mi-rol, vars: { app_port: 3000 } }
```

```bash
# Instalar rol de Ansible Galaxy
ansible-galaxy install geerlingguy.docker
ansible-galaxy install -r requirements.yml
```

---

## ansible-vault (secretos encriptados)

```bash
# Encriptar un archivo
ansible-vault encrypt vars/secrets.yml

# Crear archivo encriptado directamente
ansible-vault create vars/secrets.yml

# Ver contenido de archivo encriptado
ansible-vault view vars/secrets.yml

# Editar archivo encriptado
ansible-vault edit vars/secrets.yml

# Desencriptar archivo
ansible-vault decrypt vars/secrets.yml

# Encriptar un valor suelto (para incluir en YAML)
ansible-vault encrypt_string 'mi-password-secreto' --name 'db_password'

# Ejecutar playbook con vault
ansible-playbook site.yml --ask-vault-pass
ansible-playbook site.yml --vault-password-file ~/.vault_pass
```

---

## ansible.cfg - Configuracion

```ini
# ansible.cfg (en la raiz del proyecto o en ~/.ansible.cfg)
[defaults]
inventory          = ./inventory.ini
remote_user        = ubuntu
private_key_file   = ~/.ssh/mi-clave
host_key_checking  = False           # no verificar fingerprints (dev)
retry_files_enabled = False
stdout_callback    = yaml            # output mas legible

[privilege_escalation]
become      = True
become_method = sudo

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=30m   # reutilizar conexiones SSH
pipelining = True                    # mas rapido (requiere requiretty=False en sudoers)
```

---

## Tips de productividad

```bash
# Ver todos los hechos de un host
ansible <host> -i inventory.ini -m setup | less

# Probar conectividad antes de correr el playbook
ansible all -i inventory.ini -m ping

# Ver que haria sin ejecutar (dry-run)
ansible-playbook site.yml --check --diff

# Limitar a un host o grupo especifico
ansible-playbook site.yml --limit web1
ansible-playbook site.yml --limit "webservers:!web1"  # webservers excepto web1

# Listar hosts que matchean un patron
ansible webservers --list-hosts -i inventory.ini

# Listar tareas del playbook sin ejecutar
ansible-playbook site.yml --list-tasks
ansible-playbook site.yml --list-hosts
ansible-playbook site.yml --list-tags

# Empezar desde una tarea especifica
ansible-playbook site.yml --start-at-task="Copiar configuracion de nginx"

# Paso a paso interactivo
ansible-playbook site.yml --step
```

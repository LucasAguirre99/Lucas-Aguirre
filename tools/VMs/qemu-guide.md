# 🖥️📀 Qemu guia para levantar y manejar máquinas virtuales

Si necesitamos levantar ISO de diferentes kvm, una solución más rápida que virtualbox es levantarla directamente desde consola, primero debemos de instalar el gestor qemu

- **Instalación**:
  ```bash
  sudo apt update
  sudo apt install qemu-kvm libvirt-daemon-system virt-manager -y
  ```

- **Podemos manejarlo por la interfaz gráfica**
  ```bash
  virt-manager
  ```

- **Instalar una ISO**
  ```bash
  virt-install --name ${Nombre-vm} \
  --ram 2048 \
  --vcpus 2 \
  --disk size=${N° en Gb}  \
  --cdrom ${Nombre.iso} \
  --osinfo detect=on,require=off \
  --graphics spice
  ```

- **Ver las VM creadas**
  ```bash
  virsh list --all
  ```

- **Apagar la VM**
  ```bash
  virsh destroy ${Nombre-vm}
  ```

- **Eliminar la VM**
  ```bash
  virsh undefine ${Nombre-vm}
  ```

- **Borrar el disco virtual**
  ```bash
  virsh domblklist ${Nombre-vm}
  ```
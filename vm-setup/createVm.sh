#! /bin/bash
if [ -z "$1" ] || [ "$1" == "-h"  ]; then
  echo "Usage: ./createVm.sh <VM_NAME> <ROOT_DIK_SIZE> <CPU> <MEMORY> <NETWORK>"
  exit 1
fi

VM_NAME=${1}
VM_ROOT_DISK_SIZE=${2:-20G}
VM_CPU=${3:-2}
VM_MEMORY=${4:-4096}
VM_NETWORK=${5:-some-network}

TEMPLATE_DIR="/var/lib/libvirt/templates"
TEMPLATE_PATH="${TEMPLATE_DIR}/debian-11-generic-amd64.qcow2"

SEED_IMG_DEST="/var/lib/libvirt/seed/${VM_NAME}-seed.img"
VM_DEST="/var/lib/libvirt/storage-pool/${VM_NAME}-root-disk.qcow2"


if [ -z ${VM_NAME} ]; then

  echo "No VM name provided, aborting"
  exit -1
fi

if [ "${VM_ROOT_DISK_SIZE}" == "20G" ]; then
  echo "Using default disk size of 20G"

  echo -n "Do you want to continue (y/n)? "
  read answer

  if [ "$answer" != "${answer#[Yy]}" ] ;then # this grammar (the #[] operator) means that the variable $answer where any Y or y in 1st position will be dropped if they exist.
    echo "Continuing"
  else
    echo "Aborting"
    exit -1
  fi
fi

echo "Copy template for ${VM_NAME}"
qemu-img convert -f qcow2 -O qcow2 "${TEMPLATE_PATH}" "${VM_DEST}"

echo "Resizing disk to ${VM_ROOT_DISK_SIZE}"
qemu-img resize "${VM_DEST}" "${VM_ROOT_DISK_SIZE}"

echo "Copy cloud init cfg"
cp ./cloud_init.cfg.template "./${VM_NAME}-cloud_init.cfg"
sed -i 's/##VM_NAME##/'"${VM_NAME}"'/g' "./${VM_NAME}-cloud_init.cfg"

cloud-localds -v "${SEED_IMG_DEST}" "./${VM_NAME}-cloud_init.cfg"


echo "Run the following command to start the newly created VM."
echo virt-install --name "${VM_NAME}" --memory "${VM_MEMORY}" --vcpus "${VM_CPU}" --disk "path=${SEED_IMG_DEST},device=cdrom" --disk "${VM_DEST},device=disk,bus=virtio,format=qcow2" --os-type Linux --os-variant debian9 --network "bridge=${VM_NETWORK},model=virtio" --virt-type kvm --graphics none --import

echo "If you don't need the console append: --noautoconsole"

echo ""
echo "After the initial setup, you can disable cloud-init"
echo "touch /etc/cloud/cloud-init.disabled && apt remove -y cloud-init"
echo "And eject the cdrom"
echo "targetDrive=\$(virsh domblklist \${VM_NAME} | grep \${VM_NAME}-seed.img | awk {' print \${1} '})"
echo "virsh change-media \${VM_NAME} --path \${targetDrive} --eject --force"

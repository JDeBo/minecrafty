#! /bin/bash
#1 filename of update zip
#2 first 4 numbers of url
#3 second 3 numbers of url
# eg sh version_update.sh Vault+Hunters+3rd+Edition-Update-7H_Server-Files.zip 4384 504
# rm -rf /opt/minecraft/tmp/*
# wget -O /opt/minecraft/tmp/vault-hunters.zip $1

#unzip -q /opt/minecraft/tmp/vault-hunters.zip -d /opt/minecraft/tmp/
#rm /opt/minecraft/tmp/vault-hunters.zip

FILES=('scripts' 'patchouli_books' 'mods' 'defaultconfigs' 'resourcepacks' 'config')
 
for file in "${FILES[@]}"
do
  echo "Moving $file, please wait ..."
  mv /opt/minecraft/vault/${file}_old /opt/minecraft/tmp/
  mv /opt/minecraft/vault/$file /opt/minecraft/vault/${file}_old
  mv /opt/minecraft/tmp/$file /opt/minecraft/vault/$file
done


# mv /opt/minecraft/tmp/* /opt/minecraft/vault/
# echo "Update finished (hopefully). Restart minecraft when ready (sudo systemctl restart <service>)"
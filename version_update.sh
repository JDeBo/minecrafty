#! /bin/bash
#1 filename of update zip
#2 first 4 numbers of url
#3 second 3 numbers of url
# eg sh version_update.sh Vault+Hunters+3rd+Edition-Update-7H_Server-Files.zip 4384 504
rm -rf /opt/minecraft/tmp/*
wget -O /opt/minecraft/tmp/vault-hunters.zip https://media.forgecdn.net/files/$2/$3/$1

unzip -q /opt/minecraft/tmp/vault-hunters.zip -d /opt/minecraft/tmp/
rm /opt/minecraft/tmp/vault-hunters.zip

FILES=('scripts' 'patchouli_books' 'mods' 'defaultconfigs' 'config')
 
for file in "${FILES[@]}"
do
  echo "Moving $file, please wait ..."
  mv /opt/minecraft/vault/$file /opt/minecraft/vault/$file_old
done

mv /opt/minecraft/tmp/* /opt/minecraft/vault/
echo "Update finished (hopefully). Restart minecraft when ready (sudo systemctl restart <service>)"

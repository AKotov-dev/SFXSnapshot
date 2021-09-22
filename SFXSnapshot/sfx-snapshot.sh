#!/usr/bin/bash

#Сбрасываем цвета
tput sgr0
#Определяем цвет выделения
color='\e[32m'; ncolor='\e[0m';

#Читаем параметры
SFX_NAME="$1" #Имя SFX-архива
SFX_PATH="$2" #Путь назначения для SFX-архива
WORK_DIR="$3" #Путь к рабочему каталогу user/root
SFX_ROOT="$4" #Запрос root/su при распаковке SFX

CMD_PATH="$(dirname "$0")"; #Путь к рабочим скриптам

cd $WORK_DIR; #Делаем текущим рабочий каталог юзера для tar

#Подчищаем старый патч, если создавался
rm -f ./*.tar.gz ./*.run

echo -e "${color}Assembling objects from a list of files...${ncolor}"
echo "---"

tar -P -zcvf "./$SFX_NAME.tar.gz" -T "./files.lst"

#---------------------------------------------------

#Создаю стартовый скрипт распаковки ./install.sh
echo -e "#!/bin/bash\n\n\
clear\n\
echo 'Install \"$SFX_NAME\"?'\n\
echo '---'\n\
echo 'Enter - Yes, Ctrl+C - Cancel...'\n\
read a\n\
tar -P -xvf './$SFX_NAME.tar.gz'\n\
echo '---'\n\
echo 'Completed. Enter - Exit...'\n\
read a" > ./install.sh
chmod +x ./install.sh

if [ -n "$SFX_ROOT" ]; then
echo -e "${color}Make \"$SFX_NAME.run\" with root privilege request...${ncolor}"; else
echo -e "${color}Make \"$SFX_NAME.run\" without request for root privileges...${ncolor}"; fi

"$CMD_PATH"/makeself --version
"$CMD_PATH"/makeself --zstd --header "$CMD_PATH/makeself-header.sh" \
         --tar-extra "--exclude=./*.lst --exclude=./*.xml" \
         $SFX_ROOT ./ "./$SFX_NAME.run" "" ./install.sh

echo -e "${color}Move \"$SFX_NAME.run\" from work directory to the destination folder...${ncolor}"
[ -f "./$SFX_NAME.run" ] && mv -fv "$WORK_DIR/$SFX_NAME.run" "$SFX_PATH"

#Подчищаем промежуточные файлы
find . -type f ! -name "*.xml" -delete

echo "---"
echo -e "${color}Compression is complete. Enter - Exit...${ncolor}"
read a

exit 0;


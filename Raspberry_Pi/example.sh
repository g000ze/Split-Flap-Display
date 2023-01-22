#!/bin/bash

dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

chars='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!%&*+-./:?$@# '
i2c_transmit="${dir}/i2c_transmit.php"

${i2c_transmit} --text="      "
sleep 2

for i in 0 1 2 3 4 5 6 7 8 9 ; do 
  ${i2c_transmit} --text="$i~~~~~" --same --noblock
  ${i2c_transmit} --text="~$i~~~~" --same --noblock
  ${i2c_transmit} --text="~~$i~~~" --same --noblock
  ${i2c_transmit} --text="~~~$i~~" --same --noblock
  ${i2c_transmit} --text="~~~~$i~" --same --noblock
  ${i2c_transmit} --text="~~~~~$i" --same --noblock
  sleep 0.2
done
sleep 2

counter=0
for i in a b c d e f g h i j  ; do
  ((counter++))
  if [ $((counter%2)) -eq 0 ]; then
    ${i2c_transmit} --text="$i~~~~~" --same --noblock
    ${i2c_transmit} --text="~$i~~~~" --same --noblock
    ${i2c_transmit} --text="~~$i~~~" --same --noblock
    ${i2c_transmit} --text="~~~$i~~" --same --noblock
    ${i2c_transmit} --text="~~~~$i~" --same --noblock
    ${i2c_transmit} --text="~~~~~$i" --same --noblock
  else
    ${i2c_transmit} --text="~~~~~$i" --same --noblock
    ${i2c_transmit} --text="~~~~$i~" --same --noblock
    ${i2c_transmit} --text="~~~$i~~" --same --noblock
    ${i2c_transmit} --text="~~$i~~~" --same --noblock
    ${i2c_transmit} --text="~$i~~~~" --same --noblock
    ${i2c_transmit} --text="$i~~~~~" --same --noblock
  fi
  sleep 0.2
done
sleep 2

# start from left to right
${i2c_transmit} --text="      " --same --animation=l
sleep 2
# start from right to left
${i2c_transmit} --text='$$$$$$' --same --animation=r
sleep 2

# inside out
${i2c_transmit} --text="~~${i}${i}~~" --noblock ; sleep 0.3
${i2c_transmit} --text="~${i}~~${i}~" --noblock ; sleep 0.3
${i2c_transmit} --text="${i}~~~~${i}" --noblock ; sleep 0.3
sleep 6

# start at the same time
${i2c_transmit} --text='ug&7nz' --same --animation=
sleep 2
# stop at the same time
${i2c_transmit} --text="      " --same --animation=h
sleep 2

for i in 0 1 2 3 4 5 6 7 8 9 A B C " " ; do
  ${i2c_transmit} --text="${i}${i}${i}${i}${i}${i}" --same ; sleep 0.2
done

sleep 1
sleep=1
for i in 0 1 2 3 4 5 6 7 8 9  A B C D E F G H I J K L M N O P Q R S T U V W X Y Z " " ; do
  ${i2c_transmit} --text="${i}${i}${i}${i}${i}${i}" --same
  sleep $sleep
  sleep="$(bc -l <<< "$sleep-($sleep/9)")"
done
sleep 1

for ((i = 0; i < ${#chars}; i++ )); do
  a="${chars:$i:1}"; ${i2c_transmit} --text="$a$a$a$a$a$a"; 
  sleep 0.2
done


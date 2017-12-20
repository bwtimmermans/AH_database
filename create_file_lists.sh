#!/bin/sh

# Master list file.
   M_LIST="./PPE_database_AH.txt"
   TEMP_PATH="./temp_listings"
   HTAR_PATH="./htar_listings"

# Create a temporary list.
#-----------------------------------------------------------------#
# Temporary extract list.
   EX_LIST="${TEMP_PATH}/temp_extract_list_`date +%d%h%H%M%S`"

# Loop over PPE members or specify a single member.
   for PPE in {39..100}
   #for PPE in `echo "28"`
      do
         PPE_N="amip_f09_f09_${PPE}"
         echo " Procesing: $PPE_N"
# Grep relevant enties from the master file.
         grep "${PPE_N}_" ${M_LIST} >> ${EX_LIST}
         if [ $? != "0" ]; then
            echo " PPE does not exist in database."
            #exit 1
         fi
      done

#-----------------------------------------------------------------#
# Find PPEs and corresponding HTAR master files.
   PPE_LIST=`gawk '{ print $1 }' ${EX_LIST} | uniq`

# Loop over PPE members.
   for PPE in `echo "${PPE_LIST}"`
      do
# Test for existing download file list and write as necessary.
         if [ ! -f "./PPE_file_lists/${PPE}.list" ]; then 
# Loop over HTAR files.
            HTAR_FILES=`grep "${PPE}	" ${EX_LIST} | gawk '{ print $2 }'`
            for TARGET in `echo "${HTAR_FILES}"`
               do
                  echo "TARGET: ${TARGET}"
                  T_N1=$(echo ${TARGET} | cut -d'/' -f8 | sed 's@X_\(.._PPE_..\)@\1@')
                  T_N2=$(echo ${TARGET} | cut -d'/' -f9 | sed 's@\(.*\)_all_norest.tar@\1@')
                  TARGET_NAME=${T_N1}-${T_N2}
# Locate previous HTAR listing if available.
                  if [ ! -f "${HTAR_PATH}/${TARGET_NAME}_list" ]; then
echo "HTAR listing not found!"
                     echo "htar tf ${TARGET} > ${HTAR_PATH}/${TARGET_NAME}_list"
                  fi
                  HTAR_EXTRACT=`cat ${HTAR_PATH}/${TARGET_NAME}_list | grep "${PPE}\." | grep 'cam.h1.' | gawk '{ print $7 }'`
                  for FILES in `echo ${HTAR_EXTRACT}`
                     do
# Write a list of files.
                        echo "${TARGET}	${FILES}" >> ./PPE_file_lists/${PPE}.list
                     done
               done
         fi
      done


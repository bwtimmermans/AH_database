#!/bin/sh

# Build a data base of HTAR files that correspond to PPEs.
#==================================================================#

# Block.
   HIST="AH"

# Master list file.
   M_LIST="./PPE_database_${HIST}.txt"
   if [ -f ${M_LIST} ]; then
      " WARNING: Database file exists."
      #exit 1
   fi

# Loop over PPE members.
   #for PPE in `cat /global/cscratch1/sd/timmer/cesm/ensemble_DA/analysis/success_master`
   for PPE in {1..100}
      do
# Loop over IC members.
         for IC in {1..28}
            do
               PPE_M="amip_f09_f09_${PPE}_${IC}\/"
               PPE_MM="amip_f09_f09_${PPE}_${IC}"

# Loop over blocks.
               #for B_N in {01..09}
               for B_N in `echo "03 04"`
                  do
                     BLOCK="X_${HIST}_PPE_${B_N}"
#------------------------------------------------------------------#
# "First round" runs.
#------------------------------------------------------------------#
# Ignore IC 15 runs in the first round.
                     if [ "${IC}" != "15" ]
                        then
# Hack to avoid problem in X_AH_PPE_04.
                           if [ "${BLOCK}" != "X_AH_PPE_04" ]
                              then
                                 for F_N in {1..2}
                                    do
# Part 1 & 2 files.
                                       HTAR_FILE="/home/t/timmer/cesm/archive/cori-knl/${BLOCK}/01_02_P${F_N}_all_norest.tar"
                                       LIST_FILE="${HIST}_PPE_${B_N}-01_02_P${F_N}_list"
                                       if ! [ -f "./htar_listings/${LIST_FILE}" ]
                                          then
                                             htar tf ${HTAR_FILE} > ./htar_listings/${LIST_FILE}
                                       fi
# Find files.
                                       grep -m 1 "${PPE_M}" ./htar_listings/${LIST_FILE} > /dev/null 2>&1
# Save location when found.
                                       if [ "$?" == "0" ]
                                          then
                                             echo "${PPE_MM}	${HTAR_FILE}" >> ${M_LIST}
                                       fi
                                    done
                              else 
                                 HTAR_FILE="/home/t/timmer/cesm/archive/cori-knl/${BLOCK}/01_02_all_norest.tar"
                                 LIST_FILE="${HIST}_PPE_${B_N}-01_02_list"
                                 if ! [ -f "./htar_listings/${LIST_FILE}" ]
                                    then
                                       htar tf ${HTAR_FILE} > ./htar_listings/${LIST_FILE}
                                 fi
# Find files.
                                 grep -m 1 "${PPE_M}" ./htar_listings/${LIST_FILE} > /dev/null 2>&1
# Save location when found.
                                 if [ "$?" == "0" ]
                                    then
                                       echo "${PPE_MM}	${HTAR_FILE}" >> ${M_LIST}
                                 fi
                           fi
# Part 3 files.
                           for F_N in {1..4}
                              do
                                 HTAR_FILE="/home/t/timmer/cesm/archive/cori-knl/${BLOCK}/03_P${F_N}_all_norest.tar"
                                 LIST_FILE="${HIST}_PPE_${B_N}-03_P${F_N}_list"
                                 if ! [ -f "./htar_listings/${LIST_FILE}" ]
                                    then
                                       htar tf ${HTAR_FILE} > ./htar_listings/${LIST_FILE}
                                 fi
                  
                                 grep -m 1 "${PPE_M}" ./htar_listings/${LIST_FILE} > /dev/null 2>&1
# Save location when found.
                                 if [ "$?" == "0" ]
                                    then
                                       echo "${PPE_MM}	${HTAR_FILE}" >> ${M_LIST}
                                 fi
                              done
                     fi

#------------------------------------------------------------------#
# "Second round" runs.
#------------------------------------------------------------------#
                     for F_N in {0..7}
                        do
                           HTAR_FILE="/home/t/timmer/cesm/archive/cori-knl/${BLOCK}/04_P${F_N}_all_norest.tar"
                           LIST_FILE="${HIST}_PPE_${B_N}-04_P${F_N}_list"
                           if ! [ -f "./htar_listings/${LIST_FILE}" ]
                              then
                                 htar tf ${HTAR_FILE} > ./htar_listings/${LIST_FILE}
                           fi
                           grep -m 1 "${PPE_M}" ./htar_listings/${LIST_FILE} > /dev/null 2>&1
# Save location when found.
                           if [ "$?" == "0" ]
                              then
                                 echo "${PPE_MM}	${HTAR_FILE}" >> ${M_LIST}
                           fi
                        done
                  done
            done
      done

# Finished.

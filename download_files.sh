#!/bin/sh

# Download files for each PPE from HPSS.

# Loop over PPE members or specify a single member.
   for PPE in {43..60}
   #for PPE in `echo "28"`
      do
         for IC in {1..28}
         #for IC in `echo "1 2 3 4"`
            do
               echo " Downloading amip_f09_f09_${PPE}_${IC}..."
               PPE_LIST="/global/cscratch1/sd/timmer/cesm/ensemble_DA/staging/AH/PPE_file_lists/amip_f09_f09_${PPE}_${IC}.list"
               if [ -f "${PPE_LIST}" ]; then
                  #echo " PPE list file does not exist."
                  #exit 1
               #fi

# Create directory for member output files.
               mkdir -p ./${PPE}/${IC}
               cd ./${PPE}/${IC}

# Get the HTAR file list.
               HTAR_LIST=$(gawk '{ print $1 }' ${PPE_LIST} | uniq)

# Loop over HTAR files to find output files.
               H_COUNT=0
               for HTAR_FILES in `echo ${HTAR_LIST}`
                  do
                     echo " Opening ${HTAR_FILES}..."

# Make a temporay directory for each HTAR file to catch duplicate output files.
                     mkdir temp${H_COUNT}
                     cd temp${H_COUNT}

# Extract the output files from HPSS.
                     #grep "${HTAR_FILES}" ${PPE_LIST} | gawk '{ print $2 }'
                     htar xf ${HTAR_FILES} `grep "${HTAR_FILES}" ${PPE_LIST} | gawk '{ print $2 }'`
                     cd ..
                     ((H_COUNT++))
                  done

# Find duplicates and select largest.
               find . -mindepth 1 -type f -printf '%p %f\n' | sort -t ' ' -k 2,2 | uniq -f 1 --all-repeated=separate | gawk '{ print $1 }' > dup.list
               U_FILES=$(find . -mindepth 1 -type f -printf '%p %f\n' | sort -t ' ' -k 2,2 | uniq -f 1 --all-repeated=separate | gawk '{ print $2 }' | uniq)
               for FILES in `echo ${U_FILES}`
                  do
                     ls -S `grep "${FILES}" dup.list` | sed -n '2,$p' >> rm.list
                  done
# Delete duplicate files.
               if [ -f ./rm.list ]; then
                  echo " Deleting: `cat rm.list`"
                  rm `cat rm.list`
               fi

# Move remaining files to base directory.
               F_COUNT=$(find ./ -name "*nc" | sort -V | wc -l)
               echo " File count: ${F_COUNT}"
               if [ ${F_COUNT} != 16 ]; then
                  echo " WARNING: File count = ${F_COUNT}. IC member blacklisted."
                  echo "amip_f09_f09_${PPE}_${IC}" >> blacklist 
               fi
               
               mv `find ./ -name "*nc" | sort -V` .

# Clean up and leave member directory.
               if [ "$?" == "0" ]; then
                  #rm -r for ((I=0; I<=H_COUNT; I++)); do echo "temp${I}"; done
                  rm -r temp*
               else
                  echo " Clean-up FAILED!"
               fi

               cd ../..

               else
                  echo " PPE list file does not exist."
               fi
              
            done
         echo " amip_f09_f09_${PPE}_${IC} COMPLETE."
         echo
      done

      echo " Download COMPLETE."


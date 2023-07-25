#!/usr/bin/tcsh

set B = 0       # begin (time, ps)
set E = 1000000 # end (time, ps)
set F = 10000   # number of frames to be extracted for each replica from the original .xtc file

@ DT = ($E - $B) / $F
 
echo "Extracting $F frames between $B and $E ps (dt = $DT)..."

# system names
set systems = ( 0mM 125mM 250mM 500mM 1000mM )

# MD replicas perfomed for each
set replicas = ( 1 2 3 4 )

# length of 'replicas' list (number of replicas to be processed)
set R = `echo "${#replicas}"`

foreach SYS ( $systems )
 
  if (! -d $SYS) mkdir $SYS

  cd $SYS
  
    foreach REP ( $replicas )
	    
      echo SYSTEM: $SYS
      echo REPLICA: $REP
     
      # this part of the script is specific to my project (delete or change it if you want)
      if ( $SYS == '0mM' ) then
        set NAME = 'BGHI'
      else
        set NAME = 'BGHI+bgl' 	  
      endif

      # converts ps to us (for trajectory file name only)
      @ Bns = $B / 1000
      @ Ens = $E / 1000
     
      set TRJ  = "${NAME}_${Bns}-${Ens}ns_${F}_R${REP}.xtc"
      set PROD = "prod_R${REP}.xtc" 
      set TOP  = "prod_R${REP}.tpr"
  
      unlink $PROD
      ln -s /media/felipecr/Seagate/results_${SYS}/0${REP}/prod.xtc $PROD
      
      cp /media/felipecr/Seagate/results_${SYS}/0${REP}/prod.tpr $TOP
      
      # gromacs command line:
      # echo 0 | gmx_mpi trjconv -f $PROD -s $TOP -b $B -e $E -dt $DT -o $TRJ
 
      # testing the script:
      pwd
      echo "gmx_mpi trjconv -f $PROD -s $TOP -b $B -e $E -dt $DT -o $TRJ"
      echo "$TRJ"
      echo " "

    end

    # total of frames to be extrected (here, R = 4)
    @ TF = $F * $R

    # create an input file to merge all replicas (4 replicas in this case)
    cat << EOF > merge_traj.tcsh
    gmx_mpi trjcat -f ${NAME}_${Bns}-${Ens}ns_${F}_R1.xtc \
                      ${NAME}_${Bns}-${Ens}ns_${F}_R2.xtc \
                      ${NAME}_${Bns}-${Ens}ns_${F}_R3.xtc \
                      ${NAME}_${Bns}-${Ens}ns_${F}_R4.xtc \
    		   -o ${NAME}_${Bns}-${Ens}ns_${TF}_R1-4.xtc -cat  
EOF

  # merge all replicas in a simgle .xtc file (leave the line bellow commented out if you don't need it)
  # tcsh merge_traj.tcsh

  cd ../

end

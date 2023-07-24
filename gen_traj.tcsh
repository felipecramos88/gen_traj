#!/usr/bin/tcsh

set B = 0       # begin (time, ps)
set E = 1000000 # end (time, ps)
set F = 10000   # number of frames to be extracted for each replica

@ DT = ($E - $B) / $F
 
echo "Extracting $F frames between $B and $E ps (dt = $DT)..."

set c_list = ( 0mM 125mM 250mM 500mM 1000mM )
set r_list = ( 1 2 3 4 )

foreach CONC ( $c_list )
 
  if (! -d $CONC) mkdir $CONC

  cd $CONC
  
    foreach REP ( $r_list )
	    
      echo CONCENTRATION: $CONC
      echo REPLICA: $REP
     
      if ( $CONC == '0mM' ) then
        set NAME = 'BGHI'
      else
        set NAME = 'BGHI+bgl' 	  
      endif
     
      @ Bns = $B / 1000
      @ Ens = $E / 1000
     
      set TRJ  = "${NAME}_${Bns}-${Ens}ns_${F}_R${REP}.xtc"
      set PROD = "prod_R${REP}.xtc" 
      set TOP  = "prod_R${REP}.tpr"
  
      unlink $PROD
      ln -s /media/felipecr/Seagate/results_${CONC}/0${REP}/prod.xtc $PROD
      
      cp /media/felipecr/Seagate/results_${CONC}/0${REP}/prod.tpr $TOP
      
      echo 0 | gmx_mpi trjconv -f $PROD -s $TOP -b $B -e $E -dt $DT -o $TRJ
 
      # echo "gmx_mpi trjconv -f $PROD -s $TOP -b $B -e $E -dt $DT -o $TRJ"
      # touch $TRJ

    end

    # total of frames extrected:
    @ TF = $F * 4

    cat << EOF > merge_traj.tcsh
    gmx_mpi trjcat -f ${NAME}_${Bns}-${Ens}ns_${F}_R1.xtc \
                      ${NAME}_${Bns}-${Ens}ns_${F}_R2.xtc \
                      ${NAME}_${Bns}-${Ens}ns_${F}_R3.xtc \
                      ${NAME}_${Bns}-${Ens}ns_${F}_R4.xtc \
    		   -o ${NAME}_${Bns}-${Ens}ns_${TF}_R1-4.xtc -cat  
EOF

  # tcsh merge_traj.tcsh

  cd ../

end


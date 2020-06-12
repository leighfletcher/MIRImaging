

gases=['c2h6','c2h2','c2h4','ph3','nh3_all','h2','ch4','ch3d','ch4_13C']

wn = 1 		     ; 0=wavelength,1=wavenumbers
fwhm = 1.0
delv = 1.0		     ; DELV ignored if irregular bin step used.
reqdelv = 0.0 	     ; Desired DELV if delv=-1
;npts = 1501		     ; number of points
reg = 1 		    ; Regular (0) or irregular (1) bin step?
upper_w = 1500.
lower_w = 100.
bins = 1		    ; Square bins (0) or non-square (1)?
r1 = lower_w-0.5
r2 = upper_w+0.5	    ; Range for continuum calculation for non-square
shape = 1		    ; Same bin shape for all output points (0) or diff (1)
iexo = 0		    ; =1 for high-temperature line parameters
iptf = 0		    ; =1 for modified partition functions
line_band = 1		    ; Linedata(1) or banddata(2) (UNNECESSARY)
vdop = 0		    ; Line of sight velocity (UNNECESSARY)
ng = 600
wing = 1
vrel = 35
npress = 20		    ; Num of pressure points (<20)
Ln_pmin = -15		    ; Ln(pmin) [atm]
Ln_pmax = 2		    ; Ln(pmax) [atm]
ntemp = 20		    ; Num of temperature points (<20)
Tmin = 40		    ; Temperature minimum
Tmax = 300		    ; Temperature maximum
broad = 0		    ; Foreign(0) or Self(1) broadened
line_wing = 35  	    ; Line wing cut-off
filfile="../comics.fil"



ngas=n_elements(gases)

for ig=0,ngas-1 do begin
	    
	
    

	dir=strcompress('ktab_'+string(ig+1),/remove_all)
	spawn,'mkdir '+dir
	cd,dir

	if gases[ig] eq 'ph3' then gas='28 0 0'
	if gases[ig] eq 'nh3_all' then gas='11 0 6'
	if gases[ig] eq 'nh3_14N' then gas='11 1 6'
	if gases[ig] eq 'nh3_15N' then gas='11 2 6'
	if gases[ig] eq 'c2h6' then gas='27 0 0'
	if gases[ig] eq 'c2h2' then gas='26 0 0'
	if gases[ig] eq 'c2h4' then gas='32 0 0'
	if gases[ig] eq 'c4h2' then gas='30 0 0'
	if gases[ig] eq 'ch4_all' then gas='6 0 0'
	if gases[ig] eq 'ch4' then gas='6 1 0'
	if gases[ig] eq 'ch3d' then gas='6 3 0'
	if gases[ig] eq 'ch4_13C' then gas='6 2 0'
	if gases[ig] eq 'h2' then gas='39 0 0'
	if gases[ig] eq 'geh4' then gas='33 0 0'
	if gases[ig] eq 'co' then gas='5 0 0'
	if gases[ig] eq 'ash3' then gas='41 0 0'
	if gases[ig] eq 'h2o' then gas='1 0 0'
	if gases[ig] eq 'co2' then gas='2 0 0'
	if gases[ig] eq 'c3h8' then gas='34 0 0'
	if gases[ig] eq 'c3h4' then gas='42 0 0'
	if gases[ig] eq 'c6h6' then gas='49 0 0'



	key = "/home/l/lnf2/specdata/ldb/db2018/db120.key"

	if (gases[ig] eq 'nh3_all' or gases[ig] eq 'nh3_14N' or gases[ig] eq 'nh3_15N') then key="/data/nemesis/specdata/ldb/db2018/db112.key"


	outkta=strcompress(gases[ig]+'.kta',/remove_all)
	outlog=strcompress(gases[ig]+'.log',/remove_all)
	inp=strcompress(gases[ig]+'.inp',/remove_all)
	;qsub=strcompress(gases[ig]+'.qsub',/remove_all)

	inp='kta_inp'


	openw,1,inp
	printf,1,iexo,iptf
	printf,1,ng
	printf,1,wn
	printf,1,reg

	if reg eq 0 then printf,1,lower_w
	if reg eq 0 then printf,1,delv,npts
	
	; For regular DELV ktables with shape=0
	if reg eq 1 and shape eq 0 then begin
	    printf,1,npts
	    for i=0,npts-1 do printf,1,lower_w+reqdelv*i
	endif

	
	
	; For irregular ktables (e.g., channels).
	if reg eq 1 and shape eq 1 then begin
	    openr,2,filfile
	    npts=0.0
	    readf,2,npts
	    printf,1,npts
	    for j=0,npts-1 do begin
	    	dummy=0.0
    		readf,2,dummy
		printf,1,dummy
		readf,2,dummy
		arr=fltarr(2,dummy)
		readf,2,arr
	    endfor
	    close,2
	endif
	
	printf,1,bins
	if bins eq 0 then printf,1,fwhm
	if bins eq 1 then printf,1,r1,r2
	if bins eq 1 then printf,1,shape
	if bins eq 1 then printf,1,filfile

	printf,1,gas
	printf,1,wing,vrel
	printf,1,npress
	printf,1,Ln_pmin,Ln_pmax
	printf,1,ntemp
	printf,1,Tmin,Tmax
	printf,1,broad
	printf,1,line_wing
	printf,1,key
	printf,1,outkta

	close,1

	openw,1,'submit'
	printf,1,'#!/bin/bash'
	printf,1,'#'
	printf,1,'#PBS -N ktable'
	printf,1,'#PBS -l walltime=150:00:00'
	printf,1,'#PBS -l vmem=36gb'
	printf,1,'#PBS -l nodes=1:ppn=1'
	printf,1,'export PATH=~/bin/ifort:$PATH'
	printf,1,'cd $PBS_O_WORKDIR'
	printf,1,'Calc_fnktablec_dp < kta_inp > logfile'
	close,1

	cd,'..'

endfor

openw,1,'submitjob'
printf,1,'#!/bin/bash'
printf,1,'#'
printf,1,'#PBS -N ktable'
printf,1,'#PBS -l walltime=150:00:00'
printf,1,'#PBS -l vmem=36gb'
;printf,1,'#PBS -m bea'
;printf,1,'#PBS -M lnf2@le.ac.uk'
printf,1,'#PBS -l nodes=1:ppn=1'
txt=strcompress('1-'+string(ngas),/remove_all)
printf,1,'#PBS -t ',txt
printf,1,'export PATH=~/bin/ifort:$PATH'
printf,1,'cd $PBS_O_WORKDIR'
printf,1,'inputdir=ktab_${PBS_ARRAYID}'
printf,1,'cd $inputdir'
printf,1,'Calc_fnktablec_dp < kta_inp > logfile'
close,1



end


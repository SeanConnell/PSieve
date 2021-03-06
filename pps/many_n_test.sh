#!/bin/bash
resume_boinc()
# Resume BOINC if it's been stopped.  (Just continues otherwise.)
{
	boinccmd --set_run_mode auto
}

if [ $# = 0 ] ; then echo "Usage: $0 ppsieve_program [args]" ; exit ; fi
if [ "$1" = "all" ] ; then
	sh many_n_test.sh ppsieve-x86_64-linux $2 $3 -a yes
	sh many_n_test.sh ppsieve-x86_64-linux $2 $3 -a no
	sh many_n_test.sh ppsieve-boinc-x86_64-linux $2 $3 -a yes
	sh many_n_test.sh ppsieve-boinc-x86_64-linux $2 $3 -a no
	sh many_n_test.sh ppsieve-x86-linux $2 $3
	sh many_n_test.sh ppsieve-x86-linux $2 $3 -a no
	sh many_n_test.sh ppsieve-boinc-x86-linux $2 $3
	sh many_n_test.sh ppsieve-boinc-x86-linux $2 $3 -a no
	exit
fi
if [ ! -x $1 ] ; then echo "Usage: $0 ppsieve_program" ; exit ; fi
if [ -f ppcheck*.txt ] ; then rm ppcheck*.txt ; fi
mv ppfactors.txt ppfactors.txt.bak
touch ppfactors.txt
if killall boincmgr ; then sleep 1 ; fi
boinccmd --set_run_mode never
# trap keyboard interrupt (control-c)
#trap resume_boinc SIGINT
sleep 3
if [ "$2" = "-t" -o "$3" = "-t" -o "$4" = "-t" -o "$5" = "-t" ] ; then
	./$*  -p42070e9 -P42070050e6 -ippse_37TE1.txt -z normal -q #-fpps_test.txt
else
	taskset 0x00000002 ./$*  -p42070e9 -P42070050e6 -ippse_37TE1.txt -z normal -q #-fpps_test.txt
fi

resume_boinc
if grep '|' ppfactors.txt | sort | cmp OKsort.txt - ; then
	echo Test OK
	mv ppfactors.txt.bak ppfactors.txt
else
	echo TEST INVALID!!!
	printf "See diff (y/n)? "
	read keyin
	if [ $keyin == 'y' ] ; then
		sort ppfactors.txt | gvimdiff OKsort.txt -
	fi
	printf "\nKeep bad ppfactors.txt (y/n)? "
	read keyin
	if [ $keyin != 'y' ] ; then mv ppfactors.txt.bak ppfactors.txt ; fi
fi

#!/bin/ksh 

#############################################################################
###  as well as a bit of book-keeping this script will compile CABLE      ###
###  from source code  and deposit the executable binary in               ###
###  this directory. CABLE is then run over each of the sites specified   ### 
###  in "sites_main.txt" and output data moved into a created directory   ###
###  labelled by the name of the site, exact location depends somewhat on ###
### 
###  plots of flux data is called.                                        ### 
#############################################################################


#==============================================================================

#1、故障保护：book_keeping()函数负责一些文件和目录的整理工作。如果存在名为out.9的目录，脚本会退出。
book_keeping() 
{      
   if [[ -d out.9 ]]; then
      print "\n\ntime to organize your out/ directory"
      exit
   fi 
   
   i=8; ((j=i+1)); k=0;
   while [ $k -lt 8 ]
      do 
         if [[ -d out.$i ]]; then
            mv out.$i out.$j
         fi 
         ((j = j - 1)) 
         ((i = i - 1)) 
         ((k = k + 1)) 
      done

   if [[ -d out ]]; then
      mv out out.1
   fi      
   mkdir out

   HOST_MACH=`uname -n | cut -c 1-4`
   
   if [[ $HOST_MACH = 'vayu' ]]; then
   
      if [[ ! -e cable.nml ]]; then
         ln -s $CABLE_AUX/CABLE-AUX/offline/cable.nml .
      fi
      if [[ ! -e sites.txt ]]; then
         ln -s $CABLE_AUX/CABLE-AUX/offline/sites.txt .
      fi
      
   fi
}


#==============================================================================


# sitename given to subdirectory in out/ per site (should match cable.nml)
# this will be re-initiated properly for future release
#2、读取站点名称：site_name()从sites.txt文件中读取站点名称，并存储在数组中。
site_name()
{
   integer i=0
   exec < sites.txt
   
   while read line
   do
   	fchar=`echo "$line" | cut -c 1`  
      if [[ $fchar != '#' ]]; then
         echo $line >> fsites.txt     
         (( i = i + 1 ))
      fi   
   done 
   integer isites=i/3
   
   i=0
   exec < fsites.txt
   while ((i < isites)) 
   do
      read sites[i]	
      read fsites[i]	
      read fpoolsites[i]	
      print "\n\t${sites[i]}"
      (( i = i + 1 ))
   done 
   rm -f fsites.txt
} 


#==============================================================================

#3、运行CABLE：run_cable()这个函数负责运行CABLE模型。它会遍历所有站点，并对每个站点执行CABLE模型。
run_cable()
{
   integer kmax=${#sites[*]}
   integer k=0
   
   #  work around to desired trigerring from cable.nml  
   if [[ $kmax = 0 ]]; then
      kmax=1
      sites[0]='default'
   fi
              
   while [[ $k -lt $kmax ]]; do
      run_run $k        
      (( k = k + 1 ))
   done 
}


#==============================================================================

#4、辅助函数：run_run(): 这个函数是run_cable()的辅助函数，用于实际执行CABLE模型。它还负责移动输出文件到相应的目录
run_run()
{
   # remove any trace of previous runs
   tidy

   mkdir out/${sites[$1]}

   # execute CABLE
   if [[ ${fsites[$1]} != '' ]]; then
      ./cable ${fsites[$1]} ${fpoolsites[$1]}
   else
      ./cable       
   fi

   print '\n*** CABLE RUN FINISHED ***\n'
   
   # crude test for successful run, move files
   if [[ -f out_cable.nc ]]; then

      print '\n*** CABLE RUN (appears) SUCCESSFULL ***\n'
      		
      # CABLE output + restart if applicable
      mv log_cable.txt out_cable.nc restart_out.nc out/${sites[$1]}
      cp cable.nml  out/${sites[$1]}
      # pools for CASA-CNP
      if [[ -e poolcnpOut.csv ]]; then
         mv poolcnpOut.csv cnpfluxOut.csv out/${sites[$1]}
      fi 
   else
      print '\n*** ERROR: RUN FAILED ***\n'     
   fi  
   
   # clean up
   rm -f fort.66
}


#==============================================================================

#5、清理临时文件：tidy(): 清理生成的临时文件和目录。
tidy()
{
   rm -fr src/qsj.j src/*out qs* bu/  
   rm -f *.*out *.out *csv .qu 
}


#==============================================================================


#执行流程
#调用book_keeping进行目录和文件的整理。
#调用site_name从sites.txt读取站点名称。
#调用run_cable运行CABLE模型。

######################################################################
###  set up directory for this run - make output directory and     ###
### possibly helpful book-keeping to allow for immediate execution ### 
### and avoid accidently over-writing data - up to a point !!      ###
######################################################################

# see above functions()

book_keeping

site_name

########################################################################
##### call CABLE.R in batch mode to avoid going into R first, and    ###
##### then clean up this directory (these files have already been    ###
##### dealt with in R-script )                                       ###
########################################################################

run_cable








Run SURFEX offline.
1. Clone to your local git clone https://git.smhi.se/fuxing.wang/surfex_offline.git surfex_offline
2. Description of each directory:
  (1) SURFEX_FORCING: Create SURFEX format netcdf forcing. It will be added later.
  (2) SURFEX_COMPILE: Compile SURFEX code
    Change and run compile_surfex_CentOS7.sh
  (3) SURFEX_RUN: Run SURFEX simulations. 
    Change simulation.def
    For simulation with default (new) physiography: change OPTIONS.nam.defaultPhysiography (OPTIONS.nam.newPhysiography) to OPTIONS.nam
    Change NYEAR, NMONTH, NDAY for initial simulaiton date in OPTIONS.nam
  (4) SURFEX_DIM_Convert: Convert SURFEX original 1D output 1D (grid points) to 2D (x and y map)
    Change config.ini
Tips: 
- Create experiment under /nobackup (but not /home), because the very large output files will be first written in the experiment directory.
- PGD step for 'new physiography' is time consuming. If you want to use an exsisting PGD output, copy PGD.ext from that simulation to the current experiment folder. 
- To commit: git add "file_to_add" git commit -m "write comments here"; git push -u origin master


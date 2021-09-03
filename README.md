Run SURFEX offline.
1. Clone to your local git clone https://git.smhi.se/fuxing.wang/surfex_offline.git surfex_offline
2. Description of each directory: <br />
  (1) SURFEX_FORCING: Create SURFEX format netcdf forcing. Start from 'readme' file in this folder. <br />
  (2) SURFEX_COMPILE: Compile SURFEX code <br />
    Change and run compile_surfex_CentOS7.sh  <br />
  (3) SURFEX_RUN: Run SURFEX simulations. <br />
    Change simulation.def <br />
    For simulation with default (new) physiography: change OPTIONS.nam.defaultPhysiography (OPTIONS.nam.newPhysiography) to OPTIONS.nam <br />
    Change NYEAR, NMONTH, NDAY for initial simulaiton date in OPTIONS.nam <br />
  (4) SURFEX_DIM_Convert: Convert SURFEX original 1D output 1D (grid points) to 2D (x and y map) <br />
    Change config.ini and surfex_dim_convert.py <br />

Tips: <br /> 
- Create experiment under /nobackup (but not /home), because the very large output files will be first written in the experiment directory.
- PGD step for 'new physiography' is time consuming. If you want to use an exsisting PGD output, copy PGD.ext from that simulation to the current experiment folder. 
- To commit: git add "file_to_add" <br /> 
             git commit -m "write comments here" <br />
             git push -u origin master

Problems: <br />
- Currently, all variables are written to output and the simulation too slow (>10 hours for 1 month simulation). The solution is to change LSELECT=.TRUE. and set desired output variables in CSELECT in OPTIONS.nam. <br />


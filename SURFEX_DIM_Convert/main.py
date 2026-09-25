import os
import get_configuration
import dim_convert

HCLIMEXP, SURFEXEXP, name_surfex_file_list = get_configuration.get_conf()
exp_conf = get_configuration.get_experiment_conf(HCLIMEXP)

var_isba_list = ['T2M_ISBA', 'Q2M_ISBA', 'HU2M_ISBA', 'ZON10M_ISBA', 'MER10M_ISBA',
                  'LE_ISBA', 'H_ISBA', 'RN_ISBA', 'SWD_ISBA', 'SWU_ISBA', 'LWD_ISBA', 'LWU_ISBA']
var_isba_veg_evolution_list = ['LAI']

for surfex_exp in SURFEXEXP:
    simyear = get_configuration.get_simyear(surfex_exp)
    fmt = {"surfex_exp": surfex_exp, "simyear": simyear}

    # dir_surfex_month may contain "{simyear}" -- fail loudly if it's needed but missing
    if "{simyear}" in exp_conf["dir_surfex_month"] and simyear is None:
        raise KeyError(
            f"[{HCLIMEXP}] dir_surfex_month needs {{simyear}}, but '{surfex_exp}' "
            f"has no entry in [simyear_of_exp] in config.ini."
        )

    dir_surfex_sim_1d = exp_conf["dir_surfex_sim_1d"].format(**fmt)
    dir_surfex_sim_2d = exp_conf["dir_surfex_sim_2d"].format(**fmt)
    dir_surfex_ref_2d = exp_conf["dir_surfex_ref_2d"].format(**fmt)
    file_surfex_ref_2d = exp_conf["file_surfex_ref_2d"].format(**fmt)
    dir_surfex_month = exp_conf["dir_surfex_month"].format(**fmt)
    ntile = exp_conf["ntile"]

    if exp_conf["mkdir_sim_2d"]:
        os.makedirs(dir_surfex_sim_2d, exist_ok=True)
    os.makedirs(os.path.join(dir_surfex_sim_2d, "OUT_2D"), exist_ok=True)

    for name_surfex_file in name_surfex_file_list:
        nc_file_1D = os.path.join(dir_surfex_sim_1d, dir_surfex_month, name_surfex_file + ".nc")
        nc_file_2D = os.path.join(dir_surfex_ref_2d, file_surfex_ref_2d)
        nc_file_out = os.path.join(dir_surfex_sim_2d, "OUT_2D", name_surfex_file + ".2D.nc")

        dim_convert.nc_1D_to_2D(
            name_surfex_file, nc_file_1D, nc_file_2D, nc_file_out,
            ntile, var_isba_list, var_isba_veg_evolution_list,
        )

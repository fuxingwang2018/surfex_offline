"""Load configuration for the SURFEX dimension-conversion tool.

All experiment-specific paths live in config.ini. To add a new HCLIMEXP,
add a new [section] to config.ini -- no changes to this code are needed.
"""
import configparser
import os

CONFIG_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.ini")


def _read_config(path=CONFIG_FILE):
    # interpolation=None: we do our own {surfex_exp}/{simyear} substitution,
    # so ConfigParser must not try to interpret the braces itself.
    config = configparser.ConfigParser(interpolation=None)
    read_ok = config.read(path)
    if not read_ok:
        raise FileNotFoundError(f"Could not read config file: {path}")
    return config


def get_conf(path=CONFIG_FILE):
    """Return the general run settings: HCLIMEXP, list of SURFEXEXP, list of files."""
    config = _read_config(path)
    general = config["general"]

    hclimexp = general.get("HCLIMEXP")
    surfexexp_list = [s.strip() for s in general.get("SURFEXEXP").split(",")]
    name_surfex_file_list = [s.strip() for s in general.get("name_surfex_file").split(",")]

    return hclimexp, surfexexp_list, name_surfex_file_list


def get_experiment_conf(hclimexp, path=CONFIG_FILE):
    """Return the path settings for one HCLIMEXP, as defined in its config.ini section."""
    config = _read_config(path)

    if hclimexp not in config:
        raise KeyError(
            f"No [{hclimexp}] section found in {path}. "
            f"Add one there to define this HCLIMEXP experiment."
        )

    section = config[hclimexp]

    required = ("dir_surfex_sim_1d", "dir_surfex_sim_2d",
                "dir_surfex_ref_2d", "file_surfex_ref_2d", "dir_surfex_month")
    missing = [k for k in required if section.get(k) is None]
    if missing:
        raise KeyError(f"[{hclimexp}] in {path} is missing required key(s): {missing}")

    return {
        "dir_surfex_sim_1d": section.get("dir_surfex_sim_1d"),
        "dir_surfex_sim_2d": section.get("dir_surfex_sim_2d"),
        "dir_surfex_ref_2d": section.get("dir_surfex_ref_2d"),
        "file_surfex_ref_2d": section.get("file_surfex_ref_2d"),
        "dir_surfex_month": section.get("dir_surfex_month"),
        "ntile": section.getint("ntile", fallback=2),
        "mkdir_sim_2d": section.getboolean("mkdir_sim_2d", fallback=False),
    }


def get_simyear(surfex_exp, path=CONFIG_FILE):
    """Return the simulation year for surfex_exp, if config.ini's [simyear_of_exp] defines one."""
    config = _read_config(path)
    if "simyear_of_exp" not in config:
        return None
    return config["simyear_of_exp"].get(surfex_exp)

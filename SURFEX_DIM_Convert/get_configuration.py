
# Fuxing Wang, Rossby/SMHI, 5 July, 2019

#https://stackoverflow.com/questions/924700/best-way-to-retrieve-variable-values-from-a-text-file-python-json

import ConfigParser

def get_conf():
    config = ConfigParser.ConfigParser()
    config.read("config.ini")

    HCLIMEXP  = config.get("conf_surfex_dim_convert", "HCLIMEXP")
    SURFEXEXP = config.get("conf_surfex_dim_convert", "SURFEXEXP")
    name_surfex_file_list = (config.get("conf_surfex_dim_convert", "name_surfex_file")).split(',')

    return HCLIMEXP, SURFEXEXP, name_surfex_file_list



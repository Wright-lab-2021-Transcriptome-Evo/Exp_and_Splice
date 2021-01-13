#### TESTING DATA #####
infolder="stringtie_send_del"


#!/usr/bin/python2.6
# -*- coding: utf-8 -*-
''' Prepares prepDE from stringtie

'''
# ==============================================================================
import argparse
import sys
import numpy as np
import pandas as pd
import os
from collections import defaultdict

# ==============================================================================
# Command line options==========================================================
# ==============================================================================
parser = argparse.ArgumentParser()
parser.add_argument("infolder", type=str,
                    help="Infolder containing per sample folders of stringtie outputs incl. gtf files")
parser.add_argument("prepde", type=str,
                    help="Location of stringtie prepde.py file")
parser.add_argument("species_code", type=str,
                    help="code for identifying study species")

# This checks if the user supplied any arguments. If not, help is printed.
if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
#Shorten the access to command line arguments.
args = parser.parse_args()


# ==============================================================================
# Functions=====================================================================
# ==============================================================================
def list_folder(infolder):
    '''Returns a list of all files in a folder with the full path'''
    return [os.path.join(infolder, f) for f in os.listdir(infolder) if is_number(f)]


def list_files(current_dir):
    file_list = []
    for path, subdirs, files in os.walk(current_dir):  # Walk directory tree
        for name in files:
            if name.endswith("coord_sorted.bam"):
                f = os.path.join(path, name)
                file_list.append(f)
    return file_list


def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False


# ==============================================================================
# Main==========================================================================
# ==============================================================================
def main():
    infolders = list_folder(args.infolder)
    print("Number of infolders =", len(infolders))

    # Make summary text file of sample names and their gtf files
    gtfs=[]
    ids=[]
    for i in infolders:
        files=os.listdir(i)
        for file in files:
            if file.endswith("gtf"):
                gtfs = gtfs + [i + "/" + file]
                ids = ids + [file.split("_")[0]]
    summary_file = pd.DataFrame({'identifier':ids, 'gtf':gtfs})
    summary_file.to_csv(args.infolder + "/gtf_sample_summary.txt", header=False, index=False, sep ="\t")
    glist = args.infolder + "/" + args.species_code + "_gene_list.csv"
    tlist = args.infolder + "/" + args.species_code + "_transcript_list.csv"

    com = ("python " + args.prepde +
           " -i " + args.infolder +
           " -g " + glist +
           " -t " + tlist +
           " -l 95"
           )

    os.system(com)

if __name__ == "__main__":
    main()

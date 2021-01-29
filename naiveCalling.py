"""
Call naive genotypes from Beagle file and save to .tped-file.

argmax_G P(X | G)
"""

# Libraries
import numpy as np
import argparse

# Own script
import naiveCalling_cy

# Argparse
parser = argparse.ArgumentParser()
parser.add_argument("-beagle",
    help="Input Beagle file (.gz)")
parser.add_argument("-delta", type=float, default=0.0,
    help="Threshold for calling genotypes")
parser.add_argument("-threads", type=int, default=1,
    help="Number of threads")
parser.add_argument("-out", default="naive",
    help="Output filename")
args = parser.parse_args()

# Read Beagle file
L = naiveCalling_cy.readBeagle(args.beagle)
m = L.shape[0]
n = L.shape[1]//3
print("Loaded Beagle file: " + str(m) + " sites and " + str(n) + " individuals.")

# Call genotypes
G = np.zeros((m, n, 2), dtype=np.int8)
naiveCalling_cy.naiveCall(L, G, args.delta, args.threads)
G = G.reshape(m, -1)
del L
print("Called genotypes.")

# Save to .tfam-file
inds = np.arange(1, n+1, dtype=int)
with open(args.out + ".tfam", "w") as f:
    for i in range(n):
        f.write("ind" + str(i+1) + " ind" + str(i+1) + " 0 0 0 0\n")
print("Saved " + args.out + ".tfam.")

# Save to .tped-file
with open(args.out + ".tped", "w") as f:
    for s in range(m):
        f.write("1 1_" + str(s+1) + " 0 " + str(s+1) + " ")
        G[s].tofile(f, sep=" ")
        f.write("\n")
print("Saved " + args.out + ".tped.")

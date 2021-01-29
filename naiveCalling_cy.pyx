import os
import numpy as np
cimport numpy as np
from cython import boundscheck, wraparound
from cython.parallel import prange
from libcpp.vector cimport vector
from libc.string cimport strtok, strdup
from libc.stdlib cimport atof
from libc.math cimport fabs

DTYPE = np.float32
ctypedef np.float32_t DTYPE_t

# Read Beagle text format
@boundscheck(False)
@wraparound(False)
cpdef np.ndarray[DTYPE_t, ndim=2] readBeagle(str beagle):
    cdef int c = 0
    cdef int i, m, n, s
    cdef bytes line_bytes
    cdef str line_str
    cdef char* line
    cdef char* token
    cdef char* delims = "\t \n"
    cdef vector[vector[float]] L
    cdef vector[float] L_ind
    with os.popen("zcat " + beagle) as f:
        # Count number of individuals from first line
        line_bytes = str.encode(f.readline())
        line = line_bytes
        token = strtok(line, delims)
        while token != NULL:
            token = strtok(NULL, delims)
            c += 1
        n = (c - 3)

        # Add lines to vector
        for line_str in f:
            line_bytes = str.encode(line_str)
            line = line_bytes
            token = strtok(line, delims)
            token = strtok(NULL, delims)
            token = strtok(NULL, delims)
            for i in range(n):
                L_ind.push_back(atof(strtok(NULL, delims)))
            L.push_back(L_ind)
            L_ind.clear()
    m = L.size() # Number of sites
    cdef np.ndarray[DTYPE_t, ndim=2] L_np = np.empty((m, n), dtype=DTYPE)
    cdef float *L_ptr
    for s in range(m):
        L_ptr = &L[s][0]
        L_np[s] = np.asarray(<float[:n]> L_ptr)
    return L_np

# Genotype calling
@boundscheck(False)
@wraparound(False)
cpdef naiveCall(float[:,::1] L, signed char[:,:,::1] G, float d, int t):
    cdef int m = G.shape[0]
    cdef int n = G.shape[1]
    cdef int i, s
    with nogil:
        for s in prange(m, num_threads=t):
            for i in range(n):
                if fabs(L[s,3*i+0] - 0.333333) < 0.00001:
                    G[s,i,0] = 0
                    G[s,i,1] = 0
                else:
                    if (L[s,3*i+0] > L[s,3*i+1]) & (L[s,3*i+0] > L[s,3*i+2]):
                        if L[s,3*i+0] > d:
                            G[s,i,0] = 1
                            G[s,i,1] = 1
                        else:
                            G[s,i,0] = 0
                            G[s,i,1] = 0
                    elif (L[s,3*i+1] > L[s,3*i+2]):
                        if L[s,3*i+1] > d:
                            G[s,i,0] = 1
                            G[s,i,1] = 2
                        else:
                            G[s,i,0] = 0
                            G[s,i,1] = 0
                    else:
                        if L[s,3*i+2] > d:
                            G[s,i,0] = 2
                            G[s,i,1] = 2
                        else:
                            G[s,i,0] = 0
                            G[s,i,1] = 0

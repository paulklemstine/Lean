"""Shared NFS box + oracle, so E2b can reuse E2's data without re-running it."""
import numpy as np
from math import isqrt

AMAX, BMAX = 12_000, 530      # a^2 ~ 1.44e8, b^3 ~ 1.49e8, pairs = 6.36e6
M = int(1.6e8)
NP = AMAX * BMAX


def lpf_array(M):
    """lpf[n] = largest prime factor of n for n <= M.  n is B-smooth iff lpf[n]<=B."""
    lpf = np.zeros(M + 1, dtype=np.int32)
    lpf[1] = 1
    s = bytearray([1]) * (M + 1)
    s[0:2] = b"\x00\x00"
    for p in range(2, isqrt(M) + 1):
        if s[p]:
            s[p * p::p] = bytearray(len(s[p * p::p]))
    for p in range(2, M + 1):
        if s[p]:
            lpf[p::p] = p
    return lpf


def nfs_box(sign=-1):
    a = np.arange(1, AMAX + 1, dtype=np.int64)
    b = np.arange(1, BMAX + 1, dtype=np.int64)
    A2 = (a * a)[:, None]
    B3 = (b * b * b)[None, :]
    return (A2 - B3 if sign < 0 else A2 + B3).reshape(-1)
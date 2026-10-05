from sage.all_cmdline import *   # noqa
import time
# 1. Does the documented example fire at all in this build?
N = 10001
K = Zmod(N)
R = PolynomialRing(K, 'x', implementation='NTL')
f = R([ -222, 10, 10, 1 ])
print("docstring example small_roots():", f.small_roots())
print("has small_roots attr:", hasattr(f, 'small_roots'), type(f))

import time, random
from coppersmith import integer_roots, poly_eval
random.seed(1)
# small sanity
print(integer_roots([6,-5,1]))   # (x-2)(x-3)
# realistic size: a degree-24 poly with ~1000-bit coefficients
deg=24
co=[random.getrandbits(1000) for _ in range(deg)]+[1]
t=time.time()
try:
    r=integer_roots(co, -2**600, 2**600); print("big poly roots:",r,"%.2fs"%(time.time()-t))
except Exception as e: print("ERR",e,"%.2fs"%(time.time()-t))

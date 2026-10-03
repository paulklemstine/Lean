import time
from control import top_bits_instance
from coppersmith import univariate_small_roots
from coppersmith import DEFAULT_GRID
print("grid size",len(DEFAULT_GRID),"max dim",max(m+t for m,t in DEFAULT_GRID))
for frac in ((1,2),(1,4)):
    inst=top_bits_instance(256,1,*frac)
    t=time.time()
    roots,diag=univariate_small_roots([inst['a'],1],inst['N'],inst['X'],mod_is_factor=True,cross_check=False)
    print(frac,"roots=",roots[:1],"secs=%.1f"%(time.time()-t),"tried",len(diag.get('grid_tried',[])),flush=True)

import time
from control import top_bits_instance, run_case
for frac in ((1,2),(1,4)):
    for seed in (1,):
        inst=top_bits_instance(256,seed,*frac)
        t=time.time()
        ok,roots,diag=run_case(inst)
        print(frac,seed,"ok=",ok,"%.1fs"%(time.time()-t), "gridlen",len(diag.get('grid_tried',[])) if 'grid_tried' in diag else diag.get('m'))

import time
from control import top_bits_instance
from coppersmith import univariate_small_roots
for unk in (57,64):
    inst=top_bits_instance(256,1,1,2); p=inst['p']
    a=(p>>unk)<<unk; X=1<<unk
    t0=time.time()
    roots,diag=univariate_small_roots([a,1],inst['N'],X,mod_is_factor=True,cross_check=False)
    print("unk=%3d leak=%.1f%%  %.1fs roots=%s %s"%(unk,100*(1-unk/128),time.time()-t0,bool(roots),
      {k:diag.get(k) for k in ('m','t','dim','note','best_margin_bits') if k in diag}),flush=True)

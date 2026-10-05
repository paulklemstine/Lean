load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/sweep_core.sage')
import sys, json
def _py(o):
    """Coerce Sage Integers/Reals to plain python so json works."""
    if isinstance(o, dict):  return {str(k): _py(v) for k,v in o.items()}
    if isinstance(o, (list,tuple)): return [_py(v) for v in o]
    if isinstance(o, (int, float, str, bool)) or o is None: return o
    if o in ZZ: return int(o)
    try:  return float(o)
    except Exception: pass
    return str(o)
# usage: run_sweep.sage N alpha gamma b1 b2 m nseeds seed0 [outfile]
N  = int(sys.argv[1])
alpha = float(sys.argv[2]); gamma = float(sys.argv[3])
b1 = float(sys.argv[4]); b2 = float(sys.argv[5])
m  = int(sys.argv[6])
nseeds = int(sys.argv[7]); seed0 = int(sys.argv[8])
out = sys.argv[9] if len(sys.argv)>9 else None
rows=[]
for k in range(nseeds):
    seed = seed0 + k
    r = run_one(N, alpha, gamma, b1, b2, m, seed)
    if r is None:
        rows.append(dict(seed=int(seed), genfail=1)); continue
    rows.append(dict(seed=seed, ok=int(r["ok"]), why=r['why'], t=float(r["t"]),
                     latdim=list(r['latdim']), tp=r['t_'], sp=r['s_'],
                     qbits=r['qbits'], ncand=r.get('ncand',0),
                     verified=r.get('verified',False),
                     is_p2=(r.get('found')==r['p2'])))
    print(json.dumps(_py(rows[-1])), flush=True)
ok = sum(1 for x in rows if x.get('ok'))
gf = sum(1 for x in rows if x.get('genfail'))
print("SUMMARY N=%d alpha=%.2f gamma=%.2f b1=%.2f b2=%.2f m=%d : %d/%d verified (genfail %d)"
      % (N,alpha,gamma,b1,b2,m,ok,nseeds,gf))
if out:
    with open(out,'w') as fh: json.dump(_py(rows), fh)

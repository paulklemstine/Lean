# Q3: is GIFP asymptotically better than generic factoring, or only in a window?
# Generic factoring of a modulus whose SMALL factor is alpha*N bits is ECM,
# cost ~ exp(sqrt(2 ln q ln ln q)) = L[1/2, sqrt2](alpha*N). GIFP cost is
# poly(N) in the lattice dimension m. So compare measured wall-clock.
load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/sweep_core.sage')
N=int(sys.argv[1]); alpha=0.10; gamma=0.70; b1=0.10; b2=0.15
for m in [4,6,8]:
    ts=[]; oks=0
    for k in range(3):
        r = run_one(N, alpha, gamma, b1, b2, m, 9100000+k)
        if r is None: continue
        oks += int(r['ok']); ts.append(r['t'])
    if ts:
        print("N=%d m=%2d latdim=%s ok=%d/3 median_t=%.2fs (min %.2f max %.2f)"
              % (N, m, list(r['latdim']), oks, sorted(ts)[len(ts)//2], min(ts), max(ts)), flush=True)

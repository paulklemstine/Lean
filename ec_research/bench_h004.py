import sys, os, random, math, time, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import glv_rho
from batched_rho import pollard_rho as pollard_rho_batched

def maxops(bits, n):
    return 100000 if bits <= 20 else (300000 if bits <= 24 else 10000000)

def run(bits, instances):
    C = glv_rho.build_glv_curve(bits, seed=1000*bits+0)
    n = C.n
    print(f"bits={bits} n={n}", flush=True)
    out=[]
    for inst in range(instances):
        rng = random.Random(9999 + inst)
        d = rng.randrange(1, n)
        Q = C.mul(d, C.G)
        dp = max(2, min(10, n.bit_length()-12))
        W=64
        res_inst={'inst':inst}
        for variant in ('vanilla','neg','glv'):
            for impl_name,impl in (('affine', glv_rho.pollard_rho),('batched', pollard_rho_batched)):
                rrng = random.Random(55555 + inst*3 + 'vanilla neg glv'.split().index(variant))
                t0=time.perf_counter()
                dr, ops = impl(C, Q, dp_bits=dp, W=W, rng=rrng, max_ops=maxops(bits,n), variant=variant)
                t1=time.perf_counter()
                key=f"{variant}_{impl_name}"
                res_inst[key+"_ops"]=ops
                res_inst[key+"_ok"]= (dr==d)
                res_inst[key+"_time"]=t1-t0
        out.append(res_inst)
        print(f"  inst {inst}: " + " | ".join(
            f"{v}: aff ops={res_inst[v+'_affine_ops']} {res_inst[v+'_affine_ok']} t={res_inst[v+'_affine_time']:.4f}s ; bat ops={res_inst[v+'_batched_ops']} {res_inst[v+'_batched_ok']} t={res_inst[v+'_batched_time']:.4f}s"
            for v in ('vanilla','neg','glv')), flush=True)
    return C,n,out

allr={}
for bits,inst in ((20,40),(24,10),(36,5)):
    C,n,out=run(bits,inst)
    allr[bits]=(n,out)
    for variant in ('vanilla','neg','glv'):
        ao=[r[f'{variant}_affine_ops'] for r in out]
        bo=[r[f'{variant}_batched_ops'] for r in out]
        at=[r[f'{variant}_affine_time'] for r in out]
        bt=[r[f'{variant}_batched_time'] for r in out]
        aok=sum(r[f'{variant}_affine_ok'] for r in out)
        bok=sum(r[f'{variant}_batched_ok'] for r in out)
        meanao=sum(ao)/len(ao); meanbo=sum(bo)/len(bo)
        meanat=sum(at)/len(at); meanbt=sum(bt)/len(bt)
        speedup=meanat/meanbt if meanbt>0 else float('inf')
        print(f"  {variant}: affine succ={aok}/{len(out)} ops_mean={meanao:.0f} t_mean={meanat:.4f}s; batched succ={bok}/{len(out)} ops_mean={meanbo:.0f} t_mean={meanbt:.4f}s; ops_ratio bat/aff={meanbo/meanao:.4f} speedup aff/bat={speedup:.3f}x")
        per=[r[f'{variant}_affine_time']/r[f'{variant}_batched_time'] if r[f'{variant}_batched_time']>0 else 0 for r in out]
        print(f"       per-inst speedup mean={sum(per)/len(per):.3f} min={min(per):.3f} max={max(per):.3f}")

with open('ec_research/h004_results.json','w') as f:
    json.dump({str(k):{'n':allr[k][0],'data':allr[k][1]} for k in allr}, f, indent=1)
print("wrote h004_results.json")

import time, json, os
# Pollard rho ECDLP ladder for small prime curves (sanity/scaling).

LOGDIR = "/home/raver1975/lean/factor-scratch/r120/ecdlp-baseline"
os.makedirs(LOGDIR, exist_ok=True)

def find_curve(bits, seed):
    set_random_seed(int(seed))
    while True:
        p = int(next_prime(randint(1<<bits, (1<<(bits+1))-1)))
        if not is_prime(p): continue
        for _ in range(1000):
            a = randint(0, p-1); b = randint(0, p-1)
            try: E = EllipticCurve(GF(p), [a, b])
            except: continue
            n = int(E.order())
            if is_prime(n) and n > (1<<(bits-1)):
                while True:
                    x = randint(0, p-1)
                    try: pt = E.lift_x(x)
                    except: continue
                    if int(pt.order()) == n:
                        return p, a, b, n, int(pt[0]), int(pt[1]), E, pt

def rho_once(E, G, Q, n, seed_shift):
    set_random_seed(1000003 + int(seed_shift))
    ctr = [0]
    def addpt(P,pt):
        ctr[0]+=1; return P+pt
    def f(X, aa, bb):
        xr = int(X[0]) % 3
        if xr == 0:
            return addpt(X, G), (aa+1)%n, bb
        elif xr == 1:
            return addpt(X, Q), aa, (bb+1)%n
        else:
            return addpt(X, X), (2*aa)%n, (2*bb)%n
    x1,a1,bv1 = G, int(1)%n, 0
    x2,a2,bv2 = G, int(1)%n, 0
    steps = 0
    maxit = 2000000
    while steps < maxit:
        x1,a1,bv1 = f(x1,a1,bv1)
        x2,a2,bv2 = f(x2,a2,bv2)
        x2,a2,bv2 = f(x2,a2,bv2)
        steps += 1
        if x1 == x2:
            break
    from sage.all import inverse_mod
    den = (bv2 - bv1) % n
    ok = False; drec = None
    if den != 0:
        drec = int((a1 - a2) * inverse_mod(den, n) % n)
        ok = (drec == int(Qd_global))
    return steps, ctr[0], ok, drec

# global for target comparison in rho? We'll pass dtrue.
rho_results = []
for bits in [16, 20, 24, 28]:
    p,a,b,n,gx,gy,E,G = find_curve(bits, bits*37+9)
    print("CURVE", bits, "p bits", p.bit_length(), "n bits", n.bit_length(), flush=True)
    ntrials = 5
    ops_list = []
    step_list = []
    succ = 0
    for ti in range(ntrials):
        set_random_seed(bits*100 + ti)
        dtrue = randint(1, n-1)
        global Qd_global
        Qd_global = int(dtrue)
        Q = dtrue * G
        steps, ops, ok, drec = rho_once(E, G, Q, n, bits*100+ti)
        ops_list.append(int(ops))
        step_list.append(steps)
        if ok: succ += 1
        print(f"  trial {ti}: steps={steps} ops={ops} ok={ok}", flush=True)
        ops_mean = sum(ops_list)/len(ops_list)
    steps_mean = sum(step_list)/len(step_list)
    ops_med = sorted(ops_list)[len(ops_list)//2]
    rho_results.append(dict(bits=bits, nbits=n.bit_length(), n=int(n),
        ops_mean=float(ops_mean),
        ops_median=float(ops_med),
        steps_mean=float(steps_mean),
        succ=succ, ntrials=ntrials))
    json.dump(rho_results, open(os.path.join(LOGDIR,"pollard_rho_ladder.json"),"w"), indent=2, default=int)

print("\nBITS | nbits | mean_ops | median_ops | mean_steps | succ")
for r in rho_results:
    print(r["bits"], r["nbits"], r["ops_mean"], r["ops_median"], r["steps_mean"], r["succ"])
print("theoretical sqrt(pi n /2) ~", [ (3.14*n/2)**0.5 for n in [r["n"] for r in rho_results] ])

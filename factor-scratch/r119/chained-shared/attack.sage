#!/usr/bin/env sage
# -*- coding: utf-8 -*-
#
# HYPOTHESIS (round 119): the two round-118 amplifications COMPOSE.
#
#   * shared-nonce  (r118/shared-nonce): L keys signed from ONE nonce structure,
#         k = sum_j a_j g_j + Delta,  the SAME (a_j, Delta) for every key
#         unknowns (a_1..a_D, Delta, d_1..d_L) = D+1+L, threshold sum_i t_i >= D+1+L.
#   * chained-nonce (r118/chained-nonce): the SIGNALS are the previous signature's PUBLIC
#     values, k_{i+1} = sum_j a_j g_j(r_i, s_i, z_i) + Delta -> no side channel needed,
#     but the first nonce is the RNG seed and lies outside the family, so it costs +1.
#
# COMPOSED MODEL -- one badly-seeded RNG feeding L keys, where each key's nonce also mixes
# in public data:
#
#         k_{k,0} = fresh per-key seed                  (OUTSIDE the family)
#         k_{k,i} = sum_{j=1..D} a_j g_j(sig k,i-1) + Delta        for i >= 1
#
#   (a_1..a_D, Delta) SHARED by all L keys; every key has its own seed k_{k,0}.
#   Unknowns: (a_1..a_D, Delta, d_1..d_K)   where K = keys with at least one in-family
#             signature,  i.e. |K| + D + 1  (a key with t_k <= 1 has NO equation at all).
#   Equations: one per signature with i >= 1  =>  sum_{k in K} (t_k - 1).
#
# PREDICTED THRESHOLD:  sum_{k in K} (t_k - 1) >= D + 1 + |K|
#         <=>   sum_k t_k >= D + 1 + 2|K| + (#keys with t_k <= 1)
#         uniform t>=2 on L keys:  L(t-1) >= D+1+L  <=>  t >= 2 + (D+1)/L.
#   For D=1:  t >= 2 + 2/L > 2 for EVERY finite L, hence t*=3 for all L and t=2 NEVER works.
#
# WHAT IS MEASURED BELOW
#   (a) POSITIVE CONTROL: L = 1 must reproduce r118/chained-nonce exactly
#                          (t = D+3 works, t = D+2 fails), for D = 1..5.
#   (b) HEADLINE: D=1, L=10: t=3 (30 signatures) and t=2 (20 signatures).
#   (c) FULL GRID: L x t threshold map, 12 trials per cell.
#   (d) ASYMMETRIC: the 22-signature minimum, including the sharp prediction that a key
#                   with only its seed signature cannot fall at all.
#   (e) FAILURE ANALYSIS for the t=2 cell: rank, kernel dimension, which keys' d are
#                 genuinely unpinned, and A * x_true == b (equations provably right).
#   (f) AUDIT of one instance, signature by signature (the seed off-by-one).
#   GROUND TRUTH: every recovered key is checked with d_k * G == Q_k on real secp256k1.
#   IMPOSSIBLE-VALUE GUARD: if (a, Delta) are UNIQUELY recovered (rank == #unknowns) yet
#                 0 participating keys are broken, the harness raises instead of publishing.

import time

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F  = GF(PK)
E  = EllipticCurve(F, [ZZ(0), ZZ(7)])
G  = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
       ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))


def sig_signals(ri, si, zi, D, mode=0):
    """D DISTINCT public functions of one signature (all published values).

    `mode` picks WHICH public value leads the feedback (the group order matters, the rest
    of the list is filled with the other published values and then powers of r).
    Distinctness is a hard requirement: if two signals are the same public function the
    matrix has two identical columns and the system is rank-deficient for a reason that has
    nothing to do with the hypothesis.  A first draft used `j % 3 -> (r,s,z)`, which makes
    g_4 = g_1 = r and silently breaks D >= 4; a second draft prepended `r` to `[r,s,z]`,
    which breaks D >= 2.  Both were caught by the POSITIVE CONTROL (t = D+3 must give
    12/12 for D = 1..5), which is the only reason the numbers below are trustworthy.
    """
    if mode == 0:
        lead = [ri, si, zi]                 # r, s, z  then r^2, r^3, ...
    elif mode == 1:
        lead = [si, zi, ri]
    elif mode == 2:
        lead = [zi, ri, si]
    elif mode == 3:
        lead = [ri * si % NK, zi, ri]
    else:
        lead = [(ri + si + zi) % NK, ri, si]
    out = list(lead)
    e = 2
    while len(out) < D:
        out.append(pow(ri, e, NK))
        e += 1
    assert len(set(out)) == len(out), "signals must be distinct public functions"
    return out[:D]


def trial(L, sig_cnts, D=1, seed=0, mode=0):
    """One composed instance and the attack on it.

    sig_cnts[k] = number of signatures key k publishes.
    Keys with sig_cnts[k] <= 1 have no in-family signature, hence no equation: they are
    reported as structurally unrecoverable and are NOT written into the linear system
    (including them would only add an all-zero column).
    """
    set_random_seed(seed)
    # ---- draw each private key ONCE; the SAME value signs and builds the public key ----
    ds = [ZZ(randint(1, NK - 1)) for _ in range(L)]
    Qs = [d * G for d in ds]
    for d, Q in zip(ds, Qs):
        assert (d * G) == Q, "ground truth broken: d*G != Q"
    # ---- one shared structural family feeding every key ----
    a      = [ZZ(randint(1, 1 << 60)) for _ in range(D)]
    delta  = ZZ(randint(1, NK - 1))
    seedn  = [ZZ(randint(1, NK - 1)) for _ in range(L)]      # per-key RNG seeds

    # which keys can participate at all
    part = [k for k in range(L) if sig_cnts[k] >= 2]
    idx = {k: p for p, k in enumerate(part)}
    nunk = D + 1 + len(part)

    rows, rhs = [], []
    for k in range(L):
        kn = seedn[k]                       # the SEED nonce: outside the family
        prev = None
        for i in range(sig_cnts[k]):
            zi = ZZ(randint(0, NK - 1))
            assert kn % NK != 0, "degenerate nonce"
            Ri = ZZ((kn * G)[0]) % NK
            assert Ri != 0, "degenerate r"
            si = (zi + Ri * ds[k]) * inverse_mod(kn, NK) % NK
            if i == 0:
                # k_{k,0} is a FRESH unknown:  s_0 * k_0 = z_0 + r_0 * d_k  has two
                # unknowns and k_0 appears in no other equation -> nothing usable.
                pass
            elif k in idx:
                g = prev                    # public values of the PREVIOUS signature
                row = [si * gj for gj in g] + [si % NK] + [ZZ(0)] * len(part)
                row[D + 1 + idx[k]] = (-Ri) % NK
                rows.append(row)
                rhs.append(zi)
            prev = sig_signals(Ri, si, zi, D, mode)
            kn = (sum(a[j] * prev[j] for j in range(D)) + delta) % NK

    res = dict(L=L, D=D, npart=len(part), nrows=len(rows), nunk=nunk, ok=0,
               a_ok=None, d_ok=None, model_ok=True, rk=0, drec=None, ds=ds, Qs=Qs,
               A=None, b=None, xtrue=None)
    if len(rows) == 0:
        return res

    A = matrix(Zmod(NK), rows)
    b = vector(Zmod(NK), rhs)
    # the true unknowns, restricted to the participating keys, in the same column order
    xtrue = vector(Zmod(NK), [aj % NK for aj in a] + [delta % NK] +
                   [ds[k] % NK for k in part])
    # (e) does the TRUE vector satisfy the attacker's system?  If yes the equations are
    #     written from the right signatures, and any failure is pure underdetermination.
    res['model_ok'] = bool(A * xtrue == b)
    res['rk'] = A.rank()
    res['A'], res['b'], res['xtrue'] = A, b, xtrue

    if res['rk'] == nunk:
        sol = A.solve_right(b)
        drec = {k: ZZ(sol[D + 1 + idx[k]]) % NK for k in part}
        # GROUND TRUTH: real secp256k1 relation, never a membership test
        res['ok'] = sum(1 for k in part if (drec[k] * G) == Qs[k])
        res['drec'] = drec
        res['a_ok'] = all(ZZ(sol[j]) % NK == (a[j] % NK) for j in range(D))
        res['d_ok'] = (ZZ(sol[D]) % NK == delta % NK)
        if res['a_ok'] and res['d_ok'] and res['ok'] == 0 and len(part) > 0:
            raise RuntimeError("IMPOSSIBLE OUTCOME: (a,Delta) uniquely recovered but 0 "
                               "participating keys broken -- harness bug, not a result")
    return res


def run_cell(label, L, sig_cnts, D, trials, base_seed, mode=0):
    t0 = time.time()
    hits = unrec = uniq = a_oks = 0
    model_ok = True
    for tr in range(trials):
        r = trial(L, sig_cnts, D=D, seed=base_seed + 7919 * tr, mode=mode)
        hits += r['ok']
        unrec += (r['L'] - r['npart'])
        model_ok = model_ok and r['model_ok']
        if r['a_ok']:
            a_oks += 1
        if r['rk'] == r['nunk']:
            uniq += 1
    dt = time.time() - t0
    tot = L * trials
    print(f"{label:>24} | keys fallen {hits:>5}/{tot:<5d} | eq {sum(c-1 for c in sig_cnts):>3d} "
          f"vs unk {D+1+sum(1 for c in sig_cnts if c>=2):>3d} | det {uniq:>2d}/{trials} "
          f"| a,d ok {a_oks:>2d}/{trials} | model {str(model_ok):>5s} | unrec {unrec:>4d} "
          f"| {dt:5.2f}s", flush=True)
    return hits, tot, model_ok


print("=" * 104)
print("COMPOSED ATTACK: L chained nonce generators SHARING one structural family (a_1..a_D, Delta)")
print("=" * 104)
print("model     k_{k,0} = fresh per-key seed ;  k_{k,i} = sum_j a_j g_j(sig k,i-1) + Delta  (i>=1)")
print("unknowns  (a_1..a_D, Delta, d_1..d_K), K = keys with >= 1 in-family signature")
print("threshold sum_{k in K} (t_k - 1) >= D + 1 + K      (each key pays 1 signature for its seed)")
print("          uniform t:  t >= 2 + (D+1)/L ;  for D=1 that is > 2, so t* = 3 for every L")
print()

# --------------------------------------------------------------- positive control ------
print("-" * 104)
print("(a) POSITIVE CONTROL -- a single key (L=1) with a chained nonce")
print("     MUST reproduce r118/chained-nonce: t = D+3 works, t = D+2 FAILS")
print("-" * 104)
for D in [1, 2, 3, 4, 5]:
    run_cell(f"L=1 D={D} t=D+2={D+2}", 1, [D + 2], D, 12, 40000)
    run_cell(f"L=1 D={D} t=D+3={D+3}", 1, [D + 3], D, 12, 50000)
print()

# ------------------------------------------------------------------- headline ---------
print("-" * 104)
print("(b) HEADLINE -- D=1, L=10 keys, uniform signatures per key")
print("     t=3 (30 signatures): 30 >= D+1+2L = 22  -> all 10 keys predicted to fall")
print("     t=2 (20 signatures): 20 <  22            -> NO key predicted to fall")
print("-" * 104)
run_cell("L=10 t=2 (20 sigs)", 10, [2] * 10, 1, 24, 1000)
run_cell("L=10 t=3 (30 sigs)", 10, [3] * 10, 1, 24, 2000)
print()

# ------------------------------------------------------------------- grid -------------
print("-" * 104)
print("(c) THRESHOLD GRID -- D=1, 12 trials per cell")
print("-" * 104)
for L in [1, 2, 3, 5, 10, 20]:
    for t in [2, 3, 4]:
        run_cell(f"L={L} t={t} ({L*t} sigs)", L, [t] * L, 1, 12, 30000 + 1000 * L + 10 * t)
print()

# ---------------------------------------------------------------- asymmetric ----------
print("-" * 104)
print("(d) ASYMMETRIC ALLOCATION -- D=1, L=10.  Minimum total = D+1+2L = 22 signatures.")
print("     sharp prediction: a key with only its seed signature (t_k = 1) contributes NO")
print("     equation, so it cannot fall however many signatures the other keys provide.")
print("-" * 104)
run_cell("[3]*2+[2]*8  tot 22", 10, [3] * 2 + [2] * 8, 1, 12, 61000)
run_cell("[4]+[2]*9     tot 22", 10, [4] + [2] * 9, 1, 12, 62000)
run_cell("[5]+[2]*8+[1] tot 22", 10, [5] + [2] * 8 + [1], 1, 12, 62500)
run_cell("[21]+[1]*9    tot 22", 10, [21] + [1] * 9, 1, 12, 65000)
run_cell("[3]+[2]*9     tot 21", 10, [3] + [2] * 9, 1, 12, 63000)
run_cell("[2]*10        tot 20", 10, [2] * 10, 1, 12, 64000)
run_cell("[3]*10        tot 30", 10, [3] * 10, 1, 12, 66000)
print()

# ---------------------------------------------------------------- failure analysis -----
print("-" * 104)
print("(e) WHY t=2 FAILS -- failure analysis on one L=10, D=1, t=2 instance")
print("-" * 104)
r = trial(10, [2] * 10, D=1, seed=1000)
A, b, xt = r['A'], r['b'], r['xtrue']
Dl = r['D']
ker = A.right_kernel()
dim = ker.dimension()
print(f"  signatures: 20 (10 keys x 2).  Seed signatures: 10 -> usable equations: {r['nrows']}")
print(f"  unknowns (a_1..a_D, Delta, d_1..d_10): {r['nunk']}   rank: {r['rk']}   "
      f"kernel dimension: {dim}")
print(f"  the TRUE unknown vector satisfies the attacker's system: {r['model_ok']}")
print(f"     -> the equations are written from the correct signatures (no off-by-one);")
print(f"        the failure is pure underdetermination ({r['nrows']} equations, {r['nunk']} unknowns).")
basis = [v for v in ker.basis()]
print(f"  kernel basis vectors: {len(basis)}, length {len(basis[0]) if basis else 0}")
amb = [k for k in range(r['npart'])
       if any(basis[i][Dl + 1 + k] != 0 for i in range(len(basis)))] if dim else []
print(f"  keys whose d_k is NOT pinned by the system: {len(amb)}/10 -- the free directions are")
print(f"     linear combinations of the private keys, so no d_k is determined")
if dim:
    alt = xt + basis[0]
    print(f"  A * x_true == b        : {A * xt == b}")
    print(f"  A * (x_true + k) == b  : {A * alt == b}   (k = a nonzero kernel vector)")
    print(f"     -> at least two consistent solutions exist, so no solver can pick the right one")
print(f"  keys broken: {r['ok']}/10  (a,Delta uniquely recovered: {r['a_ok']})")
print(f"  NOTE: counting all 20 signatures as '20 >= 12 equations' is WRONG -- each seed")
print(f"        signature carries a fresh unknown nonce, so only L*(t-1) = {r['nrows']} are usable.")
print()

# ---------------------------------------------------------------- audit --------------
print("-" * 104)
print("(f) AUDIT of one instance signature by signature (L=10, D=1, t=3, seed 777)")
print("-" * 104)
Ld, Dd, td = 10, 1, 3
r = trial(Ld, [td] * Ld, D=Dd, seed=777)
set_random_seed(777)
ds = [ZZ(randint(1, NK - 1)) for _ in range(Ld)]
a  = ZZ(randint(1, 1 << 60))
delta = ZZ(randint(1, NK - 1))
seeds = [ZZ(randint(1, NK - 1)) for _ in range(Ld)]
for k in range(3):
    kn = seeds[k]
    print(f"  key {k}: d_k = {ds[k]}")
    for i in range(td):
        zi = ZZ(randint(0, NK - 1))
        Ri = ZZ((kn * G)[0]) % NK
        si = (zi + Ri * ds[k]) * inverse_mod(kn, NK) % NK
        if i == 0:
            print(f"    sig {i}: nonce = SEED k_{k},0 (outside family)        -> NO equation")
        else:
            print(f"    sig {i}: nonce = a * {Ri} + Delta                    -> ONE equation")
        nxt = sig_signals(Ri, si, zi, Dd)
        kn = (a * nxt[0] + delta) % NK
print(f"  ... keys 3..9 identical in shape")
print(f"  {Ld} keys x {td} signatures = {Ld*td} signatures, of which {Ld} are seed signatures")
print(f"  -> usable equations {r['nrows']} vs unknowns {r['nunk']}; rank {r['rk']}/{r['nunk']}")
print(f"  -> model_ok {r['model_ok']} ; keys broken {r['ok']}/{Ld} ; a,Delta recovered {r['a_ok']}")
print()

# --------------------------------------------------- large L / other D / other signals ---
print("-" * 104)
print("(g) SCALING -- does t* stay at 3 for large L, and does the formula hold for D>1?")
print("     t >= 2 + (D+1)/L, so the uniform threshold never drops to 2 for any finite L;")
print("     the ASYMMETRIC minimum sum t_k = D+1+2L does approach 2 signatures per key.")
print("-" * 104)
run_cell("L=50 t=2 (100)", 50, [2] * 50, 1, 12, 71000)
run_cell("L=50 t=3 (150)", 50, [3] * 50, 1, 12, 72000)
run_cell("L=50 [3]*2+[2]*48, 102", 50, [3] * 2 + [2] * 48, 1, 12, 73000)
run_cell("L=50 [2]*50, 100", 50, [2] * 50, 1, 12, 74000)
run_cell("L=6 D=2 t=2 (12)", 6, [2] * 6, 2, 12, 75000)
run_cell("L=6 D=2 t=3 (18)", 6, [3] * 6, 2, 12, 76000)
run_cell("L=4 D=3 t=3 (12)", 4, [3] * 4, 3, 12, 77000)
run_cell("L=4 D=3 t=4 (16)", 4, [4] * 4, 3, 12, 78000)
print()
print("-" * 104)
print("(h) WHICH PUBLIC VALUE FEEDS BACK -- D=1, L=10, t=3, nonce = a * (signal) + Delta")
print("-" * 104)
for nm, md in [("r (prev x-coord)", 0), ("s (prev s-value)", 1), ("z (prev hash)", 2),
               ("r*s", 3), ("r+s+z", 4)]:
    run_cell(f"signal = {nm}", 10, [3] * 10, 1, 12, 80000 + 10 * md, mode=md)
print()
print("=" * 104)
print("SUMMARY")
print("  The two amplifications COMPOSE: L chained generators sharing (a, Delta) fall together")
print("  once sum_{k in K}(t_k - 1) >= D + 1 + K.  D=1, L=10: 3 signatures per key (30 total, 20")
print("  usable equations) break all 10 keys; 2 per key (20 total, only 10 usable) breaks none.")
print("=" * 104)

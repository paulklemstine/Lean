# =====================================================================
#  ph_requested.sage -- measure the PH column at the smallest cells of
#  the REQUESTED grid (s in {20,40,60}, b in {40,60,80,100,120}) that
#  are actually computable: (20,40) and (40,40).
#  (The generic BSGS baseline at those cells is 2^30 / 2^40 group ops,
#  which is NOT computable here -- it comes from the calibrated model
#  in ph_analyze.py.  This script exists so that at least the PH side of
#  two requested cells is a real measurement, not an extrapolation.)
# =====================================================================
import time, json, os
from math import gcd, log as pylog
from random import Random as PyRandom

LOGDIR = "/home/raver1975/lean/factor-scratch/r115/ph-exchange-rate/logs"

def log2(x):
    return pylog(x, 2.0)

def dbl_add(a, k, n):
    ops = 0
    result = 0
    base = a % n
    kk = int(k)
    while kk > 0:
        if kk & 1:
            result = (result + base) % n; ops += 1
        kk >>= 1
        if kk > 0:
            base = (base + base) % n; ops += 1
    return result % n, ops

def bsgs(n, gen, h, order):
    ops = 0
    m = 1
    while m * m < order:
        m += 1
    baby = {}
    cur = 0
    for j in range(m):
        baby[cur] = j
        cur = (cur + gen) % n
        ops += 1
    baby_ops = ops
    mgen, o2 = dbl_add(gen, m, n)
    ops += o2
    neg = (n - mgen) % n
    gamma = h % n
    steps = 0
    while steps < m:
        if gamma in baby:
            return (steps * m + baby[gamma]) % order, ops, (m, baby_ops, ops - baby_ops, steps + 1)
        gamma = (gamma + neg) % n
        ops += 1
        steps += 1
    return None, ops, (m, baby_ops, ops - baby_ops, steps)

def crt_pair(a1, m1, a2, m2):
    assert gcd(m1, m2) == 1
    u = ((a2 - a1) % m2) * inverse_mod(int(m1), int(m2)) % m2
    return (a1 + m1 * u) % (m1 * m2)

def solve_ph(n, gen, h, s, q):
    ops = 0
    gen1, o = dbl_add(gen, q, n);      ops += o
    h1,   o = dbl_add(h,   q, n);      ops += o
    x1, o, d1 = bsgs(n, gen1, h1, 1 << s); ops += o
    gen2, o = dbl_add(gen, 1 << s, n); ops += o
    h2,   o = dbl_add(h,   1 << s, n); ops += o
    x2, o, d2 = bsgs(n, gen2, h2, q);    ops += o
    return crt_pair(x1, 1 << s, x2, q), ops, d1, d2


def bsgs_expected(order):
    """Closed-form expected op count of one BSGS solve (see ph_exchange.sage)."""
    order = int(order)
    m = 1
    while m * m < order:
        m += 1
    L, r = divmod(order, m)
    S = m * L * (L - 1) // 2 + (L * r if r else 0)
    return m + dbladd_ops(m) + S / float(order)


def dbladd_ops(k):
    k = int(k)
    return 0 if k <= 0 else bin(k).count("1") + k.bit_length() - 1


def ph_expected(s, q):
    return (bsgs_expected(1 << s) + bsgs_expected(int(q))
            + dbladd_ops(q) * 2 + dbladd_ops(1 << s) * 2)


def ph_expected_single(s, b):
    return ph_expected(s, (1 << b) - 1)

def rand_prime_bits(rng, b):
    while True:
        c = rng.getrandbits(b) | (1 << (b - 1)) | 1
        if c >= (1 << b):
            continue
        if is_prime(c):
            return int(c)

MASTER = 1152040
points = [(20, 40), (40, 40)]
seeds = 12
rng = PyRandom(int(MASTER))
out = []
for (s, b) in points:
    p2 = 1 << s
    per = []
    t0all = time.time()
    for it in range(seeds):
        q = rand_prime_bits(rng, b)
        nn = p2 * q
        g = 0
        while True:
            g = rng.randrange(2, nn)
            if gcd(g, nn) == 1:
                break
        d = rng.randrange(0, nn)
        h = (d * g) % nn
        x, ops, d1, d2 = solve_ph(nn, g, h, s, q)
        ok = (x is not None) and ((x * g) % nn == h) and (x == d)
        per.append(dict(s=s, b=b, q=q, n=nn, ph_ops=int(ops), ok=bool(ok),
                        m1=int(d1[0]), m2=int(d2[0]), g1=int(d1[3]), g2=int(d2[3])))
    dt = time.time() - t0all
    mn = float(sum(p["ph_ops"] for p in per)) / float(seeds)
    mx = max(p["ph_ops"] for p in per)
    rec = dict(s=int(s), b=int(b), n_bits=int(s + b), seeds=int(seeds),
               ph_mean=mn, ph_max=int(mx), ph_min=int(min(p["ph_ops"] for p in per)),
               wall=float(dt),
               all_ok=bool(all(p["ok"] for p in per)), per=per)
    out.append(rec)
    qavg = sum(ph_expected(s, p["q"]) for p in per) / float(seeds)
    single = ph_expected_single(s, b)
    print("s=%3d b=%3d nbits=%3d | PH MEASURED mean=%14.1f max=%9d ok=%s"
          % (s, b, rec["n_bits"], mn, mx, rec["all_ok"]), flush=True)
    print("      PH model on the SAME %d measured q's: %14.1f (rel.err %+.2f%%)"
          % (seeds, qavg, 100.0 * (qavg - mn) / mn), flush=True)
    print("      PH model on the single largest q = 2^b-1: %14.1f  (the measured q's"
          " are uniform in [2^(b-1),2^b), so the q-averaged model is the right"
          " comparator -- see STEP 7 of logs/analysis.txt)" % float(single), flush=True)

def _clean(o):
    if isinstance(o, dict):
        return dict((str(k), _clean(v)) for k, v in o.items())
    if isinstance(o, (list, tuple)):
        return [_clean(v) for v in o]
    if isinstance(o, bool):
        return o
    if isinstance(o, float):
        return o
    try:
        return int(o)
    except Exception:
        pass
    try:
        return float(o)
    except Exception:
        pass
    return str(o)

json.dump(_clean(out), open(os.path.join(LOGDIR, "ph_requested.json"), "w"), indent=1)
print("wrote", os.path.join(LOGDIR, "ph_requested.json"))
print("")
print("NOTE: the generic BSGS baseline at (20,40) is 2^30.58 group ops and at (40,40)")
print("      is 2^40.58.  Neither is computable in this harness (2^30.58 ~ 1.6e9 modular")
print("      additions x 12 seeds), so those cells use the DERIVED-AND-VALIDATED generic")
print("      model of ph_analyze.py.  Only the PH column above is a direct measurement.")

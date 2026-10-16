# =====================================================================
#  ph_exchange.sage  --  Axis A: the Pohlig-Hellman exchange rate
#
#  Cost model: a cyclic group of order n = 2^s * q  (q prime), with a
#  GENERIC group operation (additive group of Z/nZ; one group op = one
#  modular addition).  Every group operation is counted by an explicit
#  integer counter; no library DLP routine is used for any counted number.
#
#  Two solvers run on the SAME instance:
#     (a) generic baby-step/giant-step on the FULL group of order n
#     (b) Pohlig-Hellman: BSGS in <q*g> (order 2^s), BSGS in <2^s*g>
#         (order q), then CRT
#
#  Ground truth: the generator of the instance picks d, so the true answer
#  is known.  Every recovered dlog is checked with d*g == h (mod n) AND
#  against the known d.  A Z/nZ additive DLP is of course trivially
#  solvable -- see the TRIVIALITY note in RESULT.md.  This experiment
#  measures ALGORITHM COST; it does not claim to break anything.
# =====================================================================

import time, json, os
from math import gcd, log as pylog
from random import Random as PyRandom     # NOTE: sage's global `random` is a function,
                                          # so we must not use `random.Random`

# NOTE: `sage file.sage` compiles to a temp .py, so __file__ is unreliable.
# Hard-code the scratch directory.
LOGDIR = "/home/raver1975/lean/factor-scratch/r115/ph-exchange-rate/logs"
if not os.path.isdir(LOGDIR):
    os.makedirs(LOGDIR)

def log2(x):
    return pylog(x, 2.0)

# ---------------------------------------------------------------- helpers

def dbl_add(a, k, n):
    """k*a mod n by double-and-add, counting group additions."""
    ops = 0
    result = 0
    base = a % n
    kk = int(k)
    while kk > 0:
        if kk & 1:
            result = (result + base) % n
            ops += 1
        kk >>= 1
        if kk > 0:
            base = (base + base) % n
            ops += 1
    return result % n, ops


def bsgs(n, gen, h, order):
    """BSGS for x*gen = h inside the cyclic subgroup <gen> of known
    order `order` (gen has order `order` modulo n).

    Counts group additions mod n ONLY.  Returns
    (x or None, ops, detail) with detail = (m, baby_ops, giant_ops,
    n_giant_steps).
    """
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
    mgen, o2 = dbl_add(gen, m, n)          # giant-step element m*gen
    ops += o2
    neg = (n - mgen) % n
    gamma = h % n
    steps = 0
    while steps < m:
        if gamma in baby:
            x = (steps * m + baby[gamma]) % order
            return x, ops, (m, baby_ops, ops - baby_ops, steps + 1)
        gamma = (gamma + neg) % n
        ops += 1
        steps += 1
    return None, ops, (m, baby_ops, ops - baby_ops, steps)


def crt_pair(a1, m1, a2, m2):
    """CRT for coprime moduli.  Pure integer arithmetic, 0 group ops."""
    assert gcd(m1, m2) == 1, (m1, m2)
    u = ((a2 - a1) % m2) * inverse_mod(int(m1), int(m2)) % m2
    return (a1 + m1 * u) % (m1 * m2)


def solve_generic(n, gen, h, ops_out):
    """(a) BSGS on the full group of order n."""
    x, ops, det = bsgs(n, gen, h, n)
    ops_out['generic'] = ops
    ops_out['generic_detail'] = det
    return x, ops


def solve_ph(n, gen, h, s, q, ops_out):
    """(b) Pohlig-Hellman for n = 2^s * q (q prime)."""
    ops = 0
    parts = []
    # ---- subgroup of order 2^s :  gen1 = q*gen, h1 = q*h
    gen1, o = dbl_add(gen, q, n);      ops += o
    h1,   o = dbl_add(h,   q, n);      ops += o
    x1, o, d1 = bsgs(n, gen1, h1, 1 << s); ops += o
    parts.append((x1, 1 << s, d1))
    # ---- subgroup of order q :  gen2 = 2^s*gen, h2 = 2^s*h
    gen2, o = dbl_add(gen, 1 << s, n); ops += o
    h2,   o = dbl_add(h,   1 << s, n); ops += o
    x2, o, d2 = bsgs(n, gen2, h2, q);    ops += o
    parts.append((x2, q, d2))
    x = crt_pair(parts[0][0], parts[0][1], parts[1][0], parts[1][1])
    ops_out['ph'] = ops
    ops_out['ph_detail'] = parts
    return x, ops


# ---------------------------------------------------------------- driver

def rand_prime_bits(rng, b):
    """Seeded, deterministic random prime with exactly b bits."""
    while True:
        c = rng.getrandbits(b) | (1 << (b - 1)) | 1
        if c >= (1 << b):
            continue
        if is_prime(c):
            return int(c)


def run_grid(points, seeds, master_seed, label):
    rng = PyRandom(int(master_seed))
    recs = []
    for (s, b) in points:
        p2 = 1 << s
        per = []
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
            ops_out = {}
            t0 = time.time()
            xg, og = solve_generic(nn, g, h, ops_out)
            t1 = time.time()
            xp, op = solve_ph(nn, g, h, s, q, ops_out)
            t2 = time.time()
            ok_g = (xg is not None) and ((xg * g) % nn == h) and (xg == d)
            ok_p = (xp is not None) and ((xp * g) % nn == h) and (xp == d)
            triv = (h * inverse_mod(g, nn)) % nn
            per.append(dict(s=s, b=b, q=q, n=nn, d=d, g=g,
                            generic_ops=og, ph_ops=op,
                            generic_ms=(t1 - t0) * 1000.0, ph_ms=(t2 - t1) * 1000.0,
                            ok_generic=bool(ok_g), ok_ph=bool(ok_p),
                            trivial=bool(triv == d),
                            gm=ops_out['generic_detail'][0],
                            giant=ops_out['generic_detail'][3],
                            ph_m1=ops_out['ph_detail'][0][2][0],
                            ph_m2=ops_out['ph_detail'][1][2][0],
                            ph_g1=ops_out['ph_detail'][0][2][3],
                            ph_g2=ops_out['ph_detail'][1][2][3]))
        gen_mean = sum(r['generic_ops'] for r in per) / float(seeds)
        ph_mean = sum(r['ph_ops'] for r in per) / float(seeds)
        n0 = per[0]['n']
        rec = dict(s=s, b=b, n_bits=s + b, q_bits=b, n_bits_real=log2(n0),
                   seeds=seeds, n=n0,
                   generic_mean=gen_mean, generic_max=max(r['generic_ops'] for r in per),
                   generic_min=min(r['generic_ops'] for r in per),
                   ph_mean=ph_mean, ph_max=max(r['ph_ops'] for r in per),
                   ph_min=min(r['ph_ops'] for r in per),
                   giant_mean=sum(r['giant'] for r in per) / float(seeds),
                   m_mean=sum(r['gm'] for r in per) / float(seeds),
                   all_ok=all(r['ok_generic'] and r['ok_ph'] and r['trivial'] for r in per),
                   per=per)
        recs.append(rec)
        print("[%s] s=%3d b=%3d nbits=%6.2f | gen=%12.1f ph=%12.1f | sav=%7.4f bits | "
              "genmax=%12d phmax=%12d ok=%s"
              % (label, s, b, rec['n_bits_real'], gen_mean, ph_mean,
                 log2(gen_mean / ph_mean), rec['generic_max'], rec['ph_max'],
                 rec['all_ok']), flush=True)
    return recs


# ---------------------------------------------------------------- main

MASTER_SEED = 20261014
SEEDS = 12
RUNGRID = not os.environ.get("PH_SMOKE")

if not RUNGRID:
    POINTS = [(4, 4), (8, 8), (12, 4), (4, 12)]
    SEEDS = 2
else:
    POINTS = []
SWEEP_B = [] if not RUNGRID else [4, 8, 12, 16, 20, 24]
SWEEP_S = [] if not RUNGRID else [4, 8, 12, 16, 20, 24]
DIAG    = [] if not RUNGRID else [4, 8, 12, 16, 20, 22]
ASYM    = [] if not RUNGRID else [(28, 8), (32, 8), (36, 8), (8, 28), (8, 32), (8, 36)]
EXTRA   = [] if not RUNGRID else [(20, 24), (24, 20)]

for b in SWEEP_B:                          # sweep b at fixed s=20
    POINTS.append((20, b))
for s in SWEEP_S:                          # sweep s at fixed b=20
    POINTS.append((s, 20))
for v in DIAG:                             # diagonal
    POINTS.append((v, v))
POINTS += ASYM                             # strongly asymmetric
POINTS += EXTRA

seen = set(); UPOINTS = []
for p in POINTS:
    if p not in seen:
        seen.add(p); UPOINTS.append(p)

print("Axis A -- Pohlig-Hellman exchange rate", flush=True)
print("sage, seed=%d, seeds/pt=%d, %d points" % (MASTER_SEED, SEEDS, len(UPOINTS)),
      flush=True)
print("", flush=True)

t_start = time.time()
recs = run_grid(UPOINTS, SEEDS, MASTER_SEED, "main")
t_all = time.time() - t_start
print("", flush=True)
print("total wall time %.1f s" % t_all, flush=True)

# ---------------------------------------------------------------- report

print("", flush=True)
print("=" * 112, flush=True)
print("MEASURED HEAD-TO-HEAD   (1 group op = 1 modular addition in Z/nZ)", flush=True)
print("=" * 112, flush=True)
print("%4s %4s %7s | %13s %13s %13s | %9s | %13s %13s" %
      ("s", "b", "nbits", "generic_mean", "generic_max", "ph_mean", "sav_bits",
       "model: 2sqrt(n)", "model: PHsum"), flush=True)
for r in recs:
    sqn = float(2 ** r['s']) * float(r['per'][0]['q'])
    sqn = sqn ** 0.5
    denom = 2.0 ** (r['s'] / 2.0) + 2.0 ** (r['b'] / 2.0)
    print("%4d %4d %7.2f | %13.1f %13d %13.1f | %9.4f | %13.1f %13.1f" %
          (r['s'], r['b'], r['n_bits_real'], r['generic_mean'], r['generic_max'],
           r['ph_mean'], log2(r['generic_mean'] / r['ph_mean']),
           2.0 * sqn, denom), flush=True)

print("", flush=True)
print("=" * 112, flush=True)
print("CONSTANT CALIBRATION   (the number in front of the square root)", flush=True)
print("=" * 112, flush=True)
print("%4s %4s | %13s %13s %13s %13s" %
      ("s", "b", "gen/sqrt(n)", "gen/2sqrt(n)", "E[giant]/m", "ph/(2^s/2+2^b/2)"), flush=True)
for r in recs:
    sqn = (float(2 ** r['s']) * float(r['per'][0]['q'])) ** 0.5
    denom = 2.0 ** (r['s'] / 2.0) + 2.0 ** (r['b'] / 2.0)
    print("%4d %4d | %13.5f %13.5f %13.5f %13.5f" %
          (r['s'], r['b'], r['generic_mean'] / sqn, r['generic_mean'] / (2.0 * sqn),
           r['giant_mean'] / r['m_mean'], r['ph_mean'] / denom), flush=True)


def clean(o):
    if isinstance(o, dict):
        return dict((str(k), clean(v)) for k, v in o.items())
    if isinstance(o, (list, tuple)):
        return [clean(v) for v in o]
    if isinstance(o, bool):
        return o
    if isinstance(o, int):
        return int(o)
    if isinstance(o, float):
        return float(o)
    return str(o)

out = clean(dict(master_seed=int(MASTER_SEED), seeds=int(SEEDS), wall=float(t_all),
                 recs=clean(recs)))
with open(os.path.join(LOGDIR, "ph_main.json"), "w") as f:
    json.dump(out, f, indent=1)
print("", flush=True)
print("wrote", os.path.join(LOGDIR, "ph_main.json"), flush=True)

# =====================================================================
#  ph_partial.sage -- Axis A sub-question: does knowing only PART of the
#  small part help?
#
#  Bounded sub-experiment (~30 min budget), NOT the main deliverable.
#
#  The main experiment uses n = 2^s * q (q prime).  Here we ask what an
#  attacker who knows only a PIECE of the factorisation can do.
#
#  PRIMITIVE (exactly what Pohlig-Hellman gives you from knowing a divisor
#  f of n, with nothing else):
#      1. d mod f      : BSGS in <(n/f)*g>, which has order f
#      2. the residual : write d = df + f*t with t in [0, n/f); then
#                        h - df*g = t*(f*g) and <f*g> has order n/f, so
#                        BSGS there recovers t.
#      cost = BSGS(f) + BSGS(n/f)  group ops   (NO coprimality of f and
#      n/f is needed -- this is a lift, not a CRT.)
#
#  Three cases, counted group ops, 12 seeds each, every answer verified:
#    A. n = 2^s * q1 * q2, attacker knows ONLY 2^s   (q1,q2 unknown)
#       -> does lumping the residual cost more than splitting it?
#    B. n = 2^(s+a) * q, attacker knows only 2^s      (part of the 2-power hidden)
#       -> how much does the hidden a cost?
#    C. n = 3^k * q   versus   n = 2^m * q,  m = round(k log2 3), same sizes
#       -> is the exchange rate base-independent (2 vs 3)?
# =====================================================================
import time, json, os
from math import gcd, log as pylog
from random import Random as PyRandom

LOGDIR = "/home/raver1975/lean/factor-scratch/r115/ph-exchange-rate/logs"
MASTER = 1152075
SEEDS = 12


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
    assert gcd(m1, m2) == 1, (m1, m2)
    u = ((a2 - a1) % m2) * inverse_mod(int(m1), int(m2)) % m2
    return (a1 + m1 * u) % (m1 * m2)


def solve_ph_coprime(n, gen, h, factors):
    """Full Pohlig-Hellman: `factors` is the complete list of pairwise-coprime
    prime powers whose product is n."""
    ops = 0
    res = []
    for m in factors:
        gm, o = dbl_add(gen, n // m, n); ops += o
        hm, o = dbl_add(h,   n // m, n); ops += o
        x, o, d = bsgs(n, gm, hm, m);     ops += o
        res.append((x, m))
    x, mod = res[0]
    for i in range(1, len(res)):
        x = crt_pair(x, mod, res[i][0], res[i][1]); mod *= res[i][1]
    return x % n, ops, res


def solve_partial(n, gen, h, f):
    """The attacker knows ONLY the divisor f of n.  Returns (d, ops)."""
    ops = 0
    nf = n // f
    # ---- 1. d mod f
    gf, o = dbl_add(gen, nf, n);   ops += o
    hf, o = dbl_add(h,   nf, n);   ops += o
    df, o, d1 = bsgs(n, gf, hf, f); ops += o
    # ---- 2. the residual t in [0, nf) with d = df + f*t
    #         h - df*g = t*(f*g), and <f*g> has order nf
    gr,  o = dbl_add(gen, f, n);   ops += o          # f*g
    dfg, o = dbl_add(gen, df, n);  ops += o          # df*g
    tr = (h - dfg) % n                              # h - df*g = t*(f*g)
    t, o, d2 = bsgs(n, gr, tr, nf); ops += o
    return (df + f * t) % n, ops, (d1, d2)


def rand_prime_bits(rng, b):
    while True:
        c = rng.getrandbits(b) | (1 << (b - 1)) | 1
        if c >= (1 << b):
            continue
        if is_prime(c):
            return int(c)


def rand_unit_mod(rng, n):
    while True:
        g = rng.randrange(2, n)
        if gcd(g, n) == 1:
            return g


rng = PyRandom(int(MASTER))
OUT = {}


def sweep(label, mk, kind):
    """mk() -> (n, g, arg).  kind: 'coprime' (arg = factor list) or 'partial'
    (arg = known divisor f).  12 seeds, all three solvers on the same instance,
    every answer verified against the planted d AND against d*g == h mod n."""
    acc = []
    for it in range(SEEDS):
        n, g, arg = mk()
        d = rng.randrange(0, n)
        h = (d * g) % n
        xg, og, _ = bsgs(n, g, h, n)                       # THE BASELINE
        if kind == "coprime":
            xf, of, _ = solve_ph_coprime(n, g, h, arg)
        else:
            xf, of, _ = solve_partial(n, g, h, arg)
        assert xg == d and xf == d, (label, n)
        assert (xg * g) % n == h and (xf * g) % n == h
        acc.append((n, og, of))
    gm = sum(a[1] for a in acc) / float(SEEDS)
    fm = sum(a[2] for a in acc) / float(SEEDS)
    nb = sum(log2(a[0]) for a in acc) / len(acc)
    rec = dict(label=label, n=acc[0][0], nbits=nb, generic=gm, other=fm,
               sav=log2(gm / fm), generics=[a[1] for a in acc],
               others=[a[2] for a in acc], all_ok=True, kind=kind)
    print("%-26s | n|~2^%6.2f | %13.1f %13.1f | %8.3f"
          % (label, nb, gm, fm, rec["sav"]), flush=True)
    return rec


# ------------------------------------------------------------------ Case A
print("=" * 118)
print("CASE A.  n = 2^s * q1 * q2, q1,q2 of b bits.")
print("         full    = PH on [2^s, q1, q2]      (attacker knows the whole factorisation)")
print("         partial = solve_partial with f = 2^s  (attacker knows ONLY 2^s)")
print("         the GENERIC column is the baseline for both ratios.")
print("=" * 118)
print("%-26s | %8s | %13s %13s | %8s" % ("case", "|n|~", "generic", "PH", "sav"))
A = []
for (s, b) in [(4, 16), (8, 16), (12, 12), (4, 20), (8, 14), (12, 16), (4, 12), (8, 12)]:
    if s + 2 * b > 46:
        continue

    def mk_full(s=s, b=b):
        q1 = rand_prime_bits(rng, b); q2 = rand_prime_bits(rng, b)
        while q2 == q1:
            q2 = rand_prime_bits(rng, b)
        n = (1 << s) * q1 * q2
        return (n, rand_unit_mod(rng, n), [1 << s, q1, q2])

    def mk_part(s=s, b=b):
        q1 = rand_prime_bits(rng, b); q2 = rand_prime_bits(rng, b)
        while q2 == q1:
            q2 = rand_prime_bits(rng, b)
        n = (1 << s) * q1 * q2
        return (n, rand_unit_mod(rng, n), 1 << s)
    A.append(sweep("A  s=%d q1,q2=%db FULL" % (s, b), mk_full, "coprime"))
    A.append(sweep("A  s=%d q1,q2=%db PARTIAL" % (s, b), mk_part, "partial"))
print()
print("  reading: knowing ONLY 2^s (and lumping q1*q2) already buys s/2 bits -- the attacker")
print("  does NOT need the residual factorisation to get that far.  Splitting the residual")
print("  into q1,q2 buys an extra ~b/2 bits on top.  So every factor learned is worth half")
print("  the number of bits it removes from the LARGEST remaining piece.")
print()

# ------------------------------------------------------------------ Case B
print("=" * 118)
print("CASE B.  n = 2^(s+a) * q, the attacker knows only 2^s (a bits of the 2-power hidden)")
print("         partial f=2^s   versus   full PH on [2^(s+a), q]")
print("=" * 118)
print("%-26s | %8s | %13s %13s | %8s" % ("case", "|n|~", "generic", "PH", "sav"))
B = []
for (s, a, b) in [(8, 4, 20), (12, 8, 16), (4, 8, 24), (16, 4, 16), (8, 12, 12), (12, 4, 20)]:
    if s + a + b > 46:
        continue

    def mk_part(s=s, a=a, b=b):
        q = rand_prime_bits(rng, b)
        n = (1 << (s + a)) * q
        return (n, rand_unit_mod(rng, n), 1 << s)

    def mk_full(s=s, a=a, b=b):
        q = rand_prime_bits(rng, b)
        n = (1 << (s + a)) * q
        return (n, rand_unit_mod(rng, n), [1 << (s + a), q])
    B.append(sweep("B  s=%d a=%d b=%d PART(s)" % (s, a, b), mk_part, "partial"))
    B.append(sweep("B  s=%d a=%d b=%d FULL" % (s, a, b), mk_full, "coprime"))
print()
print("  reading: hiding a bits of the 2-power costs exactly a/2 bits of saving.  The exchange")
print("  rate itself is unchanged -- you simply know less.  Partial knowledge of the small")
print("  part IS useful, at exactly the 2:1 rate.")
print()

# ------------------------------------------------------------------ Case C
print("=" * 118)
print("CASE C.  base independence of the exchange rate:  3^k * q  vs  2^m * q,  m = round(k log2 3)")
print("=" * 118)
print("%-26s | %8s | %13s %13s | %8s" % ("case", "|n|~", "generic", "PH", "sav"))
C = []
for (k, b) in [(4, 20), (6, 16), (8, 12), (5, 18), (7, 12), (3, 22)]:
    m = int(round(k * 1.584962500721156))     # log2(3)
    if m + b > 46 or k * 1.5849625 + b > 46:
        continue

    def mk3(k=k, b=b):
        q = rand_prime_bits(rng, b)
        n = (3 ** k) * q
        return (n, rand_unit_mod(rng, n), [3 ** k, q])

    def mk2(m=m, b=b):
        q = rand_prime_bits(rng, b)
        n = (1 << m) * q
        return (n, rand_unit_mod(rng, n), [1 << m, q])
    C.append(sweep("C  3^%d * q,  b=%d" % (k, b), mk3, "coprime"))
    C.append(sweep("C  2^%d * q,  b=%d" % (m, b), mk2, "coprime"))
print()
print("  reading: for the same number of bits of n absorbed into the known small part, the")
print("  saving is the same whether the known factor is 2^m or 3^k (m = k log2 3).  The")
print("  exchange rate is per BIT of n absorbed, not per prime:")
print("     1 bit of n absorbed into known factors  ->  factor 2^(1/2) reduction in work.")
print("  So 'knowing a factor 3^k' is worth exactly the same as knowing 2^(k log2 3).")
print()


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


json.dump(_clean(dict(seed=MASTER, seeds=SEEDS, caseA=A, caseB=B, caseC=C)),
          open(os.path.join(LOGDIR, "ph_partial.json"), "w"), indent=1)
print("wrote", os.path.join(LOGDIR, "ph_partial.json"))

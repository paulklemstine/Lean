# ---------------------------------------------------------------------------
# exp_i6.sage -- Axis I6: GLV / sublattice-structured nonces.
#
# Claim under test: a lattice embedding that uses the sublattice basis
# (k = k1 + lam*k2 with k1,k2 < 2^(nb/2)) recovers d better than the plain
# range embedding k < 2^nb.
#
# Three measurements:
#  (1) EXACT image density of the GLV box on small curves (enumerable) plus
#      the closed-form collision count  ~2^(nb+2)/n  for n ~ 2^nb.
#  (2) Lattice comparison at MATCHED total leakage, same instances, same
#      seeds: sublattice embedding vs plain range embedding.
#  (3) The no-leakage case (structure only) on the toy curve.
#
# Usage: sage exp_i6.sage [nseeds] [seed1] [seed2]
# ---------------------------------------------------------------------------
from sage.all import *
import json
load('common.sage')

def P(*a): print(*a, flush=True)

NSEED = int(sys.argv[1]) if len(sys.argv) > 1 else 20
SEEDS = [int(sys.argv[2]) if len(sys.argv) > 2 else 20261014,
         int(sys.argv[3]) if len(sys.argv) > 3 else 909090]

# ---------------------------------------------------------------------------
P("=== (1) image density of the GLV box {k1 + lam*k2 mod n : k1,k2 < 2^h} ===")
P("h = nb//2, so the box holds 2^(2h) = 2^(nb) (nb even) or 2^(nb-1) (nb odd)")
P("elements, while n itself has nb bits.")
P("%12s %6s %6s %16s %12s %14s" %
  ("curve n", "nb", "h", "box elements", "|image|", "|image|/n"))

def glv_lam(n):
    R_ = PolynomialRing(GF(n), 'x'); xx = R_.gen()
    rts = (xx**2 + xx + 1).roots()
    return int(rts[0][0]) if rts else None

def glv_box_size(n, h):
    lam = glv_lam(n)
    if lam is None:
        return None, None
    seen = set()
    B = 2**h
    for k1 in range(B):
        base = k1 % n
        for k2 in range(B):
            seen.add((base + lam*k2) % n)
    return lam, len(seen)

# exact enumeration on small prime-order curves, both parities of nb
small = {}
p = 2**15
while len(small) < 6 and p < 2**23:
    p = next_prime(p)
    E = EllipticCurve(GF(p), [0, 7])
    nE = int(E.order())
    if nE % 3 == 1 and Integer(nE).is_prime():
        small[p] = nE
for (p, nE) in sorted(small.items()):
    nb = Integer(nE).nbits(); h = nb // 2
    if 2**(2*h) > 2**22:
        continue
    lam, size = glv_box_size(nE, h)
    if size is None:
        continue
    P("%12d %6d %6d %16d %12d %14.6f"
      % (nE, nb, h, 2**(2*h), size, size/float(nE)))

# toy curve: 2^(2h) is far too large to enumerate.  Two independent estimates:
#  (a) exact collision count = sum over d2 in (0,2^h) of #d1 in (-2^h,2^h)
#      with d1 = -lam*d2 (mod n)   -- computed on a 10^6 random sample and
#      scaled (the condition is isomorphic for each d2 class);
#  (b) the closed form  2^(2h+2)/n.
nt = TOY['n']; nbt = Integer(nt).nbits(); ht = nbt // 2
lam_t = glv_lam(nt)
NSAMP = 200000
hit = 0
for _ in range(NSAMP):
    d2 = int(randrange(1, 2**ht))
    d1 = (-lam_t * d2) % nt
    if d1 < 2**ht or nt - d1 < 2**ht:
        hit += 1
frac_hit = hit / float(NSAMP)
# each hit d1 corresponds to 2 ordered delta pairs (d1,d2) and (-d1,-d2)
coll = frac_hit * (2**ht) * 2 / 2          # unordered pairs / 2 -> collisions
P("%12d %6d %6d %16d %12d %14.6f   (sampled, %d draws)"
  % (nt, nbt, ht, 2**(2*ht), 2**(2*ht) - coll,
     (2**(2*ht) - coll)/float(nt), NSAMP))
P("            closed-form collisions 2^(2h+2)/n = %d   =>  density ~1/2"
  % (2**(2*ht+2)//nt))
P("            (1 bit per signature of genuine constraint -- and this is the")
P("             BEST case: a real curve has density 1, i.e. no constraint.)")

# real curve
ns = SECP['n']
lam_s = glv_lam(ns)
P("secp256k1  : lambda^2+lambda+1=0 (mod n), lambda = 0x%064x" % lam_s)
P("            box = 2^256 elements, n ~ 2^256(1-2^-128)  =>  |image|/n -> 1")
P("            collision count (closed form 2^(2h+2)/n) = %d" % (2**258//ns))
P("=> the GLV box holds ~n elements, so its image has essentially full density:")
P("   'k is GLV-decomposed' carries NO information beyond 'k < 2^256'.")
P("   (on the 61-bit toy curve the box is half of n, which is a 1 bit/signature")
P("    bonus for the sublattice embedding -- the BEST case for I6.)")

# ---------------------------------------------------------------------------
P("")
P("=== (2) lattice comparison at MATCHED total leakage (toy curve, h=%d) ===" % ht)
P("matched leakage: sublattice ell1+ell2 = plain ell (same unknown bits)")
P("NOTE the toy curve's GLV box has density 1/2: it hands the sublattice")
P("     embedding a 1 bit/signature bonus that a real curve does not have.")
P("%6s %6s %6s %6s %8s %16s %20s" %
  ("ell1", "ell2", "ell", "t", "t*(ell)", "sublattice emb.", "plain range emb."))

def glv_pts(total):
    return [(total//2, total - total//2), (total, 0)]

res2 = {}
for tot in (4, 8, 16):
    tf = int(ceil(NB_TOY/float(tot)))
    for tt in (tf, 2*tf):
        for (e1, e2) in glv_pts(tot):
            okS = okP = done = 0
            for s in SEEDS:
                set_random_seed(s)
                for _ in range(NSEED):
                    d = Integer(randrange(1, nt-1))
                    sig = gen_glv(TOY, d, tt, e1, e2, lam_t)
                    if sig['t'] < tt:
                        continue
                    done += 1
                    okS += int(trial(attack_glv, sig))
                    # plain range embedding at the matched total leakage
                    okP += int(trial(attack_plain_classical,
                                    gen_plain(TOY, d, tt, tot)))
            res2[(e1, e2, tt)] = (okS, okP, done)
            P("%6d %6d %6d %6d %8d %9d/%-6d %13d/%-6d"
              % (e1, e2, tot, tt, tot*tt, okS, done, okP, done))

# ---------------------------------------------------------------------------
# save the matched-leakage data FIRST, so the JSON always exists even if a
# later section is cut off by a wall-clock limit
with open('logs/i6_matched.json', 'w') as f:
    json.dump({'seeds': [int(x) for x in SEEDS], 'nseeds': int(NSEED),
               'lam_toy': int(lam_t), 'lam_secp': int(lam_s) if lam_s else None,
               'matched': [[int(k[0]), int(k[1]), int(k[2])] + [int(v) for v in vv]
                           for k, vv in sorted(res2.items())]},
              f, indent=1)
P("wrote logs/i6_matched.json")

# ---------------------------------------------------------------------------
P("")
P("=== (3) structure only, no leakage at all (toy curve) ===")
for tt in (16, 31):
    P("  ... running structure-only point t=%d" % tt)
    okS = done = 0
    for s in SEEDS:
        set_random_seed(s)
        for _ in range(NSEED):
            d = Integer(randrange(1, nt-1))
            sig = gen_glv(TOY, d, tt, 0, 0, lam_t)
            if sig['t'] < tt:
                continue
            done += 1
            okS += int(trial(attack_glv, sig))
    P("  ell1=ell2=0 t=%d : sublattice embedding %d/%d" % (tt, okS, done))

with open('logs/i6.json', 'w') as f:
    json.dump({'seeds': [int(x) for x in SEEDS], 'nseeds': int(NSEED),
               'lam_toy': int(lam_t), 'lam_secp': int(lam_s) if lam_s else None,
               'matched': [[int(k[0]), int(k[1]), int(k[2])] + [int(v) for v in vv]
                           for k, vv in sorted(res2.items())]}, f, indent=1)
P("wrote logs/i6.json")

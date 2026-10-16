load("lib.sage")
# Prediction from the mechanism (why2.sage): the obstacle below the threshold is a shorter
# OUT-OF-BOX solution (K_i ~ K_i +/- n, i.e. the modular wraparound).  Known LOW bits of
# the nonce exclude exactly those: X = k mod 2^m must satisfy X == b (mod 2^l2), which the
# wraparound candidates do not.  Substituting X = b + 2^l2 * Y gives an equivalent HNP
# instance with box 2^(m-l2), s' = s*2^l2, c' = z - s*b.
# So MIXED (msb + lsb) leakage should approach the counting bound t*l > nbits more closely
# than pure MSB leakage, whose measured threshold is 72 at nbits=256, t=4 (t*l = 288).

def mixed_instance(nbits, t, l1, l2, sd=0, dbits=None):
    inst = build_instance(nbits, t, l1, "msb", sd=sd, dbits=dbits)   # a = top l1 bits
    n = inst["n"]
    s, z, k = inst["s"][:], inst["z"][:], inst["k"][:]
    m = nbits - l1
    if l2 > m:
        return None
    b = [k[i] % (ZZ(1) << l2) for i in range(t)]
    A = [(k[i] >> m) << m for i in range(t)]
    # original c_i = z_i - s_i*A_i ; new: c'_i = c_i - s_i*b_i, s'_i = s_i*2^l2
    inst2 = dict(inst)
    inst2["s"] = [(s[i] * (ZZ(1) << l2)) % n for i in range(t)]
    inst2["z"] = [((z[i] - s[i] * A[i]) - s[i] * b[i]) % n for i in range(t)]
    inst2["a"] = [ZZ(0)] * t
    inst2["l"] = l1 + l2                       # effective box is 2^(m - l2)
    return inst2

def rate(nbits, t, l1, l2, sd_range, dbits=None):
    hits = 0; tot = 0
    for sd in sd_range:
        inst2 = mixed_instance(nbits, t, l1, l2, sd=sd, dbits=dbits)
        if inst2 is None: return None
        tot += 1
        hits += (attack(inst2)[0] is not None)
    return hits, tot

NB, T = 256, 4
print("nbits=256, t=4.  Total leakage l1+l2 at which the attack starts working (>=10/12).", flush=True)
print(f"{'l1 (msb)':>9} {'l2 (lsb)':>9} {'total':>6} | {'threshold total found?':>22}", flush=True)
best = None
for (l1, l2) in [(72,0),(64,8),(56,16),(48,24),(40,32),(32,40),(24,48),(16,56),(0,72),(60,12),(68,4)]:
    # find the smallest additional total that works: scan total from l2 upward
    tot_needed = None
    for extra in range(0, NB - l1 + 1, 4):
        if l1 + l2 + extra > NB: break
        r = rate(NB, T, l1, l2, range(12), dbits=NB) if extra == 0 else None
        # scan over l1 with fixed l2 instead: vary l1
        ll1 = l1 + extra
        if ll1 + l2 > NB: break
        h = 0
        for sd in range(12):
            inst2 = mixed_instance(NB, T, ll1, l2, sd=sd, dbits=NB)
            h += (attack(inst2)[0] is not None)
        if h >= 10:
            tot_needed = ll1 + l2
            break
    print(f"{l1:>9} {l2:>9} {(l1+l2):>6} | {str(tot_needed):>22}", flush=True)
    if tot_needed and (best is None or tot_needed < best[0]):
        best = (tot_needed, l1, l2)
print()
print(f"pure MSB reference (round 15/16): total = 72, t*total = 288 = 1.125*nbits", flush=True)
print(f"best mixed leakage found: total = {best[0] if best else None} -> t*total = "
      f"{4*best[0] if best else None} = {(4*best[0]/NB) if best else float('nan'):.3f}*nbits", flush=True)
print("counting bound: t*total > nbits  <=>  total > 64", flush=True)

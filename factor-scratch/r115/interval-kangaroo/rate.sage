# =====================================================================
#  rate.sage -- Axis K (r115): measured group-operation throughput
#
#  Measures, on THIS machine, the honest group-operation rate for the
#  code paths the kangaroo/BSGS experiments actually use.  Everything is
#  timed separately from the op COUNTS, so the wall-clock extrapolation
#  in RESULT.md is an extrapolation from a MEASURED rate, not a claim
#  about future hardware.
#
#  PART A  pure point addition (Sage native affine EC over GF(p))
#  PART B  the kangaroo inner loop: jump hash + point addition + dict
#  PART C  the BSGS inner loop: point addition + dict lookup
#  PART D  an OPTIMISED pure-Python Jacobian-coordinate implementation
#          (NOT Sage native) -- this is an engineering upper bound on
#          what a tuned C/assembly implementation would reach; it is
#          clearly labelled as such and is NOT used for the headline
#          extrapolation.
# =====================================================================

import time, json, os

LOGDIR = "/home/raver1975/lean/factor-scratch/r115/interval-kangaroo/logs"

P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
GOLD = int(0x9E3779B97F4A7C15)
MASK64 = int(0xFFFFFFFFFFFFFFFF)
NREP = 5

def jump_of(pt, Mmax):
    x = int(pt[0])
    h = ((x >> 64) * GOLD + (x >> 192)) & MASK64
    h = (h * GOLD + (h >> 31)) & MASK64
    return 1 + (h % Mmax)

print("=" * 74)
print("rate.sage -- measured group-operation throughput (Sage %s)" % str(version()))
print("=" * 74)

# ---------------- PART A: pure point addition -------------------------
res = {}
for MM in (512, 2048, 8192):
    J = [None] * (MM + 1)
    cur = EE(0)
    for j in range(1, MM + 1):
        cur = cur + GG; J[j] = cur
    # distinct random points so nothing is cached
    pts = [GG * (i * 7919 + 13) for i in range(512)]
    N = int(60000)
    rates = []
    for rep in range(NREP):
        acc = pts[0]
        t0 = time.time()
        for i in range(N):
            acc = acc + pts[1 + (i % 511)]
        dt = time.time() - t0
        rates.append(N / dt)
    res['add_M%d' % MM] = dict(ops=N, reps=rates, best=max(rates), mean=sum(rates) / len(rates))
    print("  PART A  pure point addition, table %5d : %s ops/s  (mean %.0f)"
          % (MM, "%.0f" % max(rates), sum(rates) / len(rates)))

# ---------------- PART B: kangaroo inner loop ------------------------
MM = 2048
J = [None] * (MM + 1)
cur = EE(0)
for j in range(1, MM + 1):
    cur = cur + GG; J[j] = cur
N = int(40000)
rates = []
for rep in range(NREP):
    p = GG * 12345
    t0 = time.time()
    n = 0
    for i in range(N):
        j = jump_of(p, MM)
        p = p + J[j]
        n += 1
    dt = time.time() - t0
    rates.append(n / dt)
res['kangaroo_step'] = dict(ops=N, reps=rates, best=max(rates), mean=sum(rates) / len(rates))
print("  PART B  kangaroo step (hash+add), table %5d: %s ops/s  (mean %.0f)"
      % (MM, "%.0f" % max(rates), sum(rates) / len(rates)))

# ---------------- PART C: BSGS inner loop (add + dict) ---------------
d = {}
p = GG * 999
N = int(40000)
rates = []
for rep in range(NREP):
    p = GG * 999
    neg = -GG
    t0 = time.time()
    n = 0
    for i in range(N):
        p = p + neg
        xv = int(p[0])
        v = d.get(xv)
        n += 1
    dt = time.time() - t0
    rates.append(n / dt)
res['bsgs_step'] = dict(ops=N, reps=rates, best=max(rates), mean=sum(rates) / len(rates))
print("  PART C  BSGS step (add + dict lookup)    : %s ops/s  (mean %.0f)"
      % ("%.0f" % max(rates), sum(rates) / len(rates)))

# ---------------- PART D: optimised pure-Python Jacobian -------------
# NOT Sage native.  Jacobian (X,Y,Z) over GF(p) with PYTHON ints,
# generic addition.  All numeric literals are forced to Python ints
# (in a .sage file `2 * x` makes a Sage Integer, which is 10x slower --
# one of the traps recorded in RESULT.md).
I0 = int(0); I1 = int(1); I2 = int(2); I3 = int(3); I8 = int(8)

def jac_init(k):
    """k*G in Jacobian via double-and-add"""
    X, Y = GX, GY
    R = (I0, I0, I0)          # infinity
    for bit in format(k, 'b'):
        R = jac_dbl(R)
        if bit == '1':
            R = jac_add(R, (X, Y, I1))
    return R

def jac_dbl(P):
    X1, Y1, Z1 = P
    if Z1 == 0 or Y1 == 0:
        return (I0, I0, I0)
    A = (X1 * X1) % PP
    B = (Y1 * Y1) % PP
    C = (B * B) % PP
    t = (X1 + B) % PP
    D = (I2 * (t * t - A - C)) % PP
    E = (I3 * A) % PP
    F = (E * E) % PP
    X3 = (F - I2 * D) % PP
    Y3 = (E * (D - X3) - I8 * C) % PP
    Z3 = (I2 * Y1 * Z1) % PP
    return (X3, Y3, Z3)

def jac_add(P, Q):
    X1, Y1, Z1 = P
    X2, Y2, Z2 = Q
    if Z1 == 0:
        return Q
    if Z2 == 0:
        return P
    Z1Z1 = (Z1 * Z1) % PP
    Z2Z2 = (Z2 * Z2) % PP
    U1 = (X1 * Z2Z2) % PP
    U2 = (X2 * Z1Z1) % PP
    S1 = (Y1 * Z2 * Z2Z2) % PP
    S2 = (Y2 * Z1 * Z1Z1) % PP
    if U1 == U2:
        if S1 != S2:
            return (I0, I0, I0)
        return jac_dbl(P)
    H = (U2 - U1) % PP
    I_ = (I2 * H) % PP
    I_ = (I_ * I_) % PP
    Jv = (H * I_) % PP
    r = (I2 * (S2 - S1)) % PP
    V = (U1 * I_) % PP
    X3 = (r * r - Jv - I2 * V) % PP
    Y3 = (r * (V - X3) - I2 * S1 * Jv) % PP
    Z3 = (((Z1 + Z2) * (Z1 + Z2) - Z1Z1 - Z2Z2) * H) % PP
    return (X3, Y3, Z3)

GX = int(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798)
GY = int(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
PP = int(P_P)

# validate the Jacobian implementation against Sage
for k in (1, 2, 3, 12345, 0xdeadbeef, 2**64 + 7):
    Jp = jac_init(k)
    sp = GG * k
    if Jp[2] == 0:
        assert sp == EE(0)
        continue
    zinv = pow(Jp[2], PP - 2, PP)
    zi2 = (zinv * zinv) % PP
    assert (Jp[0] * zi2) % PP == int(sp[0]), "Jacobian x mismatch"
    assert (Jp[1] * zi2 * zinv) % PP == int(sp[1]), "Jacobian y mismatch"
print("  PART D  Jacobian implementation validated against Sage on 6 test scalars")

Jt = [None] + [jac_init(j) for j in range(1, int(2049))]
N = int(20000)
rates = []
for rep in range(NREP):
    R = Jt[int(1)]
    t0 = time.time()
    n = 0
    for i in range(N):
        j = (i % int(2047)) + I2
        R = jac_add(R, Jt[j])
        n += 1
    dt = time.time() - t0
    rates.append(n / dt)
res['jacobian_py'] = dict(ops=N, reps=rates, best=max(rates), mean=sum(rates) / len(rates))
print("  PART D  pure-Python Jacobian addition     : %s ops/s  (mean %.0f)"
      % ("%.0f" % max(rates), sum(rates) / len(rates)))

print()
print("  SUMMARY (best of %d reps, machine: %s)" % (NREP, os.uname().nodename))
for k, v in res.items():
    print("    %-16s %12.0f ops/s   (%.3f us/op)" % (k, v['best'], 1e6 / v['best']))

out = dict(machine=os.uname().nodename, sage=str(version()), results=res)
fn = os.path.join(LOGDIR, "rate.json")
with open(fn, "w") as fh:
    json.dump(out, fh, indent=1)
print("wrote", fn)

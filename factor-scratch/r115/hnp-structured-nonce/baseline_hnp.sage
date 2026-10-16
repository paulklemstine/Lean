# ---------------------------------------------------------------------------
# baseline_hnp.sage -- plain HNP reference lattice, built from scratch.
#
# POSITIVE CONTROL FIRST: this script must show the plain HNP attack FIRING on
# a 64-bit toy curve before any structured variant (I2 / I6) is believed.
# Success criterion is d*G == Q (verified by elliptic-curve arithmetic), never
# "a row looks small".
#
# Run:  sage baseline_hnp.sage [nseeds] [nbits] [ell_min] [ell_max] [t_mult]
# ---------------------------------------------------------------------------
import sys, os, json, time
from sage.all import *
from fpylll import LLL, BKZ, IntegerMatrix
load('common.sage')

# ---- toy curve: y^2 = x^3 + 7 over F_p, p ~ 2^61, prime order -------------
P_TOY = 2305843009213697761
E_TOY = EllipticCurve(GF(P_TOY), [0, 7])
N_TOY = int(E_TOY.order())
NBITS_TOY = int(N_TOY).bit_count() and Integer(N_TOY).nbits()
TOY = dict(p=int(P_TOY), a=0, b=7, n=int(N_TOY),
           G=(int(E_TOY.gens()[0][0]), int(E_TOY.gens()[0][1])))
print("toy curve: p = %d (nbits %d)" % (P_TOY, Integer(P_TOY).nbits()))
print("          n = %d (nbits %d)" % (int(N_TOY), NBITS_TOY))
print("          p-n = %d" % (P_TOY - int(N_TOY)))
print("          G  = %s" % (str(TOY['G']),))
assert Integer(N_TOY).is_prime()

def toy_gen():
    """(curve, d, Q)"""
    d = Integer(ZZ.random_element(1, N_TOY-1))
    Q = ec_mul(int(d), TOY['G'], 0, P_TOY)
    return d, Q

# --------------------------------------------------------------------------
# fpylll wrappers (single place where reduction parameters live)
# --------------------------------------------------------------------------
def to_fpylll(B):
    nr, nc = B.nrows(), B.ncols()
    A = IntegerMatrix(nr, nc)
    for i in range(nr):
        for j in range(nc):
            A[i, j] = int(B[i, j])
    return A

def from_fpylll(A):
    nr, nc = A.nrows, A.ncols
    return Matrix(ZZ, nr, nc, [[A[i, j] for j in range(nc)] for i in range(nr)])

def do_lll(B, delta=0.99):
    return from_fpylll(LLL.reduction(to_fpylll(B), delta=delta))

def do_bkz(B, block=20):
    return from_fpylll(BKZ.reduction(to_fpylll(B),
                     BKZ.Param(block_size=block,
                               strategies=BKZ.DEFAULT_STRATEGY)))

# --------------------------------------------------------------------------
# instance generator: t signatures with ell known MSBs of k
# --------------------------------------------------------------------------
def gen_instance(curve, d, t, ell, nb, rng):
    p, n = curve['p'], curve['n']
    K = 2**(nb - ell)
    r, s, z, kbar, ktrue = [], [], [], [], []
    for i in range(t):
        while True:
            k = ZZ.random_element(1, n-1) if rng == 'sage' else k
            if rng == 'sage':
                k = Integer(randrange(1, n-1))
                break
        k = int(k)
        zi = int(randrange(0, n))
        P = mul_G(k, curve)
        ri = P[0] % n
        if ri == 0:
            continue
        try:
            si = (inverse_mod(k, n) * (zi + ri * int(d))) % n
        except ZeroDivisionError:
            continue
        if si == 0:
            continue
        r.append(ri); s.append(si); z.append(zi)
        kbar.append((k // K) * K)
        ktrue.append(k)
    return dict(r=r, s=s, z=z, kbar=kbar, ktrue=ktrue, n=n, nb=nb, ell=ell)

# --------------------------------------------------------------------------
# the attack
# --------------------------------------------------------------------------
def attack_plain(sig, reduce='lll', bkz_block=20):
    n, nb = sig['n'], sig['nb']
    B, tcol = hnp_basis_plain(sig['r'], sig['s'], sig['z'], sig['kbar'], n, nb,
                              sig['ell'])
    if reduce == 'lll':
        R = do_lll(B)
    else:
        R = do_bkz(B, bkz_block)
    cands = []
    for row in R:
        cands.extend(hnp_candidates(row, tcol, n))
    return cands

def main():
    nseeds = int(sys.argv[1]) if len(sys.argv) > 1 else 20
    ell_lo = int(sys.argv[2]) if len(sys.argv) > 2 else 4
    ell_hi = int(sys.argv[3]) if len(sys.argv) > 3 else 8
    tmult  = float(sys.argv[4]) if len(sys.argv) > 4 else 2.0
    set_random_seed(20261014)      # fixed, documented, reproducible
    print("fixed seed 20261014, nseeds = %d per point" % nseeds)
    print("info floor: t*ell >= log2(n) = %d bits" % NBITS_TOY)
    print()
    print("%8s %6s %8s %8s %8s %10s   %s" %
          ("ell", "t", "t*ell", "floor", "LLL", "BKZ20", "notes"))
    out = []
    for ell in range(ell_lo, ell_hi+1):
        K = 2**(NBITS_TOY - ell)
        tmin = int(ceil(NBITS_TOY / float(ell)))
        for tmult_ in [tmult]:
            t = int(ceil(tmin * tmult_))
            cnt_lll = cnt_bkz = 0
            for seed in range(nseeds):
                d = Integer(ZZ.random_element(1, N_TOY-1))
                Q = mul_G(int(d), TOY)
                sig = gen_instance(TOY, d, t, ell, NBITS_TOY, 'sage')
                sig['Q'] = Q
                for cand in attack_plain(sig, 'lll'):
                    if mul_G(int(cand), TOY) == Q:
                        cnt_lll += 1
                        break
                for cand in attack_plain(sig, 'bkz', 20):
                    if mul_G(int(cand), TOY) == Q:
                        cnt_bkz += 1
                        break
            print("%8d %6d %8d %8d %6d/%-3d %6d/%-3d   %s" %
                  (ell, t, t*ell, tmin*ell, cnt_lll, nseeds, cnt_bkz, nseeds,
                   "POSITIVE CONTROL: plain HNP fires" if cnt_lll > 0 else "NO FIRE -- HARNESS BROKEN"))
            out.append(dict(ell=int(ell), t=int(t), tell=int(t*ell), lll=int(cnt_lll),
                            bkz=int(cnt_bkz), nseeds=int(nseeds),
                            nbits=int(NBITS_TOY)))
    with open('logs/baseline_toy.json', 'w') as f:
        json.dump(out, f, indent=1)

main()

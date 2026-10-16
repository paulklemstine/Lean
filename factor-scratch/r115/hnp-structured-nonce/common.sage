# ---------------------------------------------------------------------------
# common.sage -- shared harness for round 115, Axis I sub-axes I1 / I2 / I6.
#
# Self-contained (written for this round, not imported from any other round's
# harness).  Success criterion everywhere: the recovered d satisfies d*G == Q,
# checked by elliptic-curve arithmetic.  Never "a row looks small".
#
# ---------------------------------------------------------------------------
# UNIFIED LATTICE DESIGN
#
# Every attack below is phrased as:
#
#   find SMALL unknowns x = (x_1..x_n) in Z^n such that
#        c^(j) . x  =  k_j            (mod M_j)      j = 1..s
#   with the *big* unknowns (the private key d, the LCG increment b, ...)
#   eliminated first, so that the quotients of the lifted integer equations
#       c^(j) . x - k_j*u = M_j * w_j
#   are themselves SMALL.  Then the solution is the unique short vector of
#   the kernel lattice
#       [ C  |  -diag(M_j)  | -k ]
#   (coordinates: x | w_1..w_s | u,  the target has u = 1).
#
# The plain HNP cannot eliminate d from a single relation, so it keeps the
# classical construction AND this one, and both are reported.
# ---------------------------------------------------------------------------

from sage.all import *
from fpylll import LLL, BKZ, IntegerMatrix
import math

# ===========================================================================
# curves
# ===========================================================================
TOY  = dict(p=2305843009213697761, a=0, b=7, n=2305843006310511949,
            G=(1936604392079193929, 366635138978874566))
NB_TOY = 61

SECP = dict(p=2**256 - 2**32 - 977, a=0, b=7,
            n=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141,
            G=(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
               0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))
NB_SECP = 256

def nb_of(C):  return NB_TOY if C['n'] == TOY['n'] else NB_SECP

# ===========================================================================
# EC arithmetic, longhand
# ===========================================================================
def ec_add(P, Q, C):
    a, p = C['a'], C['p']
    if P is None: return Q
    if Q is None: return P
    (x1, y1), (x2, y2) = P, Q
    if x1 == x2 and (y1 + y2) % p == 0: return None
    if P == Q:
        lam = (3*x1*x1 + a) * inverse_mod(2*y1, p) % p
    else:
        lam = (y2 - y1) * inverse_mod(x2 - x1, p) % p
    x3 = (lam*lam - x1 - x2) % p
    return (x3, (lam*(x1 - x3) - y1) % p)

def ec_mul(k, P, C):
    R, k = None, int(k)
    while k:
        if k & 1: R = ec_add(R, P, C)
        P = ec_add(P, P, C); k >>= 1
    return R

def mulG(k, C): return ec_mul(k, C['G'], C)

def ecdsa_sign(k, d, z, C):
    n = C['n']
    r = mulG(k, C)[0] % n
    return r, (inverse_mod(k, n) * (z + r*int(d))) % n

def ecdsa_verify(Q, r, s, z, C):
    n = C['n']
    if not (1 <= r < n and 1 <= s < n): return False
    w = inverse_mod(s, n)
    X = ec_add(ec_mul((z*w) % n, C['G'], C), ec_mul((r*w) % n, Q, C), C)
    return X is not None and X[0] % n == r

# ===========================================================================
# fpylll wrappers -- the only place reduction parameters live
# ===========================================================================
def to_fpylll(B):
    A = IntegerMatrix(B.nrows(), B.ncols())
    for i in range(B.nrows()):
        for j in range(B.ncols()):
            A[i, j] = int(B[i, j])
    return A

def from_fpylll(A):
    return Matrix(ZZ, A.nrows, A.ncols,
                  [[int(A[i, j]) for j in range(A.ncols)] for i in range(A.nrows)])

def do_lll(B, delta=0.99):
    return from_fpylll(LLL.reduction(to_fpylll(B), delta=delta))

def do_bkz(B, block=20):
    return from_fpylll(BKZ.reduction(to_fpylll(B),
                     BKZ.Param(block_size=block, strategies=BKZ.DEFAULT_STRATEGY)))

# ===========================================================================
# the generic kernel lattice
# ===========================================================================
def kernel_lattice(nx, rows):
    """rows = list of (coeffs (length nx), modulus M_j, constant k_j).

    Builds the integer matrix
        [ C ]       [ -diag(M_j) ] [ -k ]
    over Z^{nx + s + 1} and returns (reduced_basis, index_of_u).
    The target solution is a short vector with u-coordinate +-n.
    """
    s = len(rows)
    N = nx + s + 1
    M = Matrix(ZZ, s, N)
    for j in range(s):
        c, mod, k = rows[j]
        assert len(c) == nx
        for i in range(nx):
            M[j, i] = int(c[i])
        M[j, nx + j] = -int(mod)
        M[j, N - 1] = -int(k)
    L = M.right_kernel()
    return L.basis_matrix(), N - 1, M

def reduce_and_split(B, col_u, nx, reduce='lll', bkz_block=20):
    R = do_lll(B) if reduce == 'lll' else do_bkz(B, bkz_block)
    return R, col_u

# ===========================================================================
# instance generators
# ===========================================================================
def _gen_nonces(C, t):
    n = C['n']
    ks = []
    while len(ks) < t:
        k = int(randrange(1, n - 1))
        if k not in ks:
            ks.append(k)
    return ks

def gen_plain(C, d, t, ell):
    """t signatures, uniform nonces, ell known MSB bits of each k"""
    n = C['n']; nb = nb_of(C); K = 2**(nb - ell)
    r, s, z, kt = [], [], [], []
    for k in _gen_nonces(C, t):
        zi = int(randrange(0, n))
        ri, si = ecdsa_sign(k, d, zi, C)
        if ri and si:
            r.append(ri); s.append(si); z.append(zi); kt.append(k)
    return dict(C=C, n=n, nb=nb, ell=ell, t=len(r), r=r, s=s, z=z,
                kbar=[(k // K) * K for k in kt], ktrue=kt,
                Q=mulG(int(d), C), kind='plain')

def gen_lcg(C, d, t, ell, m, a, b):
    """t signatures with nonces k_{i+1} = a k_i + b (mod 2^m), a and b secret;
    ell known MSB bits of each k.  Needs 2^m < n so the nonce is not reduced."""
    n = C['n']; K = 2**(m - ell); two_m = 2**m
    k = int(randrange(1, two_m - 1))
    ks = []
    for i in range(t):
        ks.append(k); k = (a * k + b) % two_m
    r, s, z, kt = [], [], [], []
    for k in ks:
        zi = int(randrange(0, n))
        ri, si = ecdsa_sign(k, d, zi, C)
        if ri and si:
            r.append(ri); s.append(si); z.append(zi); kt.append(k)
    return dict(C=C, n=n, nb=nb_of(C), ell=ell, t=len(r), r=r, s=s, z=z,
                kbar=[(k // K) * K for k in kt], ktrue=kt,
                m=m, a=a, b=b, Q=mulG(int(d), C), kind='lcg')

def gen_glv(C, d, t, ell1, ell2, lam):
    """GLV nonces k = k1 + lam*k2 (mod n), k1,k2 < 2^(nb/2);
    ell1 / ell2 known MSB bits of k1 / k2."""
    n = C['n']; nb = nb_of(C); half = nb // 2
    K1 = 2**(half - ell1); K2 = 2**(half - ell2)
    pairs = [(int(randrange(0, 2**half)), int(randrange(0, 2**half)))
             for _ in range(t)]
    ks = [(k1 + lam * k2) % n for (k1, k2) in pairs]
    r, s, z, kt, pr = [], [], [], [], []
    for k, (k1, k2) in zip(ks, pairs):
        zi = int(randrange(0, n))
        ri, si = ecdsa_sign(k, d, zi, C)
        if ri and si:
            r.append(ri); s.append(si); z.append(zi); kt.append(k); pr.append((k1, k2))
    return dict(C=C, n=n, nb=nb, ell=ell1, ell2=ell2, t=len(r), r=r, s=s, z=z,
                kbar1=[(k1 // K1) * K1 for (k1, k2) in pr],
                kbar2=[(k2 // K2) * K2 for (k1, k2) in pr],
                ktrue=kt, pairs=pr, lam=lam, half=half, Q=mulG(int(d), C),
                kind='glv')

# ===========================================================================
# shared per-signature data
# ===========================================================================
def sig_params(sig):
    """g_i = r_i s_i^-1, y_i = z_i s_i^-1 (mod n)"""
    n = sig['n']
    g = [(sig['r'][i] * inverse_mod(sig['s'][i], n)) % n for i in range(sig['t'])]
    y = [(sig['z'][i] * inverse_mod(sig['s'][i], n)) % n for i in range(sig['t'])]
    return g, y

# ===========================================================================
# ATTACK 1 : plain HNP, classical construction (dimension t+2)
#   target row = (2*2^ell*eps_i - n, d, -n)
# ===========================================================================
def attack_plain_classical(sig, reduce='lll', bkz_block=20):
    n, nb, ell, t = sig['n'], sig['nb'], sig['ell'], sig['t']
    kbi = 2**ell
    B = Matrix(ZZ, t + 2, t + 2)
    for i in range(t):
        B[i, i] = 2 * kbi * n
        B[t,   i] = 2 * kbi * ((sig['r'][i] * inverse_mod(sig['s'][i], n)) % n)
        B[t+1, i] = 2 * kbi * ((sig['kbar'][i] -
                                (sig['z'][i]*inverse_mod(sig['s'][i], n) % n)) % n) + n
    B[t, t] = 1; B[t+1, t+1] = n
    R = do_lll(B) if reduce == 'lll' else do_bkz(B, bkz_block)
    out = []
    for row in R:
        c = Integer(row[t]) % n
        if c: out += [c, (-c) % n]
    return out

# ===========================================================================
# ATTACK 2 : plain HNP, eliminate-d + kernel lattice (cross-check harness)
#   unknowns: eps_1..eps_t ;  rows: h_i eps_i - h_t eps_t = h_i A_i - h_t A_t
# ===========================================================================
def attack_plain_elim(sig, reduce='lll', bkz_block=20):
    n, t = sig['n'], sig['t']
    g, y = sig_params(sig)
    h = [inverse_mod(g[i], n) for i in range(t)]
    A = [(y[i] - sig['kbar'][i]) % n for i in range(t)]
    rows = []
    for i in range(t - 1):
        c = [ZZ(0)] * t
        c[i] = h[i]; c[t-1] = (-h[t-1]) % n
        rows.append((c, n, (h[i]*A[i] - h[t-1]*A[t-1]) % n))
    B, cu, _ = kernel_lattice(t, rows)
    R = do_lll(B) if reduce == 'lll' else do_bkz(B, bkz_block)
    out = []
    for row in R:
        u = Integer(row[cu])
        if u == 0: continue
        eps0 = Integer(row[0])
        if eps0 == 0: continue
        for sgn in (1, -1):
            drec = (h[0] * (-A[0] + sgn*eps0)) % n
            out += [drec, (-drec) % n]
    return out

# ===========================================================================
# ATTACK 3 : LCG nonce, multiplier a KNOWN (I2-A) -- kernel lattice
#   rows (A') from eliminating d, rows (B') from eliminating b:
#     (A')  h_i eps_i - h_t eps_t  = h_i A_i - h_t A_t          (mod n)
#     (B')  eps_{i+2}-(1+a)eps_{i+1}+a eps_i = E_i              (mod 2^m)
# ===========================================================================
def attack_lcg_a(sig, reduce='lll', bkz_block=20):
    n, m, t, a = sig['n'], sig['m'], sig['t'], sig['a']
    two_m = 2**m
    g, y = sig_params(sig)
    h = [inverse_mod(g[i], n) for i in range(t)]
    A = [(y[i] - sig['kbar'][i]) % n for i in range(t)]
    rows = []
    for i in range(t - 1):
        c = [ZZ(0)] * t
        c[i] = h[i]; c[t-1] = (-h[t-1]) % n
        rows.append((c, n, (h[i]*A[i] - h[t-1]*A[t-1]) % n))
    kb = sig['kbar']
    for i in range(t - 2):
        c = [ZZ(0)] * t
        c[i] = a % two_m
        c[i+1] = (-(1 + a)) % two_m
        c[i+2] = 1
        E = (a*kb[i+1] - kb[i+2] - a*kb[i] + kb[i+1]) % two_m
        rows.append((c, two_m, E))
    B, cu, _ = kernel_lattice(t, rows)
    R = do_lll(B) if reduce == 'lll' else do_bkz(B, bkz_block)
    out = []
    for row in R:
        u = Integer(row[cu])
        if u == 0: continue
        eps0 = Integer(row[0])
        if eps0 == 0: continue
        for sgn in (1, -1):
            drec = (h[0] * (-A[0] + sgn*eps0)) % n
            out += [drec, (-drec) % n]
    return out

# ===========================================================================
# ATTACK 4 : LCG nonce, multiplier a UNKNOWN (I2-B) -- best-effort linearisation
#
# The recurrence over Z_{2^m} is
#     k_{i+1} = a*k_i + b   (mod 2^m)
#     =>  eps_{i+1} - a*eps_i - a*kbar_i - b = -kbar_{i+1}   (mod 2^m)
# and the signature equation is  eps_i - g_i*d = A_i  (mod n).
# The term a*eps_i is a PRODUCT of two unknowns, so this is not a linear
# system and cannot be the kernel of one integer matrix.  The only linear
# encoding available is the linearisation gamma_i := a*eps_i with the
# (bilinear) link gamma_i = a*eps_i DROPPED.  The lattice then has unknowns
#   (eps_1..eps_t, gamma_1..gamma_t, a, b, d)
# and the true solution carries gamma_i = a*eps_i ~ 2^(2m) -- i.e. the
# products, not the leakage, dominate the solution vector.  We build exactly
# this lattice and measure it; the purpose of the measurement is to show that
# the bilinear obstruction is real and not an artefact of a bad choice of
# embedding.
# ===========================================================================
def attack_lcg_ab(sig, reduce='lll', bkz_block=20):
    n, m, t = sig['n'], sig['m'], sig['t']
    two_m = 2**m
    r, s, z, kb = sig['r'], sig['s'], sig['z'], sig['kbar']
    # unknown layout: eps[0..t) | gamma[0..t) | a | b | d
    nx = 2*t + 3
    def ce(i): return i
    def cg(i): return t + i
    def ca():  return 2*t
    def cb():  return 2*t + 1
    def cd():  return 2*t + 2
    rows = []
    for i in range(t):                      # (A) eps_i - g_i d = A_i  (mod n)
        g = (r[i] * inverse_mod(s[i], n)) % n
        y = (z[i] * inverse_mod(s[i], n)) % n
        c = [ZZ(0)] * nx
        c[ce(i)] = 1
        c[cd()] = (-g) % n
        rows.append((c, n, (y - kb[i]) % n))
    for i in range(t - 1):                  # (B) eps_{i+1} - gamma_i
        c = [ZZ(0)] * nx                    #      - kbar_i*a - b = -kbar_{i+1}
        c[ce(i+1)] = 1
        c[cg(i)]   = (-1) % two_m
        c[ca()]    = (-kb[i]) % two_m
        c[cb()]    = (-1) % two_m
        rows.append((c, two_m, (-kb[i+1]) % two_m))
    B, cu, _ = kernel_lattice(nx, rows)
    R = do_lll(B) if reduce == 'lll' else do_bkz(B, bkz_block)
    s0 = inverse_mod(s[0], n)
    out = []
    for row in R:
        u = Integer(row[cu])
        d_ = Integer(row[cd()])
        if u == 0 or d_ == 0:
            continue
        for sgn in (1, -1):
            drec = Integer(d_ * sgn) % n
            out += [drec, (-drec) % n]
    return out

# ===========================================================================
# ATTACK 5 : GLV sublattice-structured nonce (I6)
#   unknowns: eps^1_i, eps^2_i (small halves), with
#     k_i = k1_i + lam*k2_i (mod n),  k1_i = kbar1_i + eps^1_i
#   eliminating d from the signature equations gives, for i = 1..t-1,
#     alpha_i eps^1_i + beta_i eps^2_i - alpha_t eps^1_t - beta_t eps^2_t
#                = alpha_i C_i - alpha_t C_t       (mod n)
#   with alpha_i = r_i^-1 s_i, beta_i = alpha_i*lam, C_i = z_i - s_i kbar1_i
#        - s_i lam kbar2_i   (all mod n)
# ===========================================================================
def attack_glv(sig, reduce='lll', bkz_block=20):
    """I6: GLV sublattice embedding.

    k_i = k1_i + lam*k2_i (mod n),  k1_i = kbar1_i + eps1_i (eps1_i < 2^(half-e1)),
    k2_i = kbar2_i + eps2_i.  From  s_i k_i - r_i d = z_i (mod n):
        d = alpha_i*(k1_i + lam*k2_i) - tau_i      (mod n)
    with alpha_i = r_i^-1 s_i, tau_i = r_i^-1 z_i.  Eliminating d by comparing
    signature i with signature t-1 gives, for i = 1..t-1,
        alpha_i eps1_i + beta_i eps2_i - alpha_t eps1_t - beta_t eps2_t
              = C_i - C_t                              (mod n)
    with beta_i = alpha_i*lam, C_i = alpha_i*kbar1_i + beta_i*kbar2_i - tau_i.
    """
    n, t, lam = sig['n'], sig['t'], sig['lam']
    r, s, z = sig['r'], sig['s'], sig['z']
    kb1, kb2 = sig['kbar1'], sig['kbar2']
    alpha = [(inverse_mod(r[i], n) * s[i]) % n for i in range(t)]
    beta = [(alpha[i] * lam) % n for i in range(t)]
    tau = [(inverse_mod(r[i], n) * z[i]) % n for i in range(t)]
    CC = [(alpha[i]*kb1[i] + beta[i]*kb2[i] - tau[i]) % n for i in range(t)]
    nx = 2*t
    def c1(i): return 2*i
    def c2(i): return 2*i + 1
    rows = []
    for i in range(t - 1):
        c = [ZZ(0)] * nx
        c[c1(i)] = alpha[i];  c[c2(i)] = beta[i]
        c[c1(t-1)] = (-alpha[t-1]) % n
        c[c2(t-1)] = (-beta[t-1]) % n
        rows.append((c, n, (CC[t-1] - CC[i]) % n))
    B, cu, _ = kernel_lattice(nx, rows)
    R = do_lll(B) if reduce == 'lll' else do_bkz(B, bkz_block)
    out = []
    for row in R:
        u = Integer(row[cu])
        if u == 0:
            continue
        e1 = Integer(row[c1(0)]); e2 = Integer(row[c2(0)])
        if e1 == 0 or e2 == 0:
            continue
        for sgn in (1, -1):
            k0 = (kb1[0] + sgn*e1 + lam*(kb2[0] + sgn*e2)) % n
            drec = (inverse_mod(r[0], n) * (s[0]*k0 - z[0])) % n
            out += [drec, (-drec) % n]
    return out

# ===========================================================================
# trial runner:  success == d*G == Q
# ===========================================================================
def verify_d(d, Q, C):
    return mulG(int(d), C) == Q

def trial(cand_fn, sig):
    Q, C = sig['Q'], sig['C']
    for d in cand_fn(sig):
        if 0 < int(d) < C['n'] and verify_d(d, Q, C):
            return True
    return False

# ROUND 115, AXIS I -- REFERENCE HARNESS for the ECDSA nonce-leakage (HNP) lattice attack.
#
# PURPOSE: this is the CAMPAIGN'S REFERENCE BASELINE for the HNP family. It is NOT a new
# attack. Every structured-nonce lattice experiment in this round is compared against it.
# A measured baseline is worth more than a tenth new mechanism.
#
# MODEL (stated explicitly, because it decides what the numbers mean):
#   The HNP instance is fully determined by (n ; r_i, s_i, z_i, leaked part of k_i).  The
#   elliptic curve contributes nothing else to the attack -- the lattice never touches a
#   point.  We therefore generate the equations algebraically:
#       d < n uniform, k_i uniform, r_i,s_i uniform in (Z/nZ)^*, z_i uniform,
#       and we DEFINE the leak of k_i (msb / lsb / range).
#   A real-curve cross-check (secp256k1) at the end confirms that genuine (r,s) pairs from
#   an actual signing operation behave identically -- they must, since the lattice depends
#   only on the equation; the check is that they do.
#
# THE LATTICE, derived from first principles (no remembered formulas -- see the derivation
# notes at the bottom of this header), then verified empirically on a positive control:
#
#   signature equation:   s_i * k_i = z_i + r_i * d            (mod n)
#   k_i = a_i + K_i, a_i known, K_i < 2^m  (m = nbits - l):
#             - r_i * d + s_i * K_i  =  c_i                     (mod n),  c_i = z_i - s_i a_i
#
#   chi(x) = (-r_i x_0 + s_i x_i)_i  is surjective onto (Z/nZ)^t, so ker(chi) has index
#   n^t in Z^{t+1}, and a basis is
#         B = [ (1, beta_1, ..., beta_t) ;  n e_1 ; ... ; n e_t ],   beta_i = r_i s_i^{-1} mod n
#   (check: chi(1,beta) = (-r_i + s_i beta_i) = (-r_i + r_i) = 0; chi(n e_i) = 0.)
#   A particular solution is v_p = (0, c_1 s_1^{-1}, ..., c_t s_t^{-1}) mod n.
#   Hence every solution is v_p + lambda, lambda in B, and the true key is
#         v_true = (d, K_1, ..., K_t) = v_p + lambda_true.
#
#   Kannan embedding (SVP form) with column scaling S_i = 2^(nbits-m):
#         rows 0..t      : the basis B above, scaled
#         row  t+1       : (0, S_1 v_p[1], ..., S_t v_p[t], B_big)      <- target row
#   After reduction, rows whose last coordinate is +/- B_big are candidate solutions;
#   the key is the first coordinate, read back mod n.
#
# SUCCESS DEFINITION (campaign rule): the recovered key must equal the ground truth d.
# A "small row" that is not the key is NOT a success -- that is the pigeonhole failure
# mode that has burned this campaign before, so those rows are counted separately.
#
# ENVIRONMENT TRAP (verified on this box): `sage file.sage` in Sage 10.9 preparses and
# execs with __name__ == 'sage.all', NOT '__main__'.  An `if __name__ == "__main__":`
# block therefore silently does nothing.  Dispatch on sys.argv at top level.

import sys, json, time
from sage.all import matrix, ZZ, randint, set_random_seed as sageseed

try:
    from fpylll import IntegerMatrix, LLL as FpLLL
    HAVE_FPYLLL = True
except Exception:
    HAVE_FPYLLL = False

SECP256K1_P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
SECP256K1_B = 7
SECP256K1_Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
SECP256K1_Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
SECP256K1_N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141


# ------------------------------------------------------------------ instance builder
def build_instance(nbits, t, l, mode, sd=0):
    sageseed(sd)
    n = ZZ((1 << nbits) - 1)
    while not n.is_prime():
        n -= 2
    d = ZZ(randint(1, n - 1))
    ks, rs, ss, zs, a = [], [], [], [], []
    m = nbits - l
    for _ in range(t):
        k = ZZ(randint(1, n - 1))
        if mode == "range":
            k = ZZ(randint(1, (ZZ(1) << m) - 1))
        r = ZZ(randint(1, n - 1))
        z = ZZ(randint(0, n - 1))
        # GROUND TRUTH: the signature equation s*k = z + r*d (mod n) must hold, so s
        # is DETERMINED by (k, r, z, d).  Generating s independently at random would
        # produce algebraically inconsistent instances that no attack can touch.
        s = (z + r * d) * inverse_mod(k, n) % n
        if mode == "msb":
            leak = (k >> m) << m
        elif mode == "lsb":
            leak = k % (ZZ(1) << l)
        elif mode == "range":
            leak = ZZ(0)
        else:
            raise ValueError(mode)
        ks.append(k); rs.append(r); ss.append(s); zs.append(z); a.append(leak)
    return dict(n=n, nbits=nbits, t=t, l=l, mode=mode, d=d, k=ks, r=rs, s=ss, z=zs, a=a)


# ------------------------------------------------------------------ the attack
def attack(inst, w_shift=0, algo="lll", bkz_block=20, verbose=False):
    """SVP / Kannan embedding of the HNP. Returns (d or None, n_wrong_candidates, stats).

    The solution set of the congruences  -r_i d + s_i K_i = c_i (mod n), with d < n and
    K_i < 2^m (m = nbits - l), is v_p + Lambda where Lambda = ker(chi) has det n^t.
    The number of lattice points inside the box is ~ 2^(t*m) / n^(t-1), so the solution
    is unique exactly when t*l >= log2(n) -- the information-theoretic floor, and the
    quantity this harness measures.  Embedding (dimension t+2), with S_i = 2^l:
        row 0   : (1, S_1 beta_1, ..., S_t beta_t, 0)
        row i   : (0, ..., n S_i, ..., 0)
        row t+1 : (0, S_1 vp_1, ..., S_t vp_t, B),   B = 2^(nbits + w_shift)
    The true key is the first coordinate of any row whose last coordinate is +/- B.
    """
    n, t, l = inst["n"], inst["t"], inst["l"]
    r, s, z, a = inst["r"], inst["s"], inst["z"], inst["a"]
    nbits = inst["nbits"]
    c = [(z[i] - s[i] * a[i]) % n for i in range(t)]
    beta, vp = [], []
    for i in range(t):
        si_inv = inverse_mod(s[i], n)
        beta.append((r[i] * si_inv) % n)
        vp.append((c[i] * si_inv) % n)

    S = [ZZ(1)] + [ZZ(1) << l for _ in range(t)]
    B = ZZ(1) << (nbits + w_shift)
    M = matrix(ZZ, t + 2, t + 2)
    M[0, 0] = ZZ(1)
    for i in range(t):
        M[0, 1 + i] = S[1 + i] * beta[i]
    for i in range(t):
        M[1 + i, 1 + i] = n * S[1 + i]
    for i in range(t):
        M[t + 1, 1 + i] = S[1 + i] * vp[i]
    M[t + 1, t + 1] = B

    R = M.BKZ(block_size=bkz_block, proof=False) if algo == "bkz" else M.LLL()

    wrong = 0
    for i in range(R.nrows()):
        v = R.row(i)
        if v[t + 1] != B and v[t + 1] != -B:
            continue
        x = [v[j] // S[j] for j in range(t + 1)]
        dk = x[0] % n
        if all((s[j] * (x[1 + j] % n) - r[j] * dk - c[j]) % n == 0 for j in range(t)):
            if dk == inst["d"] % n:
                return int(dk), wrong, dict(alg="svp-kannan", Bbits=int(nbits + w_shift))
            wrong += 1
    return None, wrong, dict(alg="svp-kannan", Bbits=int(nbits + w_shift))


def real_curve(ls=(0, 16, 32, 64, 96, 128, 160, 192, 224, 256)):
    """Cross-check on genuine secp256k1 signatures (see header for why it must agree)."""
    from sage.all import GF, EllipticCurve
    F = GF(SECP256K1_P)
    E = EllipticCurve(F, [0, SECP256K1_B])
    G = E(SECP256K1_Gx, SECP256K1_Gy)
    sageseed(7)
    d = ZZ(randint(1, SECP256K1_N - 1))
    t = 4
    inst = dict(n=ZZ(SECP256K1_N), nbits=256, t=t, l=0, mode="msb",
                d=d, k=[], r=[], s=[], z=[], a=[])
    for _ in range(t):
        kk = ZZ(randint(1, SECP256K1_N - 1))
        P = kk * G
        r = ZZ(P[0]) % SECP256K1_N
        z = ZZ(randint(0, SECP256K1_N - 1))
        s = (z + r * d) * inverse_mod(kk, SECP256K1_N) % SECP256K1_N
        inst["k"].append(kk); inst["r"].append(r); inst["s"].append(s); inst["z"].append(z)
    ok = all(inst["s"][i] * inst["k"][i] % SECP256K1_N
             == (inst["z"][i] + inst["r"][i] * d) % SECP256K1_N for i in range(t))
    print("real secp256k1 signature equations consistent:", ok, flush=True)
    for l in ls:
        inst["l"] = l
        inst["a"] = [(inst["k"][i] >> (256 - l)) << (256 - l) for i in range(t)]
        dd, wrong, st = attack(inst, algo="lll")
        print(f"  real secp256k1 t=4 l={l:3d} t*l={4*l:4d} floor=256 -> "
              f"{'RECOVERED' if dd else 'no'}", flush=True)

#!/usr/bin/env sage
# -*- coding: utf-8 -*-
#
# INDEPENDENT END-TO-END VERIFICATION of the composed attack (round 119).
#
# This file deliberately REUSES NOTHING from attack.sage.  It carries its own
#   * pure-Python secp256k1 arithmetic (affine double-and-add scalar multiplication),
#   * its own ECDSA signer,
#   * its own full ECDSA *verifier*,
#   * its own deterministic hash-chain RNG (no Python `random`, no Sage random state),
# so that the two ground-truth requirements of this campaign are checked by machinery
# independent of the attack's own Sage EC calls:
#
#     1. every recovered key satisfies  d_rec · G == Q_true, and
#     2. the PUBLISHED signatures actually verify under Q_rec = d_rec · G
#        (the strongest form: an ECDSA signature verifies under Q_rec exactly when
#         d_rec is the private key that produced it).
#
# It also closes the remaining hole in the t=2 null: the alternative accounting in which
# the per-key SEED nonces are treated as extra unknowns (D+1+2L unknowns, one extra
# equation per key) is built explicitly and shown to be underdetermined as well.
#
# Reproduce:  /home/raver1975/sage_mamba/envs/sage/bin/sage \
#               factor-scratch/r119/chained-shared/verify_e2e.sage

import hashlib

P  = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
N  = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
G  = (Gx, Gy)


class RNG(object):
    """deterministic 256-bit hash chain; reproducible and independent of any library"""
    def __init__(self, tag):
        self.b = hashlib.sha256(bytes(str(tag), 'utf-8')).digest()

    def _next(self):
        h = int.from_bytes(hashlib.sha256(self.b).digest(), 'big')
        self.b = hashlib.sha256(self.b + b'|').digest()
        return h

    def below(self, m):
        """uniform-ish in [0, m) -- modulo bias ~2^-128, irrelevant for a linear system"""
        return self._next() % m


def inv(a, m):
    return pow(a % m, m - 2, m)


def padd(p, q):
    """affine point addition on secp256k1"""
    if p is None:
        return q
    if q is None:
        return p
    x1, y1 = p
    x2, y2 = q
    if x1 == x2 and (y1 + y2) % P == 0:
        return None
    if p == q:
        lam = (3 * x1 * x1) * inv(2 * y1, P) % P
    else:
        lam = (y2 - y1) * inv((x2 - x1) % P, P) % P
    x3 = (lam * lam - x1 - x2) % P
    y3 = (lam * (x1 - x3) - y1) % P
    return (x3, y3)


def pmul(k, p):
    r = None
    a = p
    while k:
        if k & 1:
            r = padd(r, a)
        a = padd(a, a)
        k = k // 2
    return r


def pubkey(d):
    return pmul(d, G)


def ecdsa_verify(Q, z, r, s):
    """the real ECDSA verification equation: X = (z/s)G + (r/s)Q, compare X_x mod n to r"""
    if not (1 <= r < N and 1 <= s < N):
        return False
    w = inv(s, N)
    X = padd(pmul(z * w % N, G), pmul(r * w % N, Q))
    if X is None:
        return False
    return X[0] % N == r


# ------------------------------------------------------------------ sanity: verifier ----
print("=" * 100)
print("0. sanity check of the INDEPENDENT machinery (not the attack)")
print("=" * 100)
rng0 = RNG("verifier-sanity")
ok_sig = ok_bad = 0
for _ in range(5):
    d = rng0.below(N - 1) + 1
    Q = pubkey(d)
    z = rng0.below(N)
    k = rng0.below(N - 1) + 1
    R = pmul(k, G)
    r = R[0] % N
    s = inv(k, N) * (z + r * d) % N
    ok_sig += ecdsa_verify(Q, z, r, s)
    ok_bad += (not ecdsa_verify(pubkey(d + 1), z, r, s))       # a wrong key must fail
print(f"  {ok_sig}/5 freshly signed signatures verify under their own public key")
print(f"  {ok_bad}/5 the same signatures FAIL under a wrong public key "
      f"(so verification is discriminating)")
assert ok_sig == 5 and ok_bad == 5
print()


# --------------------------------------------------------------- the composed model -----
def build_instance(L, sig_cnts, D, seed):
    """L chained nonce generators sharing (a_1..a_D, Delta).  Pure Python / Sage ints.

       k_{k,0} = fresh seed                        (OUTSIDE the family)
       k_{k,i} = sum_j a_j g_j(sig k,i-1) + Delta  for i >= 1
    """
    rng = RNG(seed)
    ds = [rng.below(N - 1) + 1 for _ in range(L)]               # each key drawn ONCE
    Qs = [pubkey(d) for d in ds]
    for d, Q in zip(ds, Qs):
        assert pubkey(d) == Q                                    # ground truth, pure python
    a = [rng.below(1 << 60) for _ in range(D)]
    delta = rng.below(N - 1) + 1
    seeds = [rng.below(N - 1) + 1 for _ in range(L)]
    sigs = []
    for k in range(L):
        kn = seeds[k]                        # the SEED nonce: outside the family
        prev = None
        for i in range(sig_cnts[k]):
            z = rng.below(N)
            assert kn % N != 0
            R = pmul(kn, G)
            r = R[0] % N
            assert r != 0
            s = inv(kn, N) * (z + r * ds[k]) % N
            row = None
            if i >= 1:
                g = prev                    # public values of the PREVIOUS signature
                row = [s * gj for gj in g] + [s % N] + [0] * L
                row[D + 1 + k] = (-r) % N
            # next signal vector: D DISTINCT public functions of THIS signature
            nxt = [r, s, z]
            e = 2
            while len(nxt) < D:
                nxt.append(pow(r, e, N))
                e += 1
            sigs.append(dict(key=k, i=i, z=z, r=r, s=s, row=row))
            prev = nxt[:D]
            kn = (sum(a[j] * nxt[j] for j in range(D)) + delta) % N
    return dict(ds=ds, Qs=Qs, a=a, delta=delta, seeds=seeds, sigs=sigs, D=D, L=L)


def attack(inst):
    """the linear-algebra attack, expressed over GF(N) with Sage matrices"""
    D, L = inst['D'], inst['L']
    usable = [sg for sg in inst['sigs'] if sg['row'] is not None]
    part = sorted(set(sg['key'] for sg in usable))
    idx = {k: p for p, k in enumerate(part)}
    rows = [rw['row'][:D + 1] + [rw['row'][D + 1 + idx[k]] for k in part] for rw in usable]
    A = matrix(GF(N), rows)
    b = vector(GF(N), [sg['z'] for sg in usable])
    try:
        sol = A.solve_right(b)
        drec = {k: ZZ(sol[D + 1 + idx[k]] % N) for k in part}
    except ValueError:
        drec = {k: None for k in part}
    return drec, A.rank(), D + 1 + len(part)


def full_check(label, L, sig_cnts, D, seed):
    inst = build_instance(L, sig_cnts, D, seed)
    drec, rk, nunk = attack(inst)
    Qok = ver = 0
    for k in sorted(drec):
        q = pubkey(drec[k])
        if q == inst['Qs'][k]:                       # ground truth 1, pure python
            Qok += 1
        ns = [sg for sg in inst['sigs'] if sg['key'] == k]
        if ns and all(ecdsa_verify(q, sg['z'], sg['r'], sg['s']) for sg in ns):
            ver += 1                                   # ground truth 2, full ECDSA verify
    print(f"  {label:>26}: rank {rk}/{nunk} | d_rec*G == Q {Qok}/{len(drec)} | "
          f"all sigs verify under Q_rec {ver}/{L}")
    return ver, L


print("=" * 100)
print("1. HEADLINE -- D=1, L=10, 30 signatures (3 per key): every key falls")
print("=" * 100)
good = tot = 0
for sd in ["hdr-a", "hdr-b", "hdr-c"]:
    g, t = full_check(f"L=10 t=3 {sd}", 10, [3] * 10, 1, sd)
    good += g
    tot += t
print(f"  TOTAL: {good}/{tot} keys recovered, each verified two independent ways")
assert good == tot
print()

print("=" * 100)
print("2. THE NULL -- D=1, L=10, 20 signatures (2 per key): nothing falls")
print("=" * 100)
g2 = t2 = 0
for sd in ["nul-a", "nul-b", "nul-c", "nul-d"]:
    g, t = full_check(f"L=10 t=2 {sd}", 10, [2] * 10, 1, sd)
    g2 += g
    t2 += t
print(f"  TOTAL: {g2}/{t2} keys recovered.  The solver still returns *a* solution of the")
print(f"  underdetermined system, and that solution FAILS full ECDSA verification --")
print(f"  so the null is a real information deficit, not a solver artefact.")
assert g2 == 0
print()

print("=" * 100)
print("3. THE SEED NONCES AS UNKNOWNS -- the accounting that says '20 >= 12, so it works'")
print("=" * 100)
print("  Treat each per-key seed nonce k_{k,0} as an extra unknown.  Unknowns = D+1+2L,")
print("  equations = L*t.  For L=10, D=1: 22 unknowns against 20 equations.")
inst = build_instance(10, [2] * 10, 1, "seed-unknowns")
D, L = inst['D'], inst['L']
rows, rhs = [], []
for sg in inst['sigs']:
    k, z, r, s, i = sg['key'], sg['z'], sg['r'], sg['s'], sg['i']
    if i == 0:
        # s_0 * k_{k,0} = z_0 + r_0 * d_k   (k_{k,0} now an unknown)
        row = [0] * (D + 2 * L + 1)      # D a's + Delta + L seed nonces + L private keys
        row[D + 1 + k] = s          # column of key k's seed nonce
        row[D + 1 + L + k] = (-r) % N    # column of d_k
    else:
        # the row already carries [s*g_1 ... s*g_D, s]: take it as it is, then pad the
        # L seed-nonce columns with zeros
        row = list(sg['row'][:D + 1]) + [0] * (2 * L)
        row[D + 1 + L + k] = (-r) % N
    rows.append(row)
    rhs.append(z)
A2 = matrix(GF(N), rows)
b2 = vector(GF(N), rhs)
ker2 = A2.right_kernel()
print(f"  equations {A2.nrows()}   unknowns {A2.ncols()}   rank {A2.rank()}   "
      f"kernel dim {ker2.dimension()}")
print(f"  -> still short by {A2.ncols() - A2.rank()}: every seed signature introduces exactly")
print(f"     one new unknown (its own seed nonce), so it buys no information whatsoever.")
xs = vector(GF(N), [aj % N for aj in inst['a']] + [inst['delta'] % N] +
            [inst['seeds'][k] % N for k in range(L)] + [inst['ds'][k] % N for k in range(L)])
print(f"  the TRUE vector satisfies this system too: {A2 * xs == b2}")
print(f"  (so the failure is not a modelling error -- the system is genuinely 2 short)")
print()
print("=" * 100)
print("CONCLUSION: 3 signatures per key (30 total, 20 usable equations) break all 10 keys,")
print("verified by d_rec*G == Q AND by full ECDSA verification under Q_rec, both with an")
print("independent pure-Python secp256k1.  2 per key (20 total, 10 usable equations) break")
print("none, and no alternative accounting of the seed signatures changes that.")
print("=" * 100)

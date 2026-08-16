"""
Alternating pairings, the determinant form, and aggregate BLS signatures
========================================================================

Self-contained numerical demonstration of every result in the accompanying
paper, carried out inside the *determinant model*:

    A      = (Z/n) x (Z/n)                 the "torsion group"
    mu_n   = Z/n written multiplicatively  the target group of n-th roots of unity
    e(v,w) = zeta_0 ^ det(v,w),  det(v,w) = v1*w2 - v2*w1   (mod n)

We represent an element zeta_0^k of mu_n by its exponent k in Z/n, so that the
multiplicative group law of mu_n is addition mod n.  Every identity of the
paper is then a statement about integers mod n, and can be checked by
exhaustive enumeration over the whole parameter space.

Contents
--------
 1. The determinant pairing and its basic laws (skew-symmetry, bilinearity,
    blindness on cyclic subgroups).
 2. The forcing theorem: bi-additivity + alternation => determinant form.
 3. Classification: every alternating pairing is u*det; nondegenerate iff u is
    a unit.  Counting nondegenerate pairings = phi(n).
 4. Rank obstruction: on a cyclic subgroup the pairing is identically trivial.
 5. Endomorphism/degree law: e(Mv, Mw) = e(v,w)^det(M);  e(mv,mw)=e(v,w)^(m^2).
 6. MOV embedding and the collapse of decisional Diffie-Hellman.
 7. The obstruction theorem for the symmetric model with injective
    P |-> e(P,G): it forces the whole group to be trivial.
 8. BLS in the corrected asymmetric setting: correctness, the exact
    verification criterion s = sk*h (mod n), uniqueness.
 9. Aggregation: correctness, uniqueness, aggregate-to-single extraction,
    the CDH reduction, batch verification.
10. Exact compression:  N^m signatures  -->  N aggregates.
11. The rogue-key attack.

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import gcd
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Vec = Tuple[int, int]  # element of (Z/n)^2


# ---------------------------------------------------------------------------
# 1. The determinant pairing
# ---------------------------------------------------------------------------

def elements(n: int) -> List[Vec]:
    """All elements of the group (Z/n)^2."""
    return [(a, b) for a in range(n) for b in range(n)]


def add(n: int, v: Vec, w: Vec) -> Vec:
    """Group addition in (Z/n)^2."""
    return ((v[0] + w[0]) % n, (v[1] + w[1]) % n)


def sub(n: int, v: Vec, w: Vec) -> Vec:
    """Group subtraction in (Z/n)^2."""
    return ((v[0] - w[0]) % n, (v[1] - w[1]) % n)


def smul(n: int, k: int, v: Vec) -> Vec:
    """Scalar action of k in Z on (Z/n)^2."""
    return ((k * v[0]) % n, (k * v[1]) % n)


def det_form(n: int, v: Vec, w: Vec) -> int:
    """The determinant form det(v,w) = v1*w2 - v2*w1 in Z/n."""
    return (v[0] * w[1] - v[1] * w[0]) % n


def pairing(n: int, u: int) -> Callable[[Vec, Vec], int]:
    """
    The alternating pairing with scalar u:  e_u(v,w) = zeta_0^(u * det(v,w)).
    Returned as the exponent map (v,w) |-> u*det(v,w) mod n, since the target
    group mu_n is represented additively by its exponents.
    """
    def e(v: Vec, w: Vec) -> int:
        return (u * det_form(n, v, w)) % n
    return e


# ---------------------------------------------------------------------------
# 2-3. Basic laws, forcing, classification
# ---------------------------------------------------------------------------

def check_basic_laws(n: int) -> Dict[str, bool]:
    """Alternation, skew-symmetry, bi-additivity, Z-bilinearity."""
    e = pairing(n, 1)
    els = elements(n)
    alternating = all(e(v, v) == 0 for v in els)
    skew = all((e(v, w) + e(w, v)) % n == 0 for v in els for w in els)
    biadd_left = all(
        e(add(n, v, w), z) == (e(v, z) + e(w, z)) % n
        for v in els for w in els for z in els
    )
    biadd_right = all(
        e(v, add(n, w, z)) == (e(v, w) + e(v, z)) % n
        for v in els for w in els for z in els
    )
    bilinear = all(
        e(smul(n, k, v), w) == (k * e(v, w)) % n
        for k in range(n) for v in els for w in els
    )
    return {
        "alternating e(v,v)=1": alternating,
        "skew-symmetry e(w,v)=e(v,w)^-1": skew,
        "additive in first slot": biadd_left,
        "additive in second slot": biadd_right,
        "Z-bilinear e(kv,w)=e(v,w)^k": bilinear,
    }


def check_forcing_theorem(n: int) -> bool:
    """
    Forcing theorem:  e(a*eps1 + b*eps2, c*eps1 + d*eps2) = zeta^(ad-bc)
    where zeta = e(eps1, eps2).  Checked for every alternating pairing
    (i.e. every scalar u) and all integer coefficients mod n.
    """
    eps1, eps2 = (1, 0), (0, 1)
    for u in range(n):
        e = pairing(n, u)
        zeta = e(eps1, eps2)  # exponent of the root of unity
        for a, b, c, d in product(range(n), repeat=4):
            left = e(
                add(n, smul(n, a, eps1), smul(n, b, eps2)),
                add(n, smul(n, c, eps1), smul(n, d, eps2)),
            )
            right = (zeta * (a * d - b * c)) % n
            if left != right:
                return False
    return True


def is_nondegenerate(n: int, e: Callable[[Vec, Vec], int]) -> bool:
    """No nonzero v pairs trivially with everything."""
    for v in elements(n):
        if v == (0, 0):
            continue
        if all(e(v, w) == 0 for w in elements(n)):
            return False
    return True


def euler_phi(n: int) -> int:
    """Euler's totient, by direct counting."""
    return sum(1 for a in range(n) if gcd(a, n) == 1)


def classify_pairings(n: int) -> Tuple[List[int], int]:
    """
    Return the list of scalars u for which e_u is nondegenerate, together with
    phi(n).  Theorem: these coincide with the units of Z/n.
    """
    nondeg = [u for u in range(n) if is_nondegenerate(n, pairing(n, u))]
    return nondeg, euler_phi(n)


# ---------------------------------------------------------------------------
# 4-5. Rank obstruction, degree law, endomorphisms
# ---------------------------------------------------------------------------

def check_cyclic_blindness(n: int) -> bool:
    """e(a*v, b*v) = 1 for all a,b and all v: an alternating pairing sees
    nothing inside a cyclic subgroup.  This is the rank obstruction."""
    e = pairing(n, 1)
    return all(
        e(smul(n, a, v), smul(n, b, v)) == 0
        for a in range(n) for b in range(n) for v in elements(n)
    )


def lin_map(n: int, m: Tuple[int, int, int, int], v: Vec) -> Vec:
    """Apply the endomorphism with matrix [[a,b],[c,d]] to v."""
    a, b, c, d = m
    return ((a * v[0] + b * v[1]) % n, (c * v[0] + d * v[1]) % n)


def check_endomorphism_law(n: int) -> bool:
    """det(Mv, Mw) = det(M) * det(v,w) for every 2x2 matrix over Z/n."""
    for m in product(range(n), repeat=4):
        a, b, c, d = m
        dm = (a * d - b * c) % n
        for v, w in product(elements(n), repeat=2):
            if det_form(n, lin_map(n, m, v), lin_map(n, m, w)) != (dm * det_form(n, v, w)) % n:
                return False
    return True


def check_degree_law(n: int) -> bool:
    """e(mv, mw) = e(v,w)^(m^2): the scalar matrix case of the endomorphism law."""
    e = pairing(n, 1)
    return all(
        e(smul(n, m, v), smul(n, m, w)) == (m * m * e(v, w)) % n
        for m in range(n) for v, w in product(elements(n), repeat=2)
    )


# ---------------------------------------------------------------------------
# 6. MOV embedding and DDH
# ---------------------------------------------------------------------------

def mov_table(n: int) -> List[int]:
    """
    With P = eps1, Q = eps2 and zeta = e(P,Q) of exact order n, the map
    a |-> e(aP, Q) = zeta^a is injective on {0,...,n-1}: the curve discrete
    logarithm embeds into the discrete logarithm in mu_n.
    """
    e = pairing(n, 1)
    p, q = (1, 0), (0, 1)
    return [e(smul(n, a, p), q) for a in range(n)]


def ddh_test(n: int, a: int, b: int, c: int) -> bool:
    """
    The publicly computable DDH distinguisher:  e(aP, bQ) =? e(P, cQ).
    Inputs are only the *group elements* aP, bQ, cQ -- never a, b, c.
    """
    e = pairing(n, 1)
    p, q = (1, 0), (0, 1)
    aP, bQ, cQ = smul(n, a, p), smul(n, b, q), smul(n, c, q)
    return e(aP, bQ) == e(p, cQ)


def check_ddh_collapse(n: int) -> bool:
    """The test succeeds exactly when c = ab mod n: DDH is easy."""
    return all(
        ddh_test(n, a, b, c) == ((a * b) % n == c % n)
        for a, b, c in product(range(n), repeat=3)
    )


def check_ddh_blind_on_cyclic(n: int) -> bool:
    """On a single cyclic subgroup the same test is vacuous: both sides are 1."""
    e = pairing(n, 1)
    p = (1, 0)
    return all(
        e(smul(n, a, p), smul(n, b, p)) == 0 and e(p, smul(n, c, p)) == 0
        for a, b, c in product(range(n), repeat=3)
    )


# ---------------------------------------------------------------------------
# 7. The obstruction theorem for the symmetric model
# ---------------------------------------------------------------------------

def symmetric_model_injective_generators(n: int) -> List[Vec]:
    """
    Search for a generator G such that P |-> e(P, G) is injective on the whole
    group.  The obstruction theorem says: none exists unless the group is
    trivial (n = 1).  Alternation gives e(G,G) = 1 = e(0,G), forcing G = 0,
    and then e(.,0) is constant.
    """
    e = pairing(n, 1)
    els = elements(n)
    good: List[Vec] = []
    for g in els:
        images = [e(pt, g) for pt in els]
        if len(set(images)) == len(els):
            good.append(g)
    return good


# ---------------------------------------------------------------------------
# 8. BLS in the corrected asymmetric setting
# ---------------------------------------------------------------------------

class BLSSetting:
    """
    The corrected (type-3) BLS setting over the determinant model:

        g1 = (1,0)  signature generator,   g2 = (0,1)  key generator,
        zeta = e(g1, g2) has exact order n.

    public key  pk(sk) = sk * g2
    hash point  H(h)   = h  * g1
    signature   sig    = (sk*h) * g1
    verify      e(sigma, g2) == e(H, pk)
    """

    def __init__(self, n: int) -> None:
        self.n = n
        self.g1: Vec = (1, 0)
        self.g2: Vec = (0, 1)
        self.e = pairing(n, 1)

    # --- scheme --------------------------------------------------------
    def public_key(self, sk: int) -> Vec:
        return smul(self.n, sk, self.g2)

    def hash_point(self, h: int) -> Vec:
        return smul(self.n, h, self.g1)

    def sign(self, sk: int, h: int) -> Vec:
        return smul(self.n, sk * h, self.g1)

    def verifies(self, pk: Vec, hpt: Vec, sigma: Vec) -> bool:
        return self.e(sigma, self.g2) == self.e(hpt, pk)

    # --- root of unity -------------------------------------------------
    def root_order(self) -> int:
        """Exact order of zeta = e(g1, g2) in mu_n."""
        zeta = self.e(self.g1, self.g2)
        k = 1
        while (k * zeta) % self.n != 0:
            k += 1
        return k

    # --- aggregation ---------------------------------------------------
    def aggregate(self, sigmas: Sequence[Vec]) -> Vec:
        out: Vec = (0, 0)
        for s in sigmas:
            out = add(self.n, out, s)
        return out

    def agg_verifies(self, pks: Sequence[Vec], hpts: Sequence[Vec], sigma: Vec) -> bool:
        """e(sigma, g2) == prod_i e(H_i, pk_i); the product is a sum of exponents."""
        rhs = 0
        for pk, hpt in zip(pks, hpts):
            rhs = (rhs + self.e(hpt, pk)) % self.n
        return self.e(sigma, self.g2) == rhs

    def batch_verifies(
        self,
        pks: Sequence[Vec],
        hpts: Sequence[Vec],
        sigs: Sequence[Vec],
        weights: Sequence[int],
    ) -> bool:
        lhs_pt: Vec = (0, 0)
        for r, s in zip(weights, sigs):
            lhs_pt = add(self.n, lhs_pt, smul(self.n, r, s))
        rhs = 0
        for r, pk, hpt in zip(weights, pks, hpts):
            rhs = (rhs + r * self.e(hpt, pk)) % self.n
        return self.e(lhs_pt, self.g2) == rhs

    # --- rogue key -----------------------------------------------------
    def rogue_public_key(self, y: int, pk1: Vec) -> Vec:
        """y*g2 - pk1: computable from the victim's public key alone."""
        return sub(self.n, smul(self.n, y, self.g2), pk1)


def check_bls_correctness(n: int) -> bool:
    """Every honest signature verifies (all n^2 key/message pairs)."""
    S = BLSSetting(n)
    return all(
        S.verifies(S.public_key(sk), S.hash_point(h), S.sign(sk, h))
        for sk in range(n) for h in range(n)
    )


def check_verification_criterion(n: int) -> bool:
    """
    Exact criterion: the candidate s*g1 is accepted  <=>  s = sk*h (mod n).
    Checked over all n^3 triples.  Equivalently, signatures are unique.
    """
    S = BLSSetting(n)
    for sk, h, s in product(range(n), repeat=3):
        accepted = S.verifies(S.public_key(sk), S.hash_point(h), smul(n, s, S.g1))
        if accepted != (s % n == (sk * h) % n):
            return False
    return True


def check_aggregate_correctness(n: int, m: int) -> bool:
    """The sum of m honest signatures satisfies the aggregate equation."""
    S = BLSSetting(n)
    for sks in product(range(n), repeat=m):
        for hs in product(range(n), repeat=m):
            pks = [S.public_key(sk) for sk in sks]
            hpts = [S.hash_point(h) for h in hs]
            sigma = S.aggregate([S.sign(sk, h) for sk, h in zip(sks, hs)])
            if not S.agg_verifies(pks, hpts, sigma):
                return False
    return True


def check_forgery_extraction(n: int, m: int) -> bool:
    """
    Aggregate-to-single extraction: from ANY sigma = t*g1 satisfying the
    aggregate equation, subtracting the known co-signer contributions yields a
    valid single-signer signature for the target index 0.
    """
    S = BLSSetting(n)
    for sks in product(range(n), repeat=m):
        for hs in product(range(n), repeat=m):
            pks = [S.public_key(sk) for sk in sks]
            hpts = [S.hash_point(h) for h in hs]
            for t in range(n):
                sigma = smul(n, t, S.g1)
                if not S.agg_verifies(pks, hpts, sigma):
                    continue
                cosigners = S.aggregate([S.sign(sks[i], hs[i]) for i in range(1, m)])
                extracted = sub(n, sigma, cosigners)
                if not S.verifies(pks[0], hpts[0], extracted):
                    return False
    return True


def check_cdh_reduction(n: int, m: int) -> bool:
    """
    The extracted forgery IS the computational Diffie-Hellman target
    T = a * H(h(m*)), where a = sk_0 is the challenge secret.
    """
    S = BLSSetting(n)
    for sks in product(range(n), repeat=m):
        for hs in product(range(n), repeat=m):
            pks = [S.public_key(sk) for sk in sks]
            hpts = [S.hash_point(h) for h in hs]
            target = smul(n, sks[0], hpts[0])  # CDH answer
            for t in range(n):
                sigma = smul(n, t, S.g1)
                if not S.agg_verifies(pks, hpts, sigma):
                    continue
                cosigners = S.aggregate([S.sign(sks[i], hs[i]) for i in range(1, m)])
                if sub(n, sigma, cosigners) != target:
                    return False
    return True


def check_batch_verification(n: int, m: int) -> bool:
    """
    A family passes every weighted batch check  <=>  every signature verifies
    individually.  The forward direction uses the indicator weights.
    """
    S = BLSSetting(n)
    all_weights = list(product(range(n), repeat=m))
    for sks in product(range(n), repeat=m):
        for hs in product(range(n), repeat=m):
            for ts in product(range(n), repeat=m):  # candidate signatures t_i*g1
                pks = [S.public_key(sk) for sk in sks]
                hpts = [S.hash_point(h) for h in hs]
                sigs = [smul(n, t, S.g1) for t in ts]
                all_batches = all(S.batch_verifies(pks, hpts, sigs, w) for w in all_weights)
                all_single = all(
                    S.verifies(pks[i], hpts[i], sigs[i]) for i in range(m)
                )
                if all_batches != all_single:
                    return False
    return True


def check_rogue_key_attack(n: int) -> bool:
    """
    Universal forgery without any secret key: with pk2 = y*g2 - pk1 and
    sigma = y*H, the two-signer aggregate equation holds for EVERY y, pk1, H.
    """
    S = BLSSetting(n)
    for y in range(n):
        for pk1 in elements(n):
            for hpt in elements(n):
                pk2 = S.rogue_public_key(y, pk1)
                sigma = smul(n, y, hpt)
                if not S.agg_verifies([pk1, pk2], [hpt, hpt], sigma):
                    return False
    return True


# ---------------------------------------------------------------------------
# 10. Exact compression
# ---------------------------------------------------------------------------

def compression_profile(n: int, m: int) -> Tuple[int, int, int]:
    """
    Return (N^m, |image of aggregation|, N).  Theorem: the image is all of the
    group, so aggregation realises exactly an N^m ->> N compression.
    """
    els = elements(n)
    N = len(els)
    image = set()
    for tup in product(els, repeat=m):
        acc: Vec = (0, 0)
        for v in tup:
            acc = add(n, acc, v)
        image.add(acc)
    return N ** m, len(image), N


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def report(label: str, ok: bool) -> None:
    print(f"  [{'OK ' if ok else 'FAIL'}]  {label}")


def main() -> None:
    rule("1. Basic laws of the determinant pairing on (Z/5)^2")
    for label, ok in check_basic_laws(5).items():
        report(label, ok)

    rule("2. The forcing theorem: alternation + bi-additivity => determinant")
    report("e(a e1 + b e2, c e1 + d e2) = zeta^(ad-bc)  over (Z/4)^2, all pairings",
           check_forcing_theorem(4))
    report("same over (Z/5)^2", check_forcing_theorem(5))

    rule("3. Classification of alternating pairings e_u = u * det")
    for n in (5, 6, 8, 9, 12):
        nondeg, phi = classify_pairings(n)
        units = [u for u in range(n) if gcd(u, n) == 1]
        print(f"  n = {n:2d}:  nondegenerate scalars = {nondeg}")
        print(f"           units of Z/{n}          = {units}")
        report(f"nondegenerate  <=>  unit,  count = phi({n}) = {phi}",
               nondeg == units and len(nondeg) == phi)

    rule("4. Rank obstruction: the pairing is blind inside any cyclic subgroup")
    report("e(a v, b v) = 1 for all a, b, v over (Z/5)^2", check_cyclic_blindness(5))
    report("e(a v, b v) = 1 for all a, b, v over (Z/6)^2", check_cyclic_blindness(6))
    print("  Consequence: if the torsion were cyclic, nondegeneracy would force it")
    print("  to be trivial.  A nontrivial Weil pairing needs rank two.")

    rule("5. Endomorphism equivariance and the degree law")
    report("det(Mv, Mw) = det(M) det(v,w) over (Z/3)^2, all 81 matrices",
           check_endomorphism_law(3))
    report("e(mv, mw) = e(v,w)^(m^2) over (Z/5)^2", check_degree_law(5))

    rule("6. MOV embedding and the collapse of decisional Diffie-Hellman")
    n = 7
    tbl = mov_table(n)
    print(f"  a          : {list(range(n))}")
    print(f"  e(a P, Q)  : {tbl}   (exponents of zeta)")
    report("a |-> e(aP,Q) injective: curve DLP embeds into DLP in mu_n",
           len(set(tbl)) == n)
    report("DDH test e(aP,bQ) = e(P,cQ)  <=>  c = ab (mod 7)", check_ddh_collapse(7))
    report("the same test is vacuous on one cyclic subgroup",
           check_ddh_blind_on_cyclic(7))

    rule("7. Obstruction: the symmetric model with injective P |-> e(P,G)")
    for n in (2, 3, 5, 7):
        good = symmetric_model_injective_generators(n)
        report(f"n = {n}: no generator G makes P |-> e(P,G) injective", good == [])
    print("  Alternation gives e(G,G) = 1 = e(0,G), so injectivity forces G = 0,")
    print("  and then e(.,0) is constant.  The model is inhabited only by the")
    print("  trivial group -- every theorem proved in it would be vacuous.")

    rule("8. BLS in the corrected asymmetric setting over (Z/7)^2")
    S = BLSSetting(7)
    print(f"  g1 = {S.g1},  g2 = {S.g2},  order of zeta = e(g1,g2) is {S.root_order()}")
    sk, h = 4, 5
    pk, hp = S.public_key(sk), S.hash_point(h)
    sig = S.sign(sk, h)
    print(f"  sk = {sk}, message hash exponent h = {h}")
    print(f"  pk = {pk},  H = {hp},  signature = {sig}")
    print(f"  e(sigma, g2) = {S.e(sig, S.g2)}   e(H, pk) = {S.e(hp, pk)}")
    report("honest signature verifies", S.verifies(pk, hp, sig))
    report("correctness for all 49 key/message pairs", check_bls_correctness(7))
    report("exact criterion s = sk*h (mod 7) over all 343 triples => uniqueness",
           check_verification_criterion(7))
    print("  Accepted candidates s*g1 for (sk,h) = (4,5):",
          [s for s in range(7) if S.verifies(pk, hp, smul(7, s, S.g1))],
          f" (sk*h mod 7 = {(sk * h) % 7})")

    rule("9. Aggregation over (Z/5)^2 with 3 signers")
    report("aggregate correctness (all key/message tuples)",
           check_aggregate_correctness(5, 3))
    report("aggregate-to-single forgery extraction", check_forgery_extraction(5, 3))
    report("the extracted forgery IS the CDH target", check_cdh_reduction(5, 3))
    report("batch verification sound and complete (2 signers over (Z/3)^2)",
           check_batch_verification(3, 2))

    S5 = BLSSetting(5)
    sks, hs = (2, 3, 4), (1, 1, 1)
    pks = [S5.public_key(k) for k in sks]
    hpts = [S5.hash_point(x) for x in hs]
    sigs = [S5.sign(k, x) for k, x in zip(sks, hs)]
    agg = S5.aggregate(sigs)
    print(f"  individual signatures : {sigs}")
    print(f"  aggregate             : {agg}   (one group element, not three)")
    report("aggregate verifies", S5.agg_verifies(pks, hpts, agg))

    rule("10. Exact compression:  N^m signature tuples  -->  N aggregates")
    for n, m in ((3, 2), (3, 3), (5, 2)):
        total, image, N = compression_profile(n, m)
        print(f"  n = {n}, m = {m}:  tuples = N^m = {total:6d}   "
              f"distinct aggregates = {image:3d}   N = {N}")
        report(f"image is the whole group (compression {total} ->> {N})", image == N)

    rule("11. The rogue-key attack: registration is necessary")
    Sr = BLSSetting(5)
    pk1 = Sr.public_key(3)          # honest victim, secret key 3
    y = 4                            # adversary's chosen scalar
    pk2 = Sr.rogue_public_key(y, pk1)
    hpt = (2, 1)                     # any common message hash
    forged = smul(5, y, hpt)
    print(f"  victim public key pk1 = {pk1}")
    print(f"  rogue key pk2 = y*g2 - pk1 = {pk2}   (no secret key known)")
    print(f"  forged aggregate sigma = y*H = {forged}")
    report("the forged two-signer aggregate VERIFIES",
           Sr.agg_verifies([pk1, pk2], [hpt, hpt], forged))
    report("the attack succeeds for every y, victim key and message over (Z/5)^2",
           check_rogue_key_attack(5))
    print("  Hence aggregate security genuinely requires registered keys /")
    print("  proofs of possession: without them the scheme is broken outright.")

    print("\nAll demonstrations complete.\n")


if __name__ == "__main__":
    main()

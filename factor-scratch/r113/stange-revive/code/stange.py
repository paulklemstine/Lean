"""
r113/stange-revive -- Stange Algorithm 2.2, reimplemented FROM THE PRIMARY SOURCE.

Source: K. E. Stange, "Factoring using multiplicative relations modulo n: a
subexponential algorithm inspired by the index calculus", arXiv:2211.06821v2
(16 Jul 2023). Local copy: ../lit/stange.pdf (fetched by me this round).

This file is written from the printed Algorithm 2.2 (p.3) and the worked
example in Section 5 (p.7). It deliberately does NOT import or reuse anything
from r110-r112 (FANOUT_BRIEF ROUND 113 ADDENDUM "Do not").

Algorithm 2.2 (verbatim steps, p.3):
  1  Select B in N; factor base B = {p_1..p_b} = all primes < B.
  2  Select c in N.
  3-9 Relation finding: while j < b+c: choose x uniform in [1,n]; compute
       smallest positive residue of g^x mod n; attempt to factor it in the
       factor base; if it factors, store f_j = (f_{1,j},...,f_{b,j}) and x_j.
 10 Form the b x (b+c) integer matrix whose COLUMNS are the f_j.
 11 Compute c independent vectors b_1..b_c in the RIGHT KERNEL over Q.
 12 Scale each basis element to integers with no factor common to all entries.
 13-15 alpha_t = sum_j (b_t)_j x_j ; G = gcd(alpha_1,...,alpha_c); return G.

Correctness (paper 2.1, p.3-4): sum_j (b_t)_j f_j = 0 as a vector, and
f_j is the exponent vector of  prod_i p_i^{f_{j,i}} = g^{x_j} (mod n), so
prod_j g^{(b_t)_j x_j} = prod_i p_i^{0} = 1 (mod n), hence
alpha_t = sum_j (b_t)_j x_j = 0 (mod ord(g)).  So ord(g) | G.
We ASSERT this on every trial rather than trusting it.

Factor-from-multiple (NOT part of Algorithm 2.2; needed to test factoring):
write G = 2^s * t with t odd, a_0 = g^t, a_{j} = a_{j-1}^2, a_s = 1.
Let j* = max{j : a_j = 1 mod n}. Then a_{j*-1} is a square root of 1 mod n
that is not 1; it is a nontrivial one unless it is -1 mod n, in which case
gcd(a_{j*-1}-1, n) = n.  This is exactly the criterion
v2(ord_p g) != v2(ord_q g) (classical order-finding, success 20/27).

RNG: sha256-derived substream.  NEVER random.Random(x.__hash__()) --
Python randomizes str/tuple hashing per process under PYTHONHASHSEED, which
made two "same-seed" passes disagree in r112 (28/40 vs 33/40).  See
stange-q-kernel-method-works memory note.
"""
from __future__ import annotations

import hashlib
import math
import random
from fractions import Fraction

import sympy


# --------------------------------------------------------------------------
# deterministic RNG (sha256 substream, process-independent)
# --------------------------------------------------------------------------
def substream(seed: int, label: str) -> random.Random:
    h = hashlib.sha256(f"{seed}:{label}".encode()).digest()
    return random.Random(int.from_bytes(h, "big"))


# --------------------------------------------------------------------------
# ground-truth instance generation.  p,q in-process; p*q == N asserted.
# --------------------------------------------------------------------------
def gen_rsa(bits: int, seed: int, label: str = "n") -> tuple[int, int, int]:
    """Balanced RSA modulus with `bits` total bits. Returns (N, p, q)."""
    rng = substream(seed, f"gen:{bits}:{label}")
    half = bits // 2
    while True:
        p = sympy.nextprime(int(rng.getrandbits(half)) | (1 << (half - 1)) | 1)
        q = sympy.nextprime(int(rng.getrandbits(bits - half)) | (1 << (bits - 1 - half)) | 1)
        if p == q:
            continue
        N = p * q
        if N.bit_length() != bits:
            continue
        return N, p, q


def _prime_list(B: int) -> list[int]:
    """All primes < B (paper Algorithm 2.2 step 1)."""
    return list(sympy.primerange(2, B))


# --------------------------------------------------------------------------
# Algorithm 2.2
# --------------------------------------------------------------------------
def relation_search(g: int, N: int, primes: list[int], need: int,
                    rng: random.Random, budget: int):
    """
    Steps 3-9.  x is drawn UNIFORMLY in [1,n] exactly as the paper says
    (r48 found that stepping x from 1 upward is degenerate: g^x mod n is
    then SMALL for small x, so it does not sample the population).

    Returns (rels, trials, rejects).  rels is a list of (expvector, x).
    Stops early if `budget` trial divisions are exceeded (budget=None: none).
    """
    b = len(primes)
    used_x: set[int] = set()
    rels: list[tuple[list[int], int]] = []
    trials = 0
    rejects = 0
    spent = 0
    while len(rels) < need:
        x = rng.randrange(1, N)
        if x in used_x:
            continue
        used_x.add(x)
        trials += 1
        r = pow(g, x, N)
        ev = [0] * b
        ok = True
        rem = r
        for i, p in enumerate(primes):
            if rem == 1:
                break
            if rem % p == 0:
                e = 0
                while rem % p == 0:
                    rem //= p
                    e += 1
                ev[i] = e
        else:
            pass
        if rem != 1:
            ok = False
        spent += b
        if budget is not None and spent > budget:
            return rels, trials, rejects, False
        if ok:
            rels.append((ev, x))
        else:
            rejects += 1
    return rels, trials, rejects, True


def right_kernel_over_Q(M: list[list[int]]) -> list[list[Fraction]]:
    """
    Right kernel of the b x k matrix M (k > b), over Q.  Steps 11-12.
    Kernel vectors come back as RATIONALS -- taking int() on them silently
    breaks M v = 0 (r112 self-test T2 recorded this trap).  We scale each to
    primitive integers only at the end (step 12).
    """
    return sympy.Matrix(M).nullspace()


def primitive_int(v: list[Fraction]) -> list[int]:
    """Step 12: scale to integers with no factor common to all entries."""
    den = 1
    for f in v:
        den = den * f.denominator // math.gcd(den, f.denominator)
    iv = [int(f * den) for f in v]
    g = 0
    for z in iv:
        g = math.gcd(g, abs(z))
    if g == 0:
        g = 1
    iv = [z // g for z in iv]
    for z in iv:                       # fix global sign for reproducibility
        if z:
            if z < 0:
                iv = [-t for t in iv]
            break
    return iv


def algorithm_2_2(N: int, g: int, B: int, c: int, rng: random.Random,
                   budget: int | None = None, verify: bool = True):
    """
    Full Algorithm 2.2.  Returns a dict of everything measured.
    verify=True asserts ord(g) | G on every trial (paper section 2.1).
    """
    primes = _prime_list(B)
    b = len(primes)
    need = b + c
    rels, trials, rejects, completed = relation_search(
        g, N, primes, need, rng, budget)
    out = {
        "b": b, "c": c, "B": B, "need": need, "trials": trials,
        "rejects": rejects, "completed": completed, "n_rels": len(rels),
    }
    if not completed:
        return out

    M = [[rels[j][0][i] for j in range(need)] for i in range(b)]
    ker = right_kernel_over_Q(M)
    if len(ker) < c:
        out["kernel_dim"] = len(ker)
        out["G"] = 0
        return out
    out["kernel_dim"] = len(ker)
    basis = [primitive_int(list(v)) for v in ker[:c]]

    # ASSERT M v = 0 on every kernel vector (exact integer arithmetic).
    if verify:
        for bv in basis:
            for i in range(b):
                s = sum(M[i][j] * bv[j] for j in range(need))
                if s != 0:
                    raise AssertionError(f"kernel vector violates M v = 0 at row {i}")

    alphas = [sum(bv[j] * rels[j][1] for j in range(need)) for bv in basis]
    out["alphas"] = alphas
    G = 0
    for a in alphas:
        G = math.gcd(G, abs(a))
    out["G"] = G
    if verify:
        if G == 0 or pow(g, G, N) != 1:
            raise AssertionError("ord(g) does not divide G  (paper section 2.1)")
    return out


# --------------------------------------------------------------------------
# factoring from a multiple of ord(g)
# --------------------------------------------------------------------------
def factor_from_multiple(g: int, N: int, M: int):
    """
    Returns (factor_or_None, why).  M must be a multiple of ord(g).
    This is the classical strip-and-gcd post-processing every order
    routine already ends with; it is NOT part of Algorithm 2.2.

    Strip: while g^(M/2) == 1 mod N, replace M by M/2.  Then ord(g) | M and
    (M odd, or g^(M/2) != 1).  If M is even, g^(M/2) is a square root of 1
    mod each prime power of N; gcd(g^(M/2)-1, N) is a nontrivial factor
    exactly when the two roots have different signs, i.e. exactly when
    v2(ord_p g) != v2(ord_q g).
    """
    if M <= 0 or pow(g, M, N) != 1:
        return None, "M is not a multiple of ord(g)"
    while M % 2 == 0 and pow(g, M // 2, N) == 1:
        M //= 2
    if M % 2 == 1:
        return None, "M odd after stripping (ord(g) has no 2-part)"
    r = pow(g, M // 2, N)
    d = math.gcd(r - 1, N)
    if 1 < d < N:
        return d, "ok"
    if d == 1:
        return None, "g^(M/2) == +1 mod N (v2-valuations equal)"
    return None, "g^(M/2) == -1 mod N (v2-valuations equal)"


def true_order(g: int, m: int) -> int:
    """ord(g) mod m, by factoring m-1's... no: by the honest method below."""
    o = 1
    x = g % m
    # Pollard-style: o | lambda(m) | (m-1) for prime m; for prime powers use
    # the multiplicative order computed by successive division.
    return _order_mod(g, m)


def _order_mod(g: int, m: int) -> int:
    """Multiplicative order of g mod m for composite m, via lcm over the
    factorization of m (we only ever call this on KNOWN p and q, in the
    diagnostic; the factoring path never uses it)."""
    fac = sympy.factorint(m)
    o = 1
    for p, e in fac.items():
        pk = p ** e
        # phi(p^e)
        phi = (pk // p) * (p - 1)
        x = pow(g, phi, pk)
        d = phi
        # strip
        for q in sympy.factorint(phi):
            while d % q == 0 and pow(g, d // q, pk) == 1:
                d //= q
        o = o * d // math.gcd(o, d)
    return o


def v2(x: int) -> int:
    if x == 0:
        return 99
    return (x & -x).bit_length() - 1
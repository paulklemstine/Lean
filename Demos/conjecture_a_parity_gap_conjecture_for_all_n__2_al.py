#!/usr/bin/env python3
"""
The Parity Gap of the Exponent Counter — numerical demonstrations.

Setting
-------
Fix a modulus ``m`` and two maps ``S, T : {0, ..., n-1} -> Z/m``.  To a permutation
``sigma`` of ``{0, ..., n-1}`` attach the *exponent*

    E(sigma) = sum_j S[sigma(j)] * T[j]   (mod m)

and define the *parity-weighted exponent counter*

    c(r) = sum over { sigma : E(sigma) = r } of sign(sigma).

Facts demonstrated here (all proved in the accompanying paper):

  1.  Mass identity:  sum_r c(r) = 0  whenever n >= 2.
  2.  Determinant identity:  det( zeta^{S_j T_k} ) = sum_r c(r) zeta^r,
      exactly, as integer coefficient vectors modulo the relation
      1 + zeta + ... + zeta^{p-1} = 0.
  3.  PARITY GAP NEVER CLOSES for prime moduli (Chebotarev's theorem):
      for every prime p and injective S, T, some c(r) is nonzero.
      Equivalently every square minor of the DFT matrix of Z/p is nonsingular.
  4.  Two-sided gap: some residue has c(r) > 0, some other has c(r) < 0.
  5.  THE GAP DOES CLOSE over composite moduli, at every width up to m - q
      (q the least prime factor), via annihilating progressions or the
      pigeonhole involution; and never at widths m - 1 or m.
  6.  Additive uncertainty principle:  |supp f| + |supp f_hat| >= p + 1.
  7.  pi-adic depth: pi^{n(n-1)/2} divides the integral minor, pi = zeta - 1.
  8.  Mod-p rigidity: when n(n-1)/2 >= p - 1, all c(r) are congruent mod p.

Run with:  python3 demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import cmath
import itertools
import math
from typing import Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Core combinatorics
# ---------------------------------------------------------------------------


def permutation_sign(perm: Sequence[int]) -> int:
    """Return the sign (+1 / -1) of a permutation given in one-line notation."""
    n = len(perm)
    seen = [False] * n
    sign = 1
    for start in range(n):
        if seen[start]:
            continue
        length = 0
        j = start
        while not seen[j]:
            seen[j] = True
            j = perm[j]
            length += 1
        if length % 2 == 0:
            sign = -sign
    return sign


def coxeter_length(perm: Sequence[int]) -> int:
    """Number of inversions of ``perm``: pairs i < j with perm[i] > perm[j]."""
    n = len(perm)
    return sum(
        1 for i in range(n) for j in range(i + 1, n) if perm[i] > perm[j]
    )


def perm_exponent(S: Sequence[int], T: Sequence[int], perm: Sequence[int], m: int) -> int:
    """E(sigma) = sum_j S[sigma(j)] * T[j]  mod m."""
    return sum(S[perm[j]] * T[j] for j in range(len(perm))) % m


def parity_counter(S: Sequence[int], T: Sequence[int], m: int) -> List[int]:
    """The full parity-weighted exponent counter c(r), as a list of length m.

    Cost: Theta(n! * n).  Exact integer arithmetic.
    """
    n = len(S)
    counter = [0] * m
    for perm in itertools.permutations(range(n)):
        counter[perm_exponent(S, T, perm, m)] += permutation_sign(perm)
    return counter


def minimal_length_witness(
    S: Sequence[int], T: Sequence[int], m: int
) -> Tuple[int, int, Tuple[int, ...]]:
    """Return (r_star, c(r_star), sigma) as in the literal form of the theorem.

    ``r_star`` maximises |c(r)| and ``sigma`` is a permutation of minimal
    Coxeter length among those with exponent ``r_star``.
    """
    n = len(S)
    counter = parity_counter(S, T, m)
    r_star = max(range(m), key=lambda r: abs(counter[r]))
    best: Tuple[int, ...] | None = None
    best_len = math.inf
    for perm in itertools.permutations(range(n)):
        if perm_exponent(S, T, perm, m) == r_star:
            length = coxeter_length(perm)
            if length < best_len:
                best_len, best = length, perm
    assert best is not None, "extremal fibre must be nonempty"
    return r_star, counter[r_star], best


# ---------------------------------------------------------------------------
# Determinant of the DFT minor
# ---------------------------------------------------------------------------


def dft_minor_determinant(S: Sequence[int], T: Sequence[int], m: int) -> complex:
    """det( omega^{S_j T_k} ) with omega = exp(2 pi i / m), by Leibniz expansion."""
    omega = cmath.exp(2j * cmath.pi / m)
    total = 0j
    for perm in itertools.permutations(range(len(S))):
        total += permutation_sign(perm) * omega ** perm_exponent(S, T, perm, m)
    return total


def counter_to_complex(counter: Sequence[int], m: int) -> complex:
    """Evaluate sum_r c(r) omega^r."""
    omega = cmath.exp(2j * cmath.pi / m)
    return sum(c * omega ** r for r, c in enumerate(counter))


# ---------------------------------------------------------------------------
# Cyclotomic arithmetic: pi-adic depth of the integral minor
# ---------------------------------------------------------------------------


def poly_mul_mod_cyclotomic(a: List[int], b: List[int], p: int) -> List[int]:
    """Multiply in Z[X]/(1 + X + ... + X^{p-1}), coefficient lists of length p-1."""
    raw = [0] * (2 * p)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                if bj:
                    raw[i + j] += ai * bj
    # reduce X^p = 1 first
    folded = [0] * p
    for k, v in enumerate(raw):
        folded[k % p] += v
    # then use 1 + X + ... + X^{p-1} = 0, i.e. X^{p-1} = -(1 + ... + X^{p-2})
    top = folded[p - 1]
    return [folded[k] - top for k in range(p - 1)]


def integral_minor_in_cyclotomic(S: Sequence[int], T: Sequence[int], p: int) -> List[int]:
    """det( zeta^{S_j T_k} ) as an element of Z[zeta_p], in the basis 1..zeta^{p-2}."""
    n = len(S)
    total = [0] * (p - 1)
    for perm in itertools.permutations(range(n)):
        e = perm_exponent(S, T, perm, p)
        term = [0] * p
        term[e] = permutation_sign(perm)
        top = term[p - 1]
        for k in range(p - 1):
            total[k] += term[k] - top
    return total


def divide_by_pi(coeffs: List[int], p: int) -> List[int] | None:
    """Divide an element of Z[zeta_p] by pi = zeta - 1, or return None if not divisible.

    An element is given by the coefficient list of a polynomial ``A`` of degree at most
    ``p - 2`` in the basis ``1, zeta, ..., zeta^{p-2}``.  Divisibility by ``pi`` means
    ``A + c * Phi_p`` is divisible by ``X - 1`` for some integer ``c``; evaluating at
    ``X = 1`` forces ``c = -A(1)/p``, so ``pi | A`` exactly when ``p | A(1)`` -- which is
    the statement that the reduction ``red(A) = A(1) mod p`` vanishes.  The quotient is
    then obtained by synthetic division by ``X - 1``.
    """
    total = sum(coeffs)
    if total % p != 0:
        return None
    c = -total // p
    # B = A + c * Phi_p, a polynomial of degree p - 1 vanishing at X = 1
    B = [coeffs[k] + c for k in range(p - 1)] + [c]
    Q = [0] * (p - 1)
    Q[p - 2] = B[p - 1]
    for k in range(p - 2, 0, -1):
        Q[k - 1] = B[k] + Q[k]
    assert B[0] + Q[0] == 0, "synthetic division by X - 1 must be exact"
    return Q


def pi_adic_depth(coeffs: List[int], p: int, cap: int = 200) -> int:
    """Largest e <= cap with pi^e dividing the given (nonzero) element of Z[zeta_p]."""
    cur = list(coeffs)
    assert any(v != 0 for v in cur), "pi-adic depth of 0 is infinite"
    depth = 0
    while depth < cap:
        nxt = divide_by_pi(cur, p)
        if nxt is None:
            return depth
        cur = nxt
        depth += 1
    return depth


# ---------------------------------------------------------------------------
# Fourier analysis on Z/m and the uncertainty principle
# ---------------------------------------------------------------------------


def dft(f: Sequence[complex], m: int) -> List[complex]:
    """Discrete Fourier transform on Z/m: f_hat(xi) = sum_x f(x) omega^{-x xi}."""
    omega = cmath.exp(-2j * cmath.pi / m)
    return [sum(f[x] * omega ** (x * xi) for x in range(m)) for xi in range(m)]


def support_size(v: Iterable[complex], tol: float = 1e-9) -> int:
    return sum(1 for z in v if abs(z) > tol)


# ---------------------------------------------------------------------------
# Closure constructions over composite moduli
# ---------------------------------------------------------------------------


def annihilating_progressions(a: int, b: int, n: int) -> Tuple[List[int], List[int], int]:
    """S(i) = a i, T(j) = b j modulo m = a b: all exponents vanish."""
    m = a * b
    return [a * i % m for i in range(n)], [b * j % m for j in range(n)], m


def least_prime_factor(m: int) -> int:
    d = 2
    while d * d <= m:
        if m % d == 0:
            return d
        d += 1
    return m


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_1_counter_and_gap() -> None:
    banner("1.  The parity-weighted exponent counter, and the gap that never closes")
    for p, S, T in [
        (5, [1, 2], [0, 1]),
        (5, [0, 1, 2], [0, 1, 3]),
        (7, [1, 2, 4], [0, 1, 3]),
        (7, [0, 1, 2, 3], [0, 1, 2, 4]),
        (11, [0, 1, 3, 7], [2, 5, 6, 9]),
    ]:
        n = len(S)
        c = parity_counter(S, T, p)
        nz = {r: v for r, v in enumerate(c) if v != 0}
        print(f"\n p = {p:2d}   n = {n}   S = {S}   T = {T}")
        print(f"   counter c(r) = {c}")
        print(f"   nonzero at   = {nz}")
        print(f"   sum_r c(r)                     = {sum(c)}   (must be 0)")
        print(f"   max_r |c(r)|                   = {max(abs(v) for v in c)}   (must be >= 1)")
        print(f"   #supp c                        = {len(nz)}   (must be >= 2)")
        print(f"   sum_r c(r)^2                   = {sum(v * v for v in c)}   (must be >= 2)")
        assert sum(c) == 0
        assert max(abs(v) for v in c) >= 1
        assert len(nz) >= 2
        assert any(v > 0 for v in c) and any(v < 0 for v in c)
    print("\n  -> in every case the gap is open, and two-sided.")


def demo_2_determinant_identity() -> None:
    banner("2.  The counter is the determinant of a DFT minor, in disguise")
    for p, S, T in [(7, [1, 2, 4], [0, 1, 3]), (11, [0, 1, 3, 7], [2, 5, 6, 9])]:
        c = parity_counter(S, T, p)
        lhs = dft_minor_determinant(S, T, p)
        rhs = counter_to_complex(c, p)
        print(f"\n p = {p}   S = {S}   T = {T}")
        print(f"   det( omega^(S_j T_k) )   = {lhs:.10f}")
        print(f"   sum_r c(r) omega^r       = {rhs:.10f}")
        print(f"   |difference|             = {abs(lhs - rhs):.3e}")
        print(f"   |det|                    = {abs(lhs):.10f}   (nonzero: Chebotarev)")
        assert abs(lhs - rhs) < 1e-9
        assert abs(lhs) > 1e-9


def demo_3_exhaustive_chebotarev() -> None:
    banner("3.  Exhaustive check of Chebotarev's theorem for small primes")
    for p in (5, 7):
        for n in range(2, min(p, 4) + 1):
            worst = None
            count = 0
            for S in itertools.permutations(range(p), n):
                for T in itertools.permutations(range(p), n):
                    c = parity_counter(S, T, p)
                    peak = max(abs(v) for v in c)
                    count += 1
                    if worst is None or peak < worst[0]:
                        worst = (peak, S, T)
            assert worst is not None and worst[0] >= 1
            print(
                f"  p = {p}, n = {n}:  {count:7d} injective pairs tested, "
                f"min over pairs of max_r|c(r)| = {worst[0]}  "
                f"(attained e.g. at S={list(worst[1])}, T={list(worst[2])})"
            )
    print("\n  -> the parity gap never closes: the minimum of max_r|c(r)| is always >= 1.")


def demo_4_minimal_length_witness() -> None:
    banner("4.  The minimal-Coxeter-length witness")
    for p, S, T in [(7, [1, 2, 4], [0, 1, 3]), (11, [0, 1, 3, 7], [2, 5, 6, 9])]:
        r, val, sigma = minimal_length_witness(S, T, p)
        fibre = [
            perm
            for perm in itertools.permutations(range(len(S)))
            if perm_exponent(S, T, perm, p) == r
        ]
        print(f"\n p = {p}   S = {S}   T = {T}")
        print(f"   extremal residue r* = {r},  c(r*) = {val},  |c(r*)| >= 1  OK")
        print(f"   fibre over r* has {len(fibre)} permutations")
        print(f"   minimal-length witness sigma = {sigma}, length l(sigma) = {coxeter_length(sigma)}")
        print(f"   lengths in the fibre = {sorted(coxeter_length(t) for t in fibre)}")
        print(f"   sign(sigma) = {permutation_sign(sigma)} = (-1)^l = {(-1) ** coxeter_length(sigma)}")
        assert permutation_sign(sigma) == (-1) ** coxeter_length(sigma)
        assert coxeter_length(sigma) == min(coxeter_length(t) for t in fibre)


def demo_5_composite_closure() -> None:
    banner("5.  Over composite moduli the gap CLOSES — and primality is detected")
    print("\n  (a) the smallest closure: m = 4, S = T = (0, 2)")
    c = parity_counter([0, 2], [0, 2], 4)
    print(f"      counter = {c}   -> identically zero, the gap has closed")
    assert all(v == 0 for v in c)

    print("\n  (b) annihilating progressions S(i) = a i, T(j) = b j over m = a b")
    for a, b, n in [(2, 3, 2), (3, 3, 3), (2, 5, 2), (4, 3, 3)]:
        S, T, m = annihilating_progressions(a, b, n)
        c = parity_counter(S, T, m)
        ok = all(v == 0 for v in c)
        print(f"      m = {m:2d} = {a}*{b},  n = {n},  S = {S}, T = {T}  ->  closed: {ok}")
        assert ok

    print("\n  (c) primality test by exhaustive search at width n = 2")
    for m in range(2, 16):
        closed = False
        for S in itertools.permutations(range(m), 2):
            for T in itertools.permutations(range(m), 2):
                if all(v == 0 for v in parity_counter(S, T, m)):
                    closed = True
                    break
            if closed:
                break
        is_prime = m > 1 and all(m % d for d in range(2, int(m ** 0.5) + 1))
        verdict = "COMPOSITE" if closed else "PRIME    "
        print(f"      m = {m:2d}:  gap closes at n=2? {str(closed):5s}  -> {verdict}"
              f"   (truth: {'prime' if is_prime else 'composite'})")
        assert closed == (not is_prime)
    print("\n  -> gap closes  <=>  modulus is composite.")


def demo_6_width_of_closure() -> None:
    banner("6.  How wide a closed gap can be (even moduli: exactly m - 2)")
    for m in (4, 6):
        q = least_prime_factor(m)
        print(f"\n  modulus m = {m} (least prime factor q = {q}); predicted max width = m - q = {m - q}")
        for n in range(2, m + 1):
            closed = False
            witness = None
            for S in itertools.permutations(range(m), n):
                for T in itertools.permutations(range(m), n):
                    if all(v == 0 for v in parity_counter(S, T, m)):
                        closed, witness = True, (S, T)
                        break
                if closed:
                    break
            tag = "CLOSES" if closed else "open  "
            extra = f"  e.g. S={list(witness[0])}, T={list(witness[1])}" if witness else ""
            print(f"      n = {n}:  {tag}   (theory: {'closes' if n <= m - q else 'open'}){extra}")
            assert closed == (n <= m - q)
    print("\n  -> matches the theorem exactly: closure at every width 2..m-2, never at m-1 or m.")


def demo_7_uncertainty() -> None:
    banner("7.  The additive uncertainty principle  |supp f| + |supp f_hat| >= p + 1")
    for p in (5, 7):
        print(f"\n  p = {p}: scanning all 0/1-valued nonzero f on Z/{p}")
        worst = None
        for mask in range(1, 1 << p):
            f = [1.0 if (mask >> x) & 1 else 0.0 for x in range(p)]
            a, b = support_size(f), support_size(dft(f, p))
            if worst is None or a + b < worst[0]:
                worst = (a + b, mask, a, b)
            assert a + b >= p + 1, (mask, a, b)
        assert worst is not None
        supp = [x for x in range(p) if (worst[1] >> x) & 1]
        print(f"      minimum of |supp f| + |supp f_hat| = {worst[0]}   (bound: {p + 1})")
        print(f"      attained by f = indicator of {supp}  ({worst[2]} + {worst[3]})")
    print("\n  Contrast with a composite modulus, where the additive bound FAILS:")
    for m, sub in [(4, [0, 2]), (6, [0, 2, 4]), (9, [0, 3, 6])]:
        f = [1.0 if x in sub else 0.0 for x in range(m)]
        a, b = support_size(f), support_size(dft(f, m))
        print(f"      m = {m}: f = indicator of the subgroup {sub}: "
              f"|supp f| + |supp f_hat| = {a} + {b} = {a + b}  <  m + 1 = {m + 1}")
        assert a + b < m + 1
        print(f"                 but the multiplicative bound survives: {a} * {b} = {a * b} >= {m}")


def demo_8_pi_adic_depth() -> None:
    banner("8.  pi-adic depth of the integral minor:  pi^{n(n-1)/2} | det")
    for p, cases in [
        (5, [([1, 2], [0, 1]), ([0, 1, 2], [0, 1, 3])]),
        (7, [([1, 3], [2, 5]), ([1, 2, 4], [0, 1, 3])]),
    ]:
        for S, T in cases:
            n = len(S)
            elt = integral_minor_in_cyclotomic(S, T, p)
            depth = pi_adic_depth(elt, p)
            predicted = n * (n - 1) // 2
            print(f"  p = {p}, n = {n}, S = {S}, T = {T}:  "
                  f"v_pi(det) = {depth}   (lower bound n(n-1)/2 = {predicted})")
            assert depth >= predicted


def demo_9_rigidity() -> None:
    banner("9.  Mod-p rigidity:  n(n-1)/2 >= p - 1  =>  all c(r) congruent mod p")
    for p, S, T in [
        (3, [0, 1, 2], [0, 1, 2]),
        (5, [0, 1, 2, 3], [0, 1, 2, 3]),
        (5, [0, 1, 2, 3, 4], [0, 2, 4, 1, 3]),
        (7, [0, 1, 2, 3], [0, 1, 2, 3]),
        (7, [0, 1, 2, 3], [0, 1, 2, 4]),
        (7, [0, 1, 2, 3], [0, 1, 2, 6]),
    ]:
        n = len(S)
        depth = n * (n - 1) // 2
        c = parity_counter(S, T, p)
        residues = sorted({v % p for v in c})
        rigid_regime = depth >= p - 1
        print(f"\n  p = {p}, n = {n}:  n(n-1)/2 = {depth}, p - 1 = {p - 1}  "
              f"-> rigid regime: {rigid_regime}")
        print(f"      counter          = {c}")
        print(f"      residues mod {p}   = {residues}")
        if rigid_regime:
            assert len(residues) == 1, "rigidity must force a single residue class"
            lam = residues[0]
            if lam != 0:
                print(f"      common residue {lam} != 0  ->  FULL SUPPORT (no c(r) is zero)")
                assert all(v != 0 for v in c)
            else:
                peak = max(abs(v) for v in c)
                print(f"      common residue 0  ->  peak |c(r)| = {peak} >= p = {p}")
                assert peak >= p


def main() -> None:
    print(__doc__)
    demo_1_counter_and_gap()
    demo_2_determinant_identity()
    demo_3_exhaustive_chebotarev()
    demo_4_minimal_length_witness()
    demo_5_composite_closure()
    demo_6_width_of_closure()
    demo_7_uncertainty()
    demo_8_pi_adic_depth()
    demo_9_rigidity()
    banner("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()

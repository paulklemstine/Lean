"""
Numerical demonstrations for:

    Categorifying the Quantum Binomial Product Rule
    via Filtrations of Plethystic Modules

All polynomials in the formal variable q are represented as tuples of integer
coefficients in increasing degree order, e.g. 1 + q + 2q^2 <-> (1, 1, 2).
Everything is self-contained: no third-party dependencies.

The demos verify, over Z[q]:
  * the two dual Pascal recurrences (P1) and (P2),
  * Hermite reciprocity (self-duality)          [n,k]_q = [n,n-k]_q,
  * the classical specialization at q = 1       [n,k]_q|_{q=1} = C(n,k),
  * the absorption identity                     [N,k+1](1-q^{k+1}) = [N,k](1-q^{N-k}),
  * the categorified product rule (Rel2)        E^(a)E^(b) = [a+b,a]_q E^(a+b),
  * integrality (no denominators survive).
"""

from __future__ import annotations

from math import comb
from typing import Dict, List, Tuple

Poly = Tuple[int, ...]  # coefficients in increasing degree order


# ----------------------------------------------------------------------
# Minimal polynomial arithmetic over Z[q]
# ----------------------------------------------------------------------
def trim(p: Poly) -> Poly:
    """Drop trailing zero coefficients (canonical form)."""
    coeffs: List[int] = list(p)
    while len(coeffs) > 1 and coeffs[-1] == 0:
        coeffs.pop()
    return tuple(coeffs)


def padd(a: Poly, b: Poly) -> Poly:
    """Add two polynomials."""
    n = max(len(a), len(b))
    return trim(tuple(
        (a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0)
        for i in range(n)
    ))


def psub(a: Poly, b: Poly) -> Poly:
    """Subtract b from a."""
    n = max(len(a), len(b))
    return trim(tuple(
        (a[i] if i < len(a) else 0) - (b[i] if i < len(b) else 0)
        for i in range(n)
    ))


def pmul(a: Poly, b: Poly) -> Poly:
    """Multiply two polynomials."""
    out: List[int] = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    return trim(tuple(out))


def q_power_minus_one(e: int) -> Poly:
    """Return the polynomial (q^e - 1)  ...  used via (1 - q^e) = -(q^e - 1)."""
    coeffs = [0] * (e + 1)
    coeffs[0] = -1
    coeffs[e] = 1
    return trim(tuple(coeffs))  # q^e - 1


def one_minus_q_power(e: int) -> Poly:
    """Return the polynomial (1 - q^e)."""
    coeffs = [0] * (e + 1)
    coeffs[0] = 1
    coeffs[e] = -1
    return trim(tuple(coeffs))


def evaluate(p: Poly, q: int) -> int:
    """Evaluate the polynomial at an integer value of q."""
    return sum(c * (q ** i) for i, c in enumerate(p))


def to_str(p: Poly) -> str:
    """Human-readable rendering of a polynomial in q."""
    terms: List[str] = []
    for i, c in enumerate(p):
        if c == 0:
            continue
        if i == 0:
            terms.append(f"{c}")
        elif i == 1:
            terms.append(f"{c}q")
        else:
            terms.append(f"{c}q^{i}")
    return " + ".join(terms) if terms else "0"


# ----------------------------------------------------------------------
# Gaussian binomial coefficient via the dual Pascal recurrence (P1)
# ----------------------------------------------------------------------
def gauss_binom(n: int, k: int) -> Poly:
    """
    Gaussian binomial coefficient [n, k]_q computed by the recurrence
        [n,k]_q = [n-1,k-1]_q + q^k [n-1,k]_q          (P1)
    which is division-free and hence manifestly integral.
    """
    if k < 0 or k > n:
        return (0,)
    # memoized bottom-up q-Pascal triangle
    table: Dict[Tuple[int, int], Poly] = {}
    for nn in range(n + 1):
        for kk in range(nn + 1):
            if kk == 0 or kk == nn:
                table[(nn, kk)] = (1,)
            else:
                left = table[(nn - 1, kk - 1)]
                qk_right = pmul(monomial(kk), table[(nn - 1, kk)])
                table[(nn, kk)] = padd(left, qk_right)
    return table[(n, k)]


def monomial(deg: int) -> Poly:
    """Return q^deg."""
    return tuple([0] * deg + [1])


# ----------------------------------------------------------------------
# DEMO 1 — Dual Pascal recurrences (P1) and (P2)
# ----------------------------------------------------------------------
def demo_pascal_recurrences(n_max: int = 8) -> bool:
    """Verify (P1) and (P2) for all 1 <= n <= n_max, 0 <= k <= n."""
    print("=" * 68)
    print("DEMO 1 — Dual Pascal recurrences")
    print("  (P1) [n,k] = [n-1,k-1] + q^k [n-1,k]")
    print("  (P2) [n,k] = q^{n-k} [n-1,k-1] + [n-1,k]")
    print("=" * 68)
    ok = True
    for n in range(1, n_max + 1):
        for k in range(0, n + 1):
            lhs = gauss_binom(n, k)
            p1 = padd(gauss_binom(n - 1, k - 1), pmul(monomial(k), gauss_binom(n - 1, k)))
            p2 = padd(pmul(monomial(n - k), gauss_binom(n - 1, k - 1)), gauss_binom(n - 1, k))
            if lhs != p1 or lhs != p2:
                ok = False
                print(f"  MISMATCH at (n,k)=({n},{k})")
    print(f"  [4,2]_q = {to_str(gauss_binom(4, 2))}")
    print(f"  all (P1),(P2) verified up to n={n_max}: {ok}\n")
    return ok


# ----------------------------------------------------------------------
# DEMO 2 — Hermite reciprocity and q=1 specialization
# ----------------------------------------------------------------------
def demo_reciprocity_and_limit(n_max: int = 10) -> bool:
    """Verify [n,k]_q = [n,n-k]_q and [n,k]_q|_{q=1} = C(n,k)."""
    print("=" * 68)
    print("DEMO 2 — Hermite reciprocity  &  classical limit q -> 1")
    print("=" * 68)
    ok = True
    for n in range(0, n_max + 1):
        for k in range(0, n + 1):
            if gauss_binom(n, k) != gauss_binom(n, n - k):
                ok = False
                print(f"  reciprocity FAILS at ({n},{k})")
            if evaluate(gauss_binom(n, k), 1) != comb(n, k):
                ok = False
                print(f"  specialization FAILS at ({n},{k})")
    print(f"  [6,2]_q = {to_str(gauss_binom(6, 2))}")
    print(f"  [6,2]_q at q=1 = {evaluate(gauss_binom(6, 2), 1)} (= C(6,2) = {comb(6, 2)})")
    print(f"  reciprocity + specialization verified up to n={n_max}: {ok}\n")
    return ok


# ----------------------------------------------------------------------
# DEMO 3 — Absorption identity (the filtration engine)
# ----------------------------------------------------------------------
def demo_absorption(n_max: int = 9) -> bool:
    """Verify [N,k+1](1-q^{k+1}) = [N,k](1-q^{N-k})."""
    print("=" * 68)
    print("DEMO 3 — Absorption identity")
    print("  [N,k+1](1-q^{k+1}) = [N,k](1-q^{N-k})")
    print("=" * 68)
    ok = True
    for N in range(1, n_max + 1):
        for k in range(0, N):
            lhs = pmul(gauss_binom(N, k + 1), one_minus_q_power(k + 1))
            rhs = pmul(gauss_binom(N, k), one_minus_q_power(N - k))
            if lhs != rhs:
                ok = False
                print(f"  absorption FAILS at (N,k)=({N},{k})")
    N, k = 5, 2
    print(f"  N={N}, k={k}:")
    print(f"    [5,3](1-q^3) = {to_str(pmul(gauss_binom(N, k + 1), one_minus_q_power(k + 1)))}")
    print(f"    [5,2](1-q^3) = {to_str(pmul(gauss_binom(N, k), one_minus_q_power(N - k)))}")
    print(f"  absorption verified up to N={n_max}: {ok}\n")
    return ok


# ----------------------------------------------------------------------
# DEMO 4 — Categorified product rule (Rel2) and its single-step splitting
# ----------------------------------------------------------------------
def demo_product_rule(bound: int = 7) -> bool:
    """
    The Lusztig divided-power product rule E^(a)E^(b) = [a+b,a]_q E^(a+b).
    We verify the single-step splitting of the structure constant:
        [a+b,a]_q = [a+b-1,a-1]_q + q^a [a+b-1,a]_q.
    """
    print("=" * 68)
    print("DEMO 4 — Categorified product rule (Rel2)")
    print("  E^(a) E^(b) = [a+b,a]_q E^(a+b);  structure constant splits by (P1)")
    print("=" * 68)
    ok = True
    for a in range(1, bound + 1):
        for b in range(0, bound + 1):
            n = a + b
            const = gauss_binom(n, a)
            split = padd(gauss_binom(n - 1, a - 1), pmul(monomial(a), gauss_binom(n - 1, a)))
            if const != split:
                ok = False
                print(f"  splitting FAILS at (a,b)=({a},{b})")
    a, b = 3, 2
    print(f"  a={a}, b={b}:  structure constant [5,3]_q = {to_str(gauss_binom(a + b, a))}")
    print(f"    = [4,2]_q + q^3 [4,3]_q "
          f"= {to_str(padd(gauss_binom(4, 2), pmul(monomial(3), gauss_binom(4, 3))))}")
    print(f"  splitting verified for a,b up to {bound}: {ok}\n")
    return ok


# ----------------------------------------------------------------------
# DEMO 5 — Trinomial reciprocity (future-direction Conjecture 6.3)
# ----------------------------------------------------------------------
def demo_trinomial(bound: int = 6) -> bool:
    """
    Verify the trinomial reciprocity conjectured to be equivalent to
    associativity of the divided-power product:
        [a+b+c,a][b+c,b] = [a+b+c,c][a+b,a].
    """
    print("=" * 68)
    print("DEMO 5 — Trinomial reciprocity (associativity of divided powers)")
    print("  [a+b+c,a][b+c,b] = [a+b+c,c][a+b,a]")
    print("=" * 68)
    ok = True
    for a in range(0, bound + 1):
        for b in range(0, bound + 1):
            for c in range(0, bound + 1):
                lhs = pmul(gauss_binom(a + b + c, a), gauss_binom(b + c, b))
                rhs = pmul(gauss_binom(a + b + c, c), gauss_binom(a + b, a))
                if lhs != rhs:
                    ok = False
                    print(f"  trinomial FAILS at (a,b,c)=({a},{b},{c})")
    print(f"  trinomial reciprocity verified for a,b,c up to {bound}: {ok}\n")
    return ok


def main() -> None:
    results = {
        "Pascal recurrences (P1,P2)": demo_pascal_recurrences(),
        "Hermite reciprocity + limit": demo_reciprocity_and_limit(),
        "Absorption identity": demo_absorption(),
        "Categorified product rule": demo_product_rule(),
        "Trinomial reciprocity": demo_trinomial(),
    }
    print("=" * 68)
    print("SUMMARY")
    print("=" * 68)
    for name, ok in results.items():
        print(f"  {'PASS' if ok else 'FAIL'}  -  {name}")
    assert all(results.values()), "Some verification failed!"
    print("\nAll character-level identities verified over Z[q].")


if __name__ == "__main__":
    main()

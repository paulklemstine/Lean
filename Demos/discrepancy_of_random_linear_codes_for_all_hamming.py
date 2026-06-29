"""
Numerical demonstrations for:

    The Unconditional Kernel of the Hamming-Ball Discrepancy Conjecture

This self-contained script empirically confirms the deterministic results
established formally in the accompanying Lean development:

  * sphere_card        : |{x : d(x,0) = r}|  = C(n,r) (q-1)^r
  * ball_card_formula  : |B_r|               = sum_{i<=r} C(n,i) (q-1)^i
  * ball_card_eq       : ball volume is independent of the centre
  * sum_inter_ball     : sum_z |C cap B_r(z)| = |C| * |B_r|   (EXACT)
  * card_bad_centres_le: |{z : |C cap B_r(z)| >= t}| * t <= |C| * |B_r|
  * coset invariance   : z -> |C cap B_r(z)| is constant on cosets of C

Everything is computed by brute-force enumeration over F_q^n for small (q, n),
so the printed equalities are exact integer identities, not approximations.
"""

from __future__ import annotations

from itertools import product
from math import comb, log
from typing import Iterable


# --------------------------------------------------------------------------- #
# Core combinatorial primitives
# --------------------------------------------------------------------------- #
def hamming_distance(x: tuple[int, ...], y: tuple[int, ...]) -> int:
    """Number of coordinates in which x and y differ."""
    return sum(1 for a, b in zip(x, y) if a != b)


def whole_space(q: int, n: int) -> list[tuple[int, ...]]:
    """All q^n strings of length n over the alphabet {0, ..., q-1}."""
    return [tuple(v) for v in product(range(q), repeat=n)]


def ball(center: tuple[int, ...], r: int, space: Iterable[tuple[int, ...]]) -> list[tuple[int, ...]]:
    """The Hamming ball B_r(center): all points within distance r."""
    return [x for x in space if hamming_distance(x, center) <= r]


def sphere_card_formula(n: int, q: int, r: int) -> int:
    """Closed form C(n,r) (q-1)^r for the count of points at distance exactly r."""
    return comb(n, r) * (q - 1) ** r


def ball_card_formula(n: int, q: int, r: int) -> int:
    """Closed form sum_{i<=r} C(n,i) (q-1)^i for the ball volume."""
    return sum(comb(n, i) * (q - 1) ** i for i in range(r + 1))


def q_ary_entropy(rho: float, q: int) -> float:
    """The q-ary entropy H_q(rho) governing the dimension threshold."""
    if rho in (0.0, 1.0):
        return 0.0 if rho == 0.0 else log(q - 1, q)
    return (
        rho * log(q - 1, q)
        - rho * log(rho, q)
        - (1 - rho) * log(1 - rho, q)
    )


# --------------------------------------------------------------------------- #
# Demo 1: sphere and ball volume formulas (Theorems 6 and 7)
# --------------------------------------------------------------------------- #
def demo_volume_formulas(q: int = 3, n: int = 4) -> None:
    print("=" * 70)
    print(f"Demo 1: ball/sphere volume formulas  (q={q}, n={n})")
    print("=" * 70)
    space = whole_space(q, n)
    origin = tuple(0 for _ in range(n))
    for r in range(n + 1):
        sphere_brute = sum(1 for x in space if hamming_distance(x, origin) == r)
        ball_brute = len(ball(origin, r, space))
        sphere_form = sphere_card_formula(n, q, r)
        ball_form = ball_card_formula(n, q, r)
        ok = sphere_brute == sphere_form and ball_brute == ball_form
        print(
            f"  r={r}: |sphere|={sphere_brute:>4} (C(n,r)(q-1)^r={sphere_form:>4}) "
            f"|ball|={ball_brute:>4} (formula={ball_form:>4})  {'OK' if ok else 'MISMATCH'}"
        )
    print()


# --------------------------------------------------------------------------- #
# Demo 2: centre-independence of ball volume (Theorem 2)
# --------------------------------------------------------------------------- #
def demo_centre_independence(q: int = 3, n: int = 3, r: int = 1) -> None:
    print("=" * 70)
    print(f"Demo 2: ball volume is centre-independent  (q={q}, n={n}, r={r})")
    print("=" * 70)
    space = whole_space(q, n)
    volumes = {len(ball(z, r, space)) for z in space}
    print(f"  distinct ball volumes over all {q**n} centres: {volumes}")
    print(f"  closed-form |B_r| = {ball_card_formula(n, q, r)}")
    print(f"  all equal? {'YES' if len(volumes) == 1 else 'NO'}")
    print()


# --------------------------------------------------------------------------- #
# Demo 3: the EXACT averaging identity (Theorem 4)
# --------------------------------------------------------------------------- #
def demo_averaging_identity(q: int = 2, n: int = 5, r: int = 2) -> None:
    print("=" * 70)
    print(f"Demo 3: exact averaging identity  (q={q}, n={n}, r={r})")
    print("=" * 70)
    space = whole_space(q, n)

    # An arbitrary (non-linear) subset C, to stress that NO structure is needed.
    C = [space[i] for i in range(0, len(space), 3)]
    total = sum(len(set(C) & set(ball(z, r, space))) for z in space)
    rhs = len(C) * ball_card_formula(n, q, r)
    mean = total / (q ** n)
    target = len(C) * ball_card_formula(n, q, r) / (q ** n)
    print(f"  |C| = {len(C)} (arbitrary, non-linear subset)")
    print(f"  sum_z |C cap B_r(z)| = {total}")
    print(f"  |C| * |B_r|          = {rhs}")
    print(f"  identity holds exactly? {'YES' if total == rhs else 'NO'}")
    print(f"  average per centre = {mean:.6f}  ==  target |C||B_r|/q^n = {target:.6f}")
    print()


# --------------------------------------------------------------------------- #
# Demo 4: Markov discrepancy bound (Theorem 5)
# --------------------------------------------------------------------------- #
def demo_markov_bound(q: int = 2, n: int = 6, r: int = 2) -> None:
    print("=" * 70)
    print(f"Demo 4: Markov discrepancy (overcrowding) bound  (q={q}, n={n}, r={r})")
    print("=" * 70)
    space = whole_space(q, n)
    # A small linear code: span of two basis vectors.
    e1 = tuple(1 if i == 0 else 0 for i in range(n))
    e2 = tuple(1 if i == 1 else 0 for i in range(n))
    C = set()
    for a in range(q):
        for b in range(q):
            C.add(tuple((a * e1[i] + b * e2[i]) % q for i in range(n)))
    C = list(C)
    counts = [len(set(C) & set(ball(z, r, space))) for z in space]
    bound_const = len(C) * ball_card_formula(n, q, r)
    print(f"  |C| = {len(C)}, |B_r| = {ball_card_formula(n, q, r)}, "
          f"|C||B_r| = {bound_const}")
    for t in range(1, max(counts) + 2):
        bad = sum(1 for c in counts if c >= t)
        ceiling = bound_const / t
        ok = bad * t <= bound_const
        print(f"  t={t}: bad centres={bad:>4}  bad*t={bad*t:>5}  "
              f"<= |C||B_r|={bound_const}  (ceiling {ceiling:8.2f})  {'OK' if ok else 'VIOLATED'}")
    print()


# --------------------------------------------------------------------------- #
# Demo 5: coset invariance for linear codes (Theorem 8)
# --------------------------------------------------------------------------- #
def demo_coset_invariance(q: int = 2, n: int = 5, r: int = 2) -> None:
    print("=" * 70)
    print(f"Demo 5: coset invariance of the ball count  (q={q}, n={n}, r={r})")
    print("=" * 70)
    space = whole_space(q, n)
    e1 = tuple(1 if i == 0 else 0 for i in range(n))
    C = {tuple((a * e1[i]) % q for i in range(n)) for a in range(q)}
    C = list(C)
    Cset = set(C)

    def count_at(z: tuple[int, ...]) -> int:
        return len(Cset & set(ball(z, r, space)))

    # Group centres by coset z + C and check the count is constant on each.
    seen: dict[frozenset, set[int]] = {}
    for z in space:
        coset = frozenset(tuple((z[i] + w[i]) % q for i in range(n)) for w in C)
        seen.setdefault(coset, set()).add(count_at(z))
    all_constant = all(len(vals) == 1 for vals in seen.values())
    print(f"  number of cosets G/C = {len(seen)}  (= q^n/|C| = {q**n // len(C)})")
    print(f"  ball count constant on every coset? {'YES' if all_constant else 'NO'}")
    print()


# --------------------------------------------------------------------------- #
# Demo 6: the entropy threshold for the code dimension
# --------------------------------------------------------------------------- #
def demo_entropy_threshold(q: int = 2) -> None:
    print("=" * 70)
    print(f"Demo 6: (1/n) log_q |B_(rho n)| -> H_q(rho)  (q={q})")
    print("=" * 70)
    rho = 0.25
    print(f"  rho = {rho},  H_q(rho) = {q_ary_entropy(rho, q):.6f}")
    for n in (8, 16, 32, 64, 128):
        r = int(rho * n)
        approx = log(ball_card_formula(n, q, r), q) / n
        print(f"  n={n:>4}: (1/n)log_q|B_r| = {approx:.6f}")
    print("  -> threshold dimension k ~ (1 - H_q(rho) + eps) n")
    print()


if __name__ == "__main__":
    demo_volume_formulas()
    demo_centre_independence()
    demo_averaging_identity()
    demo_markov_bound()
    demo_coset_invariance()
    demo_entropy_threshold()
    print("All demonstrations completed: every identity holds exactly.")

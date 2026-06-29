"""
Strange Attractors as Algebraic Objects -- numerical demonstrations.

This self-contained script demonstrates the main results about the dyadic
solenoid Sigma_2 (the inverse limit of the doubling map of the circle) and its
first Cech cohomology, the group of dyadic rationals Z[1/2]:

  * Dyadic membership and the 2-adic valuation certificate.
  * Dyadic.inv_two_pow_mem : every 1/2^n is dyadic.
  * Dyadic.two_divisible   : multiplication by 2 is surjective on Z[1/2].
  * Dyadic.not_fg          : Z[1/2] is not finitely generated, via the
                             "escapee" witness 1/2^(N+1) for any finite set.
  * nerveCohomology_fg / solenoid_not_finite_nerve_cohomology : finite graphs
    have H^1 = Z^{beta_1} (finitely generated), so no finite graph reproduces
    the solenoid's H^1.

Everything is exact rational arithmetic; no external dependencies.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Optional, Tuple


# --------------------------------------------------------------------------- #
# 1. Dyadic rationals Z[1/2] as a concrete subgroup of Q
# --------------------------------------------------------------------------- #

def two_adic_valuation_of_denominator(q: Fraction) -> int:
    """Return v_2(den(q)): the exponent of 2 in the reduced denominator of q.

    q lies in Z[1/2] iff den(q) is a power of two, in which case this is the
    minimal k with 2^k * q in Z.
    """
    b = q.denominator
    k = 0
    while b % 2 == 0:
        b //= 2
        k += 1
    return k


def is_dyadic(q: Fraction) -> bool:
    """Decide membership q in Z[1/2]: true iff the denominator is a power of 2."""
    b = q.denominator
    while b % 2 == 0:
        b //= 2
    return b == 1


def dyadic_certificate(q: Fraction) -> Optional[Tuple[int, int]]:
    """Return (k, m) with (m : Q) = 2^k * q and m in Z, or None if q not dyadic.

    This mirrors the existential witness in `mem_Dyadic`.
    """
    if not is_dyadic(q):
        return None
    k = two_adic_valuation_of_denominator(q)
    m = q * (2 ** k)
    assert m.denominator == 1
    return k, int(m)


# --------------------------------------------------------------------------- #
# 2. The structural theorems
# --------------------------------------------------------------------------- #

def inv_two_pow_mem(n: int) -> Fraction:
    """Dyadic.inv_two_pow_mem : exhibit 1/2^n and confirm it is dyadic."""
    q = Fraction(1, 2 ** n)
    assert is_dyadic(q)
    return q


def two_divisible_witness(y: Fraction) -> Fraction:
    """Dyadic.two_divisible : given dyadic y, return dyadic x with 2x = y."""
    assert is_dyadic(y)
    x = y / 2
    assert is_dyadic(x) and 2 * x == y
    return x


def escapee_for_generators(S: List[Fraction]) -> Fraction:
    """Dyadic.not_fg : given a finite candidate generating set S of dyadics,
    return a dyadic number provably outside the subgroup it generates.

    Every integer combination of S has denominator dividing 2^N where
    N = max_s v_2(den(s)); the witness 1/2^(N+1) has a strictly larger
    denominator and therefore escapes the span.
    """
    assert all(is_dyadic(s) for s in S)
    N = max((two_adic_valuation_of_denominator(s) for s in S), default=0)
    return Fraction(1, 2 ** (N + 1))


def integer_span_denominator_bound(S: List[Fraction]) -> int:
    """Largest power of two that can appear as a denominator in <S>: 2^N."""
    N = max((two_adic_valuation_of_denominator(s) for s in S), default=0)
    return 2 ** N


# --------------------------------------------------------------------------- #
# 3. The telescope colimit Z --x2--> Z --x2--> ... == Z[1/2]
# --------------------------------------------------------------------------- #

def colimit_eval(level: int, value: int) -> Fraction:
    """Element '(level, value)' of colim(Z --x2--> ...) as the dyadic value/2^level."""
    return Fraction(value, 2 ** level)


def colimit_equal(a: Tuple[int, int], b: Tuple[int, int]) -> bool:
    """Two telescope representatives are equal iff they evaluate to equal dyadics."""
    (n1, m1), (n2, m2) = a, b
    return m1 * (2 ** n2) == m2 * (2 ** n1)


# --------------------------------------------------------------------------- #
# 4. Finite nerve graphs: H^1 = Z^{beta_1}, always finitely generated
# --------------------------------------------------------------------------- #

def betti_one(num_vertices: int, num_edges: int, num_components: int) -> int:
    """NerveGraph.cohomRank : beta_1 = max(0, E + components - V)."""
    raw = num_edges + num_components - num_vertices
    return raw if raw >= 0 else 0


def nerve_cohomology_rank(num_vertices: int, num_edges: int,
                          num_components: int) -> int:
    """Rank of H^1(G) = Z^{beta_1}; this finite rank makes it finitely generated."""
    return betti_one(num_vertices, num_edges, num_components)


# --------------------------------------------------------------------------- #
# Demonstration driver
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 70)
    print("Strange Attractors as Algebraic Objects -- the dyadic solenoid")
    print("=" * 70)

    print("\n[1] Dyadic membership certificates (m : Q) = 2^k * q")
    for q in [Fraction(3, 8), Fraction(5, 1), Fraction(1, 3), Fraction(17, 16)]:
        cert = dyadic_certificate(q)
        if cert is None:
            print(f"    {str(q):>6} : NOT dyadic (denominator not a power of 2)")
        else:
            k, m = cert
            print(f"    {str(q):>6} : dyadic, k={k}, m={m}  (check 2^{k}*{q} = {m})")

    print("\n[2] inv_two_pow_mem : 1/2^n is always dyadic")
    for n in range(6):
        print(f"    1/2^{n} = {inv_two_pow_mem(n)} in Z[1/2]")

    print("\n[3] two_divisible : doubling is invertible on Z[1/2]")
    for y in [Fraction(3, 8), Fraction(1, 1), Fraction(7, 16)]:
        x = two_divisible_witness(y)
        print(f"    y={y}: x={x} is dyadic and 2x={2 * x} = y")

    print("\n[4] not_fg : every finite generating set has an escapee")
    for S in [[Fraction(1, 2), Fraction(3, 4)],
              [Fraction(1, 8), Fraction(5, 16), Fraction(1, 1)],
              [Fraction(1, 2 ** 10)]]:
        bound = integer_span_denominator_bound(S)
        esc = escapee_for_generators(S)
        print(f"    S={[str(s) for s in S]}")
        print(f"        span denominators divide {bound}; escapee {esc} "
              f"(den {esc.denominator}) is NOT generated")

    print("\n[5] telescope colimit == Z[1/2]")
    reps = [(0, 1), (1, 2), (2, 4), (3, 5)]
    for (n, m) in reps:
        print(f"    ({n},{m}) -> {colimit_eval(n, m)}")
    print(f"    (1,2) == (0,1)? {colimit_equal((1, 2), (0, 1))}  "
          f"(both equal {colimit_eval(0, 1)})")
    print(f"    (2,4) == (0,1)? {colimit_equal((2, 4), (0, 1))}")
    print(f"    (3,5) == (0,1)? {colimit_equal((3, 5), (0, 1))}")

    print("\n[6] finite nerve graphs: H^1 = Z^{beta_1}, finite rank => f.g.")
    graphs = [("K_{3,3} (PM nerve)", 6, 9, 1),
              ("K_4    (GHZ nerve)", 4, 6, 1),
              ("CHSH square      ", 4, 4, 1),
              ("tree (5 vertices) ", 5, 4, 1)]
    for name, v, e, c in graphs:
        r = nerve_cohomology_rank(v, e, c)
        print(f"    {name}: V={v} E={e} comp={c} -> beta_1 = {r}, "
              f"H^1 = Z^{r} (finitely generated)")

    print("\n[7] the obstruction: solenoid H^1 = Z[1/2] is NOT finitely")
    print("    generated, but every finite graph's H^1 = Z^{beta_1} IS.")
    print("    Finite generation is preserved by isomorphism, so no finite")
    print("    graph can have H^1 isomorphic to the solenoid's. QED.")


if __name__ == "__main__":
    main()

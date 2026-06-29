"""
Numerical demonstrations of the Hamming-ball discrepancy duality framework.

Every routine here is self-contained (standard library only) and exercises one of the
formally proved theorems:

  * sum_inter_ball        -- exact averaging identity:  sum_z |C n B_r(z)| = |C|*|B_r(0)|
  * ball_card_eq          -- ball volume independent of the centre
  * ball_card_formula     -- |B_r(0)| = sum_{i<=r} C(n,i)(q-1)^i
  * sphere_card           -- |S_r(0)| = C(n,r)(q-1)^r
  * card_bad_centres_le   -- Markov upper bound on crowded centres
  * inter_ball_coset_invariant -- periodicity of the discrepancy field for linear codes

Ambient space G = (Z_q)^n, i.e. length-n strings over a q-ary alphabet.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Iterable, Sequence

Point = tuple[int, ...]


# --------------------------------------------------------------------------- core
def hamming_distance(x: Sequence[int], y: Sequence[int]) -> int:
    """Number of coordinates where x and y disagree."""
    return sum(1 for a, b in zip(x, y) if a != b)


def ambient_space(q: int, n: int) -> list[Point]:
    """All q^n strings of length n over the alphabet {0, ..., q-1}."""
    return [tuple(p) for p in itertools.product(range(q), repeat=n)]


def ball(q: int, n: int, r: int, centre: Point) -> list[Point]:
    """B_r(centre) = { x in G : d(x, centre) <= r }."""
    return [x for x in ambient_space(q, n) if hamming_distance(x, centre) <= r]


def sphere_card(n: int, q: int, r: int) -> int:
    """Closed form |S_r(0)| = C(n,r) (q-1)^r  (Lean: sphere_card)."""
    return math.comb(n, r) * (q - 1) ** r


def ball_card_formula(n: int, q: int, r: int) -> int:
    """Closed form |B_r(0)| = sum_{i<=r} C(n,i)(q-1)^i  (Lean: ball_card_formula)."""
    return sum(sphere_card(n, q, i) for i in range(r + 1))


def local_count(code: Iterable[Point], q: int, n: int, r: int, centre: Point) -> int:
    """N_C(centre) = |C n B_r(centre)|."""
    cs = set(code)
    return sum(1 for x in cs if hamming_distance(x, centre) <= r)


# ------------------------------------------------------------------ demonstrations
def demo_exact_averaging_identity(q: int, n: int, r: int, code: Sequence[Point]) -> None:
    """Certify  sum_z |C n B_r(z)| = |C| * |B_r(0)|  by brute force (Lean: sum_inter_ball)."""
    centres = ambient_space(q, n)
    lhs = sum(local_count(code, q, n, r, z) for z in centres)
    vol = ball_card_formula(n, q, r)
    rhs = len(code) * vol
    print(f"[averaging identity] q={q} n={n} r={r} |C|={len(code)}")
    print(f"    sum_z N_C(z)         = {lhs}")
    print(f"    |C| * |B_r(0)|       = {rhs}   (volume |B_r(0)| = {vol})")
    print(f"    exact mean per centre= {rhs}/{q**n} = {rhs / q**n:.6f}")
    assert lhs == rhs, "averaging identity violated!"
    print("    OK: identity holds exactly.\n")


def demo_centre_independent_volume(q: int, n: int, r: int) -> None:
    """Check |B_r(z)| is the same for every centre (Lean: ball_card_eq)."""
    sizes = {len(ball(q, n, r, z)) for z in ambient_space(q, n)}
    closed = ball_card_formula(n, q, r)
    print(f"[centre-independent volume] q={q} n={n} r={r}")
    print(f"    distinct ball sizes over all centres = {sizes}")
    print(f"    closed-form |B_r(0)|                  = {closed}")
    assert sizes == {closed}, "ball volume depends on centre!"
    print("    OK: every ball has the same size.\n")


def demo_markov_crowded_bound(q: int, n: int, r: int, code: Sequence[Point], t: int) -> None:
    """Compare true #crowded centres with the Markov bound (Lean: card_bad_centres_le)."""
    centres = ambient_space(q, n)
    crowded = sum(1 for z in centres if local_count(code, q, n, r, z) >= t)
    vol = ball_card_formula(n, q, r)
    bound = (len(code) * vol) // t
    print(f"[Markov crowded-centre bound] q={q} n={n} r={r} |C|={len(code)} t={t}")
    print(f"    #centres with N_C(z) >= t : {crowded}")
    print(f"    Markov upper bound |C||B|/t: {bound}")
    assert crowded <= bound, "Markov bound violated!"
    print("    OK: true count <= bound.\n")


def demo_linear_code_periodicity(q: int, n: int, r: int) -> None:
    """For a linear code C, N_C(z) = N_C(z + c) for every codeword c (Lean: inter_ball_coset_invariant)."""
    # Linear code: all (a, a, ..., a) repetition codewords over Z_q  (closed under +).
    code: list[Point] = [tuple([a] * n) for a in range(q)]
    centres = ambient_space(q, n)
    ok = True
    for z in centres:
        base = local_count(code, q, n, r, z)
        for c in code:
            zc = tuple((zi + ci) % q for zi, ci in zip(z, c))
            if local_count(code, q, n, r, zc) != base:
                ok = False
    print(f"[linear-code periodicity] q={q} n={n} r={r} repetition code |C|={len(code)}")
    print(f"    N_C constant on cosets of C : {ok}")
    assert ok, "discrepancy field not periodic!"
    print("    OK: discrepancy field is periodic.\n")


def main() -> None:
    random.seed(2026)
    print("=" * 70)
    print("Hamming-Ball Discrepancy Duality -- numerical certification")
    print("=" * 70 + "\n")

    # ternary alphabet, length 3, radius 1, random code of 7 codewords
    q, n, r = 3, 3, 1
    G = ambient_space(q, n)
    code = random.sample(G, 7)
    demo_exact_averaging_identity(q, n, r, code)
    demo_centre_independent_volume(q, n, r)
    demo_markov_crowded_bound(q, n, r, code, t=2)
    demo_linear_code_periodicity(q, n, r)

    # binary alphabet, length 5, radius 2, random code of 6 codewords
    q, n, r = 2, 5, 2
    G = ambient_space(q, n)
    code = random.sample(G, 6)
    demo_exact_averaging_identity(q, n, r, code)
    demo_centre_independent_volume(q, n, r)
    demo_markov_crowded_bound(q, n, r, code, t=3)

    print("All numerical checks passed -- the proved identities hold on every instance.")


if __name__ == "__main__":
    main()

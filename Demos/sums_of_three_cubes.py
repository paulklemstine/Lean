"""
Numerical demonstrations for the Sum of Three Cubes problem.

This self-contained script demonstrates the central results:

  1. Every integer cube is congruent to 0, 1, or 8 modulo 9.
  2. No sum of three such residues equals 4 or 5 modulo 9, so any integer
     congruent to 4 or 5 modulo 9 is NOT a sum of three cubes (the modular
     obstruction).
  3. Every admissible residue class modulo 9 has a small explicit witness.
  4. A bounded brute-force search exhibiting representations, exploiting the
     negation symmetry S(n) <=> S(-n).

Run with:  python demo.py
"""

from __future__ import annotations

from typing import Optional, Tuple, List, Set


# ---------------------------------------------------------------------------
# 1. Cubic residues modulo 9
# ---------------------------------------------------------------------------

def cubic_residues_mod9() -> Set[int]:
    """Return the set of values x^3 mod 9 over all residues x mod 9."""
    return {(x ** 3) % 9 for x in range(9)}


# ---------------------------------------------------------------------------
# 2. Attainable sums of three cubic residues modulo 9
# ---------------------------------------------------------------------------

def attainable_triple_sums_mod9() -> Set[int]:
    """Return all residues mod 9 expressible as a sum of three cubes mod 9."""
    residues = cubic_residues_mod9()
    return {(a + b + c) % 9 for a in residues for b in residues for c in residues}


def is_locally_obstructed(n: int) -> bool:
    """True iff n is provably NOT a sum of three cubes (n = 4 or 5 mod 9)."""
    return (n % 9) in (4, 5)


# ---------------------------------------------------------------------------
# 3. Small explicit witnesses for the admissible residue classes
# ---------------------------------------------------------------------------

SMALL_WITNESSES: dict[int, Tuple[int, int, int]] = {
    0: (0, 0, 0),
    1: (1, 0, 0),
    2: (1, 1, 0),
    3: (1, 1, 1),
    6: (2, -1, -1),
    7: (2, 0, -1),
    8: (2, 0, 0),
}


def verify_witness(n: int, xyz: Tuple[int, int, int]) -> bool:
    """Check that x^3 + y^3 + z^3 == n."""
    x, y, z = xyz
    return x ** 3 + y ** 3 + z ** 3 == n


# ---------------------------------------------------------------------------
# 4. Bounded brute-force search for representations
# ---------------------------------------------------------------------------

def is_perfect_cube(m: int) -> Optional[int]:
    """Return the integer cube root of m if m is a perfect cube, else None."""
    if m == 0:
        return 0
    sign = 1 if m > 0 else -1
    a = abs(m)
    r = round(a ** (1.0 / 3.0))
    for cand in (r - 1, r, r + 1):
        if cand >= 0 and cand ** 3 == a:
            return sign * cand
    return None


def find_representation(n: int, bound: int) -> Optional[Tuple[int, int, int]]:
    """Search for x^3 + y^3 + z^3 = n with |x|, |z| <= bound.

    Fixes x and z, then tests whether n - x^3 - z^3 is a perfect cube.
    """
    for x in range(-bound, bound + 1):
        x3 = x ** 3
        for z in range(x, bound + 1):  # z >= x avoids some duplicate work
            rem = n - x3 - z ** 3
            y = is_perfect_cube(rem)
            if y is not None:
                return (x, y, z)
    return None


# ---------------------------------------------------------------------------
# Demonstration driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("SUMS OF THREE CUBES — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    print("\n[1] Cubic residues modulo 9:")
    res = sorted(cubic_residues_mod9())
    print(f"    {{x^3 mod 9 : x}} = {res}")
    assert res == [0, 1, 8]
    print("    -> Confirmed: every cube is 0, 1, or 8 modulo 9.")

    print("\n[2] Attainable sums of three cubic residues modulo 9:")
    sums = sorted(attainable_triple_sums_mod9())
    print(f"    attainable = {sums}")
    print(f"    missing    = {sorted(set(range(9)) - set(sums))}")
    assert 4 not in sums and 5 not in sums
    print("    -> Confirmed: 4 and 5 are unreachable (modular obstruction).")

    print("\n[3] The modular obstruction in action:")
    for n in [4, 5, 13, 14, 22, 23, 31, 32]:
        print(f"    n = {n:>3}: n mod 9 = {n % 9} -> "
              f"{'NOT a sum of three cubes (proven)' if is_locally_obstructed(n) else 'admissible'}")

    print("\n[4] Small explicit witnesses for admissible residue classes:")
    for n, xyz in SMALL_WITNESSES.items():
        ok = verify_witness(n, xyz)
        assert ok
        print(f"    {n} = {xyz[0]}^3 + {xyz[1]}^3 + {xyz[2]}^3   [verified: {ok}]")

    print("\n[5] Bounded brute-force search (bound = 25):")
    targets = [0, 1, 2, 3, 6, 7, 8, 9, 10, 11, 12, 15, 16, 17, 18, 20, 24, 29]
    for n in targets:
        if is_locally_obstructed(n):
            print(f"    n = {n:>3}: obstructed mod 9, skipping")
            continue
        rep = find_representation(n, 25)
        if rep is not None:
            x, y, z = rep
            assert x ** 3 + y ** 3 + z ** 3 == n
            print(f"    n = {n:>3}: {x}^3 + {y}^3 + {z}^3 = {n}")
        else:
            print(f"    n = {n:>3}: no representation found within bound (try larger)")

    print("\n[6] Negation symmetry S(n) <=> S(-n):")
    for n in [6, 29]:
        rep = find_representation(n, 25)
        if rep:
            x, y, z = rep
            print(f"    {n}  = {x}^3 + {y}^3 + {z}^3")
            print(f"    {-n} = {-x}^3 + {-y}^3 + {-z}^3")

    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()

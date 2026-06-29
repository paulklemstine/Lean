"""
demo.py — Crystallographic Groups and Music: The 17 Wallpaper Groups of Rhythm
==============================================================================

Self-contained numerical demonstrations of the theory formalized in the
accompanying Lean development.  Every helper is inlined; the file has no
dependencies beyond the Python standard library and runs with `python demo.py`.

Each section corresponds to a theorem in the paper:

  1. Translation symmetry group of a cyclic rhythm  (subgroup structure)
  2. Period membership                              (multiples of the period)
  3. Palindrome detection + the parity theorem      (center determines parity)
  4. Complement duality of onset counts             (onsets + silences = period)
  5. Double mirror implies 180-degree rotation      (pmm contains p2)
  6. The seventeen wallpaper types                  (17 types, 10 mirror, 8 glide)
  7. The crystallographic restriction               (orders in {1,2,3,4,6})
  8. Symmetry as information / degrees of freedom    (more symmetry, fewer bits)
  9. Necklace counting and prime rigidity            (2^gcd(k,p); primes -> 2)
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import gcd
from typing import Callable

Rhythm = list[bool]          # a cyclic rhythm of period len(r): index n -> onset?
Pattern2D = list[list[bool]]  # a drum pattern: grid[t][v]; tested cyclically


# ---------------------------------------------------------------------------
# 1. Translation symmetry group of a cyclic rhythm
# ---------------------------------------------------------------------------
def is_translation_sym(r: Rhythm, k: int) -> bool:
    """True iff shifting `r` by `k` (mod p) leaves it unchanged: r(n+k) = r(n)."""
    p = len(r)
    return all(r[(n + k) % p] == r[n] for n in range(p))


def translation_sym_group(r: Rhythm) -> list[int]:
    """The set of all translation symmetries of `r` — always a subgroup of Z/pZ."""
    p = len(r)
    return [k for k in range(p) if is_translation_sym(r, k)]


def is_subgroup(elements: list[int], p: int) -> bool:
    """Verify the given subset of Z/pZ is closed under +, contains 0, and is closed under negation."""
    s = set(elements)
    if 0 not in s:
        return False
    if any((-k) % p not in s for k in s):
        return False
    return all((a + b) % p in s for a in s for b in s)


# ---------------------------------------------------------------------------
# 3. Palindromes and the parity theorem
# ---------------------------------------------------------------------------
def reflect(r: Rhythm) -> Rhythm:
    """Reflection of a finite rhythm: position k -> position n-1-k."""
    n = len(r)
    return [r[n - 1 - k] for k in range(n)]


def is_palindrome_finite(r: Rhythm) -> bool:
    """True iff the rhythm reads the same forwards and backwards."""
    return reflect(r) == r


def onset_count(r: Rhythm) -> int:
    """Number of onsets (True values) in one period."""
    return sum(1 for b in r if b)


def complement(r: Rhythm) -> Rhythm:
    """Swap onsets and silences."""
    return [not b for b in r]


# ---------------------------------------------------------------------------
# 5. Two-dimensional drum-pattern symmetries (tested cyclically)
# ---------------------------------------------------------------------------
def has_time_mirror(g: Pattern2D) -> bool:
    """g(-t, v) = g(t, v) for all cells (retrograde symmetry)."""
    p, q = len(g), len(g[0])
    return all(g[(-t) % p][v] == g[t][v] for t in range(p) for v in range(q))


def has_pitch_mirror(g: Pattern2D) -> bool:
    """g(t, -v) = g(t, v) for all cells (inversion symmetry)."""
    p, q = len(g), len(g[0])
    return all(g[t][(-v) % q] == g[t][v] for t in range(p) for v in range(q))


def has_rotation2(g: Pattern2D) -> bool:
    """g(-t, -v) = g(t, v) for all cells (180-degree rotation)."""
    p, q = len(g), len(g[0])
    return all(g[(-t) % p][(-v) % q] == g[t][v] for t in range(p) for v in range(q))


# ---------------------------------------------------------------------------
# 6-7. The seventeen wallpaper types
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class WallpaperType:
    name: str
    max_rotation_order: int
    has_mirror: bool
    has_glide: bool
    musical_name: str


WALLPAPER_TYPES: list[WallpaperType] = [
    WallpaperType("p1",   1, False, False, "free rhythm"),
    WallpaperType("p2",   2, False, False, "call-and-response"),
    WallpaperType("pm",   1, True,  False, "palindrome"),
    WallpaperType("pg",   1, False, True,  "canon"),
    WallpaperType("cm",   1, True,  True,  "round"),
    WallpaperType("pmm",  2, True,  False, "bilateral palindrome"),
    WallpaperType("pmg",  2, True,  True,  "inverted canon"),
    WallpaperType("pgg",  2, False, True,  "double canon"),
    WallpaperType("cmm",  2, True,  True,  "round + palindrome"),
    WallpaperType("p4",   4, False, False, "4-bar cycle"),
    WallpaperType("p4m",  4, True,  False, "variations on a theme"),
    WallpaperType("p4g",  4, True,  True,  "inverted variations"),
    WallpaperType("p3",   3, False, False, "3-bar blues"),
    WallpaperType("p3m1", 3, True,  False, "3-fold mirror blues"),
    WallpaperType("p31m", 3, True,  True,  "3-fold glide blues"),
    WallpaperType("p6",   6, False, False, "whole-tone scale symmetry"),
    WallpaperType("p6m",  6, True,  True,  "maximal symmetry"),
]

CRYSTALLOGRAPHIC_ORDERS: set[int] = {1, 2, 3, 4, 6}


# ---------------------------------------------------------------------------
# 8. Symmetry as information
# ---------------------------------------------------------------------------
def rhythm_degrees_of_freedom(p: int, d: int) -> int:
    """Independent positions of a period-p rhythm invariant under a group of order d|p."""
    return p // d


# ---------------------------------------------------------------------------
# 9. Necklace counting
# ---------------------------------------------------------------------------
def fixed_by_rotation(p: int, k: int) -> int:
    """Number of length-p binary patterns fixed by a rotation of k positions: 2^gcd(k,p)."""
    return 2 ** gcd(k, p)


def necklace_count(p: int) -> int:
    """Burnside count of distinct length-p binary necklaces."""
    total = sum(fixed_by_rotation(p, k) for k in range(p))
    return total // p


def is_prime(n: int) -> bool:
    return n >= 2 and all(n % d for d in range(2, int(n ** 0.5) + 1))


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------
def main() -> None:
    line = "=" * 70

    print(line)
    print("1-2. TRANSLATION SYMMETRY GROUP  (subgroup of Z/pZ; period membership)")
    print(line)
    # tresillo-like 8-step rhythm and a 2-symmetric one
    examples: dict[str, Rhythm] = {
        "tresillo  10010010": [True, False, False, True, False, False, True, False],
        "halfsym   10011001": [True, False, False, True, True, False, False, True],
        "fours     10001000": [True, False, False, False, True, False, False, False],
    }
    for label, r in examples.items():
        g = translation_sym_group(r)
        print(f"  {label}:  symmetry group = {g}   subgroup? {is_subgroup(g, len(r))}")
    print("  (Theorem: the symmetry set is always a subgroup; |group| divides p.)")

    print()
    print(line)
    print("3. PALINDROMES AND THE PARITY THEOREM (center determines parity)")
    print(line)
    palindromes: list[Rhythm] = [
        [True, False, True],                       # k=1, center onset
        [True, False, False, False, True],         # k=2, center silent
        [True, True, True, True, True],            # k=2, center onset
    ]
    for r in palindromes:
        k = len(r) // 2
        total_par = onset_count(r) % 2
        center_par = 1 if r[k] else 0
        bits = "".join("1" if b else "0" for b in r)
        ok = total_par == center_par
        print(f"  {bits}: palindrome={is_palindrome_finite(r)}  "
              f"onsets%2={total_par}  center={center_par}  match={ok}")
    print("  reflect(reflect(r)) == r :",
          all(reflect(reflect(r)) == r for r in palindromes))

    print()
    print(line)
    print("4. COMPLEMENT DUALITY  (onsets + silences = period)")
    print(line)
    for label, r in examples.items():
        oc, cc = onset_count(r), onset_count(complement(r))
        print(f"  {label}:  onsets={oc} + complement_onsets={cc} = {oc + cc}  (p={len(r)})")

    print()
    print(line)
    print("5. DOUBLE MIRROR IMPLIES ROTATION  (pmm contains p2)")
    print(line)
    # build a random-ish pattern, then symmetrize under both mirrors
    base: Pattern2D = [[(t * v) % 3 == 0 for v in range(4)] for t in range(4)]

    def symmetrize_both_mirrors(g: Pattern2D) -> Pattern2D:
        p, q = len(g), len(g[0])
        out = [[False] * q for _ in range(p)]
        for t in range(p):
            for v in range(q):
                out[t][v] = (g[t][v] or g[(-t) % p][v]
                             or g[t][(-v) % q] or g[(-t) % p][(-v) % q])
        return out

    sym = symmetrize_both_mirrors(base)
    print(f"  symmetrized pattern: time_mirror={has_time_mirror(sym)}  "
          f"pitch_mirror={has_pitch_mirror(sym)}  =>  rotation2={has_rotation2(sym)}")
    print("  (Both mirrors present forces the 180-degree rotation automatically.)")

    print()
    print(line)
    print("6. THE SEVENTEEN WALLPAPER TYPES")
    print(line)
    n_types = len(WALLPAPER_TYPES)
    n_mirror = sum(1 for w in WALLPAPER_TYPES if w.has_mirror)
    n_glide = sum(1 for w in WALLPAPER_TYPES if w.has_glide)
    print(f"  total types = {n_types}   mirror types = {n_mirror}   glide types = {n_glide}")
    print("  type   rot  mir gli  musical interpretation")
    for w in WALLPAPER_TYPES:
        print(f"  {w.name:<5} {w.max_rotation_order:>3}  "
              f"{int(w.has_mirror)}   {int(w.has_glide)}   {w.musical_name}")

    print()
    print(line)
    print("7. THE CRYSTALLOGRAPHIC RESTRICTION  (rotation orders in {1,2,3,4,6})")
    print(line)
    orders = sorted({w.max_rotation_order for w in WALLPAPER_TYPES})
    print(f"  observed rotation orders = {orders}")
    print(f"  all in {{1,2,3,4,6}}? "
          f"{all(w.max_rotation_order in CRYSTALLOGRAPHIC_ORDERS for w in WALLPAPER_TYPES)}")
    print("  (No 5-fold or 7-fold symmetry can repeat in the plane.)")

    print()
    print(line)
    print("8. SYMMETRY AS INFORMATION  (more symmetry, fewer degrees of freedom)")
    print(line)
    p = 12
    print(f"  period p = {p}")
    for d in (1, 2, 3, 4, 6, 12):
        dof = rhythm_degrees_of_freedom(p, d)
        print(f"    symmetry order d={d:>2}:  degrees of freedom = p/d = {dof:>2}  "
              f"=> at most 2^{dof} = {2 ** dof} rhythms")
    print("  Monotone: as d increases, p/d decreases (Nat.div_le_div_left).")

    print()
    print(line)
    print("9. NECKLACE COUNTING AND PRIME RIGIDITY")
    print(line)
    for p in range(2, 13):
        nz = {fixed_by_rotation(p, k) for k in range(1, p)}
        tag = "PRIME -> only 2 fixed by nonzero rotation" if is_prime(p) else ""
        print(f"  p={p:>2}:  necklaces={necklace_count(p):>4}   "
              f"nonzero-rotation fixed-counts={sorted(nz)}  {tag}")
    print("  fixed_by_rotation(p,0) = 2^p :",
          all(fixed_by_rotation(p, 0) == 2 ** p for p in range(1, 8)))


if __name__ == "__main__":
    main()

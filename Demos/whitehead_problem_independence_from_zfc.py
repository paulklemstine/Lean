"""
demo.py — Numerical demonstrations for the ZFC-provable skeleton of the
Whitehead problem.

This script illustrates the three formalized results:

  Theorem 1 (isWhiteheadGroup_of_projective):
      every projective (in particular free) abelian group is a Whitehead group.
  Theorem 2 (Module.IsTorsionFree.of_projective_int):
      every projective Z-module is torsion-free.
  Theorem 3 (not_isWhiteheadGroup_zmod):
      the cyclic group Z/n is NOT a Whitehead group for n >= 2, witnessed by
      the non-split extension  0 -> Z --(.n)--> Z --(mod n)--> Z/n -> 0.

We model finitely generated abelian groups concretely:
  * the free group Z^r is the lattice of integer r-tuples;
  * the cyclic group Z/n is the integers modulo n.

A Z-linear map out of Z/n is determined by the image of the generator 1, but it
must respect the relation n*1 = 0; this is exactly where the obstruction bites.

Self-contained: standard library only.
"""

from __future__ import annotations

from typing import Callable, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Theorem 3 — the cyclic torsion obstruction
# ---------------------------------------------------------------------------

def candidate_section_is_well_defined(n: int, c: int) -> bool:
    """A Z-linear map s : Z/n -> Z is determined by c = s(1).

    Well-definedness requires the relation n*1 = 0 in Z/n to map to 0 in Z,
    i.e. n*c = 0 in the torsion-free group Z. Since Z has no torsion, this
    forces c = 0. This function returns whether the choice c yields a
    well-defined Z-linear map.
    """
    return n * c == 0  # in Z, true iff c == 0 (for n >= 1)


def cyclic_extension_splits(n: int, search_bound: int = 1000) -> bool:
    """Decide whether 0 -> Z --(.n)--> Z --(mod n)--> Z/n -> 0 splits.

    A splitting is a Z-linear section s : Z/n -> Z with (mod n) o s = id.
    s is determined by c = s(1) and must (a) be well defined and (b) satisfy
    (c mod n) == 1. We search all c in [-search_bound, search_bound]; by
    Theorem 3 no such c exists for n >= 2.
    """
    for c in range(-search_bound, search_bound + 1):
        if not candidate_section_is_well_defined(n, c):
            continue
        # c must reduce to the generator 1 modulo n for s to be a section.
        if c % n == 1 % n:
            return True
    return False


def demonstrate_obstruction(max_n: int = 8) -> None:
    print("=" * 70)
    print("Theorem 3: Z/n is NOT a Whitehead group for n >= 2")
    print("=" * 70)
    print(f"{'n':>3} | only well-defined s(1) | splits? | Whitehead?")
    print("-" * 70)
    for n in range(2, max_n + 1):
        # The only well-defined section value c = s(1) is c = 0.
        well_defined = [c for c in range(-3, 4) if candidate_section_is_well_defined(n, c)]
        splits = cyclic_extension_splits(n)
        print(f"{n:>3} | {str(well_defined):>22} | {str(splits):>7} | "
              f"{'YES' if splits else 'NO'}")
    print("\nThe only Z-linear map Z/n -> Z is the zero map (c = 0), which is\n"
          "not a section, so the extension never splits: Z/n fails Whitehead.\n")


# ---------------------------------------------------------------------------
# Theorem 1 — projective (free) groups are Whitehead groups
# ---------------------------------------------------------------------------

def split_free_extension_section(
    r: int,
    lift: Callable[[List[int]], List[int]],
    p: Callable[[List[int]], List[int]],
) -> Callable[[List[int]], List[int]]:
    """Construct the splitting section for an extension of the free group Z^r.

    Given a surjection p : G -> Z^r and a chosen lift of each standard basis
    vector e_i of Z^r to some g_i in G with p(g_i) = e_i, the section is the
    unique linear extension s(a) = sum_i a_i * g_i. This is the algorithmic
    content of Theorem 1: projectivity of Z^r lets us lift basis vectors and
    extend linearly. Here `lift(e_i)` returns g_i.
    """
    basis_lifts = [lift([1 if j == i else 0 for j in range(r)]) for i in range(r)]

    def section(a: List[int]) -> List[int]:
        dim = len(basis_lifts[0])
        out = [0] * dim
        for i, coeff in enumerate(a):
            for k in range(dim):
                out[k] += coeff * basis_lifts[i][k]
        return out

    return section


def demonstrate_projective_whitehead() -> None:
    print("=" * 70)
    print("Theorem 1: free Z^r is a Whitehead group (extensions split)")
    print("=" * 70)
    r = 2
    # Model an extension 0 -> Z -> G -> Z^2 -> 0 with G = Z^3, where the copy of
    # Z sits in the last coordinate and p forgets it.
    #   p(x, y, z) = (x, y)              (surjection onto Z^2)
    #   i(t)       = (0, 0, t)           (injection of Z)
    def p(g: List[int]) -> List[int]:
        return [g[0], g[1]]

    # Choose an arbitrary lift of basis vectors (any preimage works).
    def lift(e: List[int]) -> List[int]:
        return [e[0], e[1], 5 * e[0] - 3 * e[1]]  # arbitrary 'twist' in kernel direction

    s = split_free_extension_section(r, lift, p)

    print("Checking p(s(a)) == a for several a in Z^2:")
    ok = True
    for a in ([1, 0], [0, 1], [3, -2], [7, 11], [-4, -9]):
        sa = s(a)
        psa = p(sa)
        good = psa == a
        ok = ok and good
        print(f"  a={a!s:>9}  s(a)={sa!s:>14}  p(s(a))={psa!s:>9}  ok={good}")
    print(f"\nSection property p o s = id holds for all tested a: {ok}\n")


# ---------------------------------------------------------------------------
# Theorem 2 — projective groups are torsion-free
# ---------------------------------------------------------------------------

def has_torsion_element(
    elements: List[Tuple[int, ...]],
    add: Callable[[Tuple[int, ...], Tuple[int, ...]], Tuple[int, ...]],
    zero: Tuple[int, ...],
    max_mult: int = 50,
) -> Optional[Tuple[Tuple[int, ...], int]]:
    """Search a finite sample of a group for a nonzero torsion element:
    a nonzero a with n*a = 0 for some 1 <= n <= max_mult. Returns (a, n) or None.
    """
    for a in elements:
        if a == zero:
            continue
        acc = zero
        for n in range(1, max_mult + 1):
            acc = add(acc, a)
            if acc == zero:
                return (a, n)
    return None


def demonstrate_torsion_free() -> None:
    print("=" * 70)
    print("Theorem 2: free/projective Z^r is torsion-free")
    print("=" * 70)

    def add(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
        return tuple(x + y for x, y in zip(a, b))

    zero = (0, 0)
    sample = [(x, y) for x in range(-3, 4) for y in range(-3, 4)]
    found = has_torsion_element(sample, add, zero)
    print(f"Sampled {len(sample)} elements of Z^2.")
    print(f"Nonzero torsion element found: {found}")
    print("None: Z^2 is torsion-free, as predicted by Theorem 2.\n")

    # Contrast with Z/6, which is built entirely of torsion.
    print("Contrast — the cyclic group Z/6 (full of torsion):")
    def add6(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
        return ((a[0] + b[0]) % 6,)
    z6 = [(k,) for k in range(6)]
    found6 = has_torsion_element(z6, add6, (0,))
    print(f"  Nonzero torsion element of Z/6: {found6}")
    print("  Z/6 has torsion, hence is not projective and not Whitehead.\n")


def main() -> None:
    demonstrate_projective_whitehead()
    demonstrate_torsion_free()
    demonstrate_obstruction()
    print("=" * 70)
    print("Summary: free groups split every extension (Whitehead) and carry no")
    print("torsion; cyclic groups Z/n (n>=2) carry torsion and fail Whitehead.")
    print("The decidable boundary: for finitely generated groups,")
    print("Whitehead  <=>  free.")
    print("=" * 70)


if __name__ == "__main__":
    main()

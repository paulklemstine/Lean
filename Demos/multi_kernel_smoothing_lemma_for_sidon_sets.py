"""Numerical demonstrations for the L2 energy characterisation of Sidon sets.

A finite set of integers s is a *Sidon set* (a B_2 set) if the only solutions
of a + b = c + d with a, b, c, d in s are the trivial ones (a = c or a = d).

Central results demonstrated here:

  * Additive energy   E[s] = #{(a,b,c,d) in s^4 : a+b = c+d}
                            = sum_x r_s(x)^2   where r_s(x) = #{(a,b): a+b=x}.
  * Universal floor    E[s] >= 2|s|^2 - |s|      (every finite set).
  * Characterisation   s is Sidon  <=>  E[s] = 2|s|^2 - |s|.
  * Energy defect      D(s) = E[s] - (2|s|^2 - |s|) >= 0 counts the non-trivial
                       additive coincidences; D(s) = 0 iff s is Sidon.

Run with:  python demo.py
"""

from __future__ import annotations

from collections import Counter
from itertools import combinations
from typing import Dict, List, Sequence, Tuple


def self_convolution(s: Sequence[int]) -> Dict[int, int]:
    """Return r_s(x) = number of ordered pairs (a, b) in s x s with a + b = x."""
    counts: Counter[int] = Counter()
    for a in s:
        for b in s:
            counts[a + b] += 1
    return dict(counts)


def additive_energy(s: Sequence[int]) -> int:
    """Additive energy E[s] = sum_x r_s(x)^2 (the squared L2 norm of r_s)."""
    return sum(r * r for r in self_convolution(s).values())


def additive_energy_bruteforce(s: Sequence[int]) -> int:
    """Direct count of quadruples (a,b,c,d) in s^4 with a+b = c+d (for checking)."""
    total = 0
    for a in s:
        for b in s:
            for c in s:
                for d in s:
                    if a + b == c + d:
                        total += 1
    return total


def energy_floor(n: int) -> int:
    """Universal lower bound on additive energy for a set of size n: 2n^2 - n."""
    return 2 * n * n - n


def energy_defect(s: Sequence[int]) -> int:
    """D(s) = E[s] - (2|s|^2 - |s|); zero iff s is Sidon."""
    n = len(set(s))
    return additive_energy(set(s)) - energy_floor(n)


def is_sidon_direct(s: Sequence[int]) -> bool:
    """Direct Sidon test: all pairwise sums a+b (a <= b) distinct."""
    sums = [a + b for a, b in combinations(sorted(set(s)), 2)]
    sums += [2 * a for a in set(s)]
    return len(sums) == len(set(sums))


def is_sidon_via_energy(s: Sequence[int]) -> bool:
    """Sidon test via the characterisation theorem: E[s] = 2n^2 - n."""
    n = len(set(s))
    return additive_energy(set(s)) == energy_floor(n)


def nontrivial_coincidences(s: Sequence[int]) -> List[Tuple[int, int, int, int]]:
    """List quadruples (a,b,c,d), a+b=c+d, that are NOT of trivial form.

    A quadruple is trivial iff a == c (diagonal kernel) or a == d (swap kernel).
    The number of such (ordered) quadruples equals the energy defect D(s).
    """
    out: List[Tuple[int, int, int, int]] = []
    us = sorted(set(s))
    for a in us:
        for b in us:
            for c in us:
                for d in us:
                    if a + b == c + d and not (a == c or a == d):
                        out.append((a, b, c, d))
    return out


def report(name: str, s: Sequence[int]) -> None:
    us = sorted(set(s))
    n = len(us)
    e_conv = additive_energy(us)
    e_brute = additive_energy_bruteforce(us)
    floor = energy_floor(n)
    defect = energy_defect(us)
    print(f"--- {name}: {us} ---")
    print(f"  |s| = {n}")
    print(f"  E[s] (convolution) = {e_conv}")
    print(f"  E[s] (brute force) = {e_brute}   [match: {e_conv == e_brute}]")
    print(f"  floor 2n^2 - n     = {floor}")
    print(f"  defect D(s)        = {defect}   (#nontrivial coincidences = "
          f"{len(nontrivial_coincidences(us))})")
    print(f"  Sidon (direct)     = {is_sidon_direct(us)}")
    print(f"  Sidon (via energy) = {is_sidon_via_energy(us)}")
    assert e_conv == e_brute, "Parseval identity failed"
    assert e_conv >= floor, "Universal floor violated!"
    assert (defect == 0) == is_sidon_direct(us), "Characterisation mismatch!"
    assert is_sidon_direct(us) == is_sidon_via_energy(us), "Sidon tests disagree!"
    assert defect == len(nontrivial_coincidences(us)), "Defect != coincidence count"
    print("  [all invariants verified]\n")


def main() -> None:
    print("=" * 64)
    print("L2 ENERGY CHARACTERISATION OF SIDON SETS -- NUMERICAL DEMO")
    print("=" * 64, "\n")

    report("Sidon quadruple", [0, 1, 3, 7])           # E = 28 = floor
    report("Consecutive run", [0, 1, 2, 3])           # E = 44 > 28
    report("Small AP", [0, 1, 2])                      # E = 19 > 15
    report("Perfect difference triple", [0, 1, 3])     # E = 15 = floor
    report("Larger Sidon set", [0, 1, 3, 7, 12])      # E = floor
    report("Random-ish non-Sidon", [0, 2, 3, 4, 7])

    # Empirical minimality of energy over 4-element sets in {0,...,9}.
    print("Minimising additive energy over 4-subsets of {0,...,9}:")
    best = None
    for combo in combinations(range(10), 4):
        e = additive_energy(combo)
        if best is None or e < best[0]:
            best = (e, combo)
    assert best is not None
    print(f"  minimum E = {best[0]} attained by {best[1]}")
    print(f"  theoretical floor 2*4^2 - 4 = {energy_floor(4)}")
    print(f"  is that minimiser Sidon? {is_sidon_direct(best[1])}\n")

    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
